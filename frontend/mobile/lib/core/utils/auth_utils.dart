import '../storage/secure_storage.dart';

class AuthUtils {
  /// Clear all authentication data and force re-login
  static Future<void> clearExpiredSession() async {
    await SecureStorage.clearUserSession();
  }

  /// Check if the current session is likely expired based on error messages
  static bool isAuthenticationError(String errorMessage) {
    return errorMessage.contains('jwt expired') ||
           errorMessage.contains('TokenExpiredError') ||
           errorMessage.contains('Authentication expired') ||
           errorMessage.contains('Please log in again');
  }

  /// Handle authentication errors by clearing session
  static Future<void> handleAuthenticationError() async {
    await clearExpiredSession();
  }
}
