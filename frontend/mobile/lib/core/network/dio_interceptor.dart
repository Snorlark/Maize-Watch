import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';

/// Dio interceptor for handling authentication tokens automatically
/// Follows clean architecture principles for network layer
class AuthInterceptor extends Interceptor {
  AuthInterceptor();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add access token to headers if available
    final accessToken = await SecureStorage.getToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    // Ensure content type is set
    if (options.headers['Content-Type'] == null) {
      options.headers['Content-Type'] = 'application/json';
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 unauthorized errors by attempting token refresh
    if (err.response?.statusCode == 401) {
      try {
        final refreshToken = await SecureStorage.getRefreshToken();
        if (refreshToken != null) {
          // Attempt to refresh token
          final dio = Dio();
          final response = await dio.post(
            '${err.requestOptions.baseUrl}/api/auth/refresh',
            data: {'refreshToken': refreshToken},
          );

          if (response.statusCode == 200 && response.data['success'] == true) {
            final newAccessToken = response.data['token'];
            await SecureStorage.storeTokens(newAccessToken, refreshToken);

            // Retry the original request with new token
            final retryOptions = err.requestOptions;
            retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';

            final retryResponse = await dio.fetch(retryOptions);
            return handler.resolve(retryResponse);
          }
        }

        // If refresh fails, clear tokens and let the error through
        await SecureStorage.clearUserSession();
      } catch (e) {
        // If refresh fails, clear tokens
        await SecureStorage.clearUserSession();
      }
    }

    super.onError(err, handler);
  }
}

/// Factory for creating configured Dio instance
class DioFactory {
  static Dio create({
    String? baseUrl,
  }) {
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

    // Set default timeout
    dio.options.connectTimeout = const Duration(seconds: 20);
    dio.options.receiveTimeout = const Duration(seconds: 20);

    return dio;
  }
}
