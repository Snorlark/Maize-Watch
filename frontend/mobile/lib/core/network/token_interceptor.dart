import 'package:dio/dio.dart';
import '../services/session_service.dart';

class TokenInterceptor extends Interceptor {
  final SessionService _sessionService = SessionService();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip token addition for auth endpoints
    if (options.path.contains('/auth/login') || 
        options.path.contains('/auth/register') ||
        options.path.contains('/auth/refresh')) {
      handler.next(options);
      return;
    }

    // Get valid access token
    final token = await _sessionService.getValidAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized errors
    if (err.response?.statusCode == 401) {
      try {
        // Attempt to refresh token
        final refreshSuccess = await _sessionService.refreshAccessToken();
        
        if (refreshSuccess) {
          // Retry the original request with new token
          final token = await _sessionService.getValidAccessToken();
          if (token != null) {
            err.requestOptions.headers['Authorization'] = 'Bearer $token';
            
            // Retry the request
            final dio = Dio();
            final response = await dio.fetch(err.requestOptions);
            handler.resolve(response);
            return;
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
