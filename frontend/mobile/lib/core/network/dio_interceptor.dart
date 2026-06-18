import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';
import '../services/session_service.dart';

/// Dio interceptor for handling authentication tokens automatically
/// Follows clean architecture principles for network layer
class AuthInterceptor extends Interceptor {
  final SessionService _sessionService = SessionService();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip token addition for auth endpoints
    if (options.path.contains('/auth/login') || 
        options.path.contains('/auth/register') ||
        options.path.contains('/auth/refresh')) {
      handler.next(options);
      return;
    }

    // Get access token directly from SecureStorage
    final accessToken = await SecureStorage.getToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    // Ensure content type is set
    if (options.headers['Content-Type'] == null) {
      options.headers['Content-Type'] = 'application/json';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 unauthorized errors by attempting token refresh
    if (err.response?.statusCode == 401) {
      try {
        // Use SessionService to refresh token
        final refreshSuccess = await _sessionService.refreshAccessToken();
        
        if (refreshSuccess) {
          // Retry the original request with new token
          final token = await SecureStorage.getToken();
          if (token != null) {
            err.requestOptions.headers['Authorization'] = 'Bearer $token';
            
            // Retry the request
            final dio = Dio();
            final response = await dio.fetch(err.requestOptions);
            return handler.resolve(response);
          }
        }
      } catch (e) {
        // Refresh failed, clear session
        await _sessionService.clearSession();
      }
    }

    handler.next(err);
  }
}

/// Factory for creating configured Dio instance
class DioFactory {
  static Dio create({String? baseUrl}) {
    final dio = Dio();

    if (baseUrl != null) {
      dio.options.baseUrl = baseUrl;
    }

    // Add auth interceptor
    dio.interceptors.add(AuthInterceptor());

    // Add logging interceptor in debug mode
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('🌐 $obj'),
      ),
    );

    dio.options.connectTimeout = const Duration(seconds: 60);
    dio.options.receiveTimeout = const Duration(seconds: 60);
    dio.options.sendTimeout = const Duration(seconds: 60);

    return dio;
  }
}
