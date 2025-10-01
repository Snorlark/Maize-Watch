import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/environment.dart';
import '../storage/secure_storage.dart';

class TwoFactorAuthService {
  static final TwoFactorAuthService _instance = TwoFactorAuthService._internal();
  factory TwoFactorAuthService() => _instance;
  TwoFactorAuthService._internal();

  final Dio _dio = Dio();

  /// Send 2FA code to contact number
  Future<Map<String, dynamic>> sendVerificationCode(String contactNumber) async {
    try {
      final response = await _dio.post(
        '${AppConfig.baseUrl}/api/auth/send-verification-code',
        data: {
          'contactNumber': contactNumber,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Verification code sent successfully',
          'sid': response.data['sid'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to send verification code',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleDioError(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: $e',
      };
    }
  }

  /// Verify 2FA code
  Future<Map<String, dynamic>> verifyCode(String contactNumber, String code) async {
    try {
      final response = await _dio.post(
        '${AppConfig.baseUrl}/api/auth/verify-code',
        data: {
          'contactNumber': contactNumber,
          'code': code,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Code verified successfully',
          'verified': response.data['verified'] ?? false,
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to verify code',
          'verified': false,
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleDioError(e),
        'verified': false,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: $e',
        'verified': false,
      };
    }
  }

  /// Send password reset code
  Future<Map<String, dynamic>> sendPasswordResetCode(String contactNumber) async {
    try {
      final response = await _dio.post(
        '${AppConfig.baseUrl}/api/auth/send-password-reset-code',
        data: {
          'contactNumber': contactNumber,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Password reset code sent successfully',
          'sid': response.data['sid'],
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to send password reset code',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleDioError(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: $e',
      };
    }
  }

  /// Reset password with verification code
  Future<Map<String, dynamic>> resetPasswordWithCode({
    required String contactNumber,
    required String code,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        '${AppConfig.baseUrl}/api/auth/reset-password-with-code',
        data: {
          'contactNumber': contactNumber,
          'code': code,
          'newPassword': newPassword,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Password reset successfully',
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to reset password',
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleDioError(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: $e',
      };
    }
  }

  /// Store verification session data
  Future<void> storeVerificationSession({
    required String contactNumber,
    required String sessionId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('verification_contact_number', contactNumber);
    await prefs.setString('verification_session_id', sessionId);
    await prefs.setInt('verification_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  /// Get verification session data
  Future<Map<String, String?>> getVerificationSession() async {
    final prefs = await SharedPreferences.getInstance();
    final contactNumber = prefs.getString('verification_contact_number');
    final sessionId = prefs.getString('verification_session_id');
    final timestamp = prefs.getInt('verification_timestamp');
    
    // Check if session is still valid (within 10 minutes)
    if (timestamp != null) {
      final sessionTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      if (now.difference(sessionTime).inMinutes > 10) {
        // Session expired, clear data
        await clearVerificationSession();
        return {'contactNumber': null, 'sessionId': null};
      }
    }
    
    return {
      'contactNumber': contactNumber,
      'sessionId': sessionId,
    };
  }

  /// Clear verification session data
  Future<void> clearVerificationSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('verification_contact_number');
    await prefs.remove('verification_session_id');
    await prefs.remove('verification_timestamp');
  }

  String _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timed out. Please try again.';
    } else if (e.response != null) {
      final responseData = e.response!.data;
      if (responseData is Map<String, dynamic>) {
        return responseData['message'] ?? 'An error occurred. Please try again.';
      }
    }
    return 'Network error. Please check your connection and try again.';
  }
}
