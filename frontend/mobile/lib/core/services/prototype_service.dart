import 'package:dio/dio.dart';
import 'package:mobile/core/config/environment.dart';

class PrototypeService {
  static final Dio _dio = Dio();

  /// Validate if a prototype ID exists and is available
  static Future<Map<String, dynamic>> validatePrototype(String prototypeId) async {
    try {
      final response = await _dio.post(
        '${AppConfig.baseUrl}/api/prototypes/validate',
        data: {'prototype_id': prototypeId},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to validate prototype: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return {
          'success': false,
          'message': 'Prototype ID not found',
          'available': false,
        };
      } else if (e.response?.statusCode == 400) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Invalid prototype ID',
          'available': false,
        };
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Register a prototype ID to the current user
  static Future<Map<String, dynamic>> registerPrototype(String prototypeId, String token) async {
    try {
      final response = await _dio.post(
        '${AppConfig.baseUrl}/api/prototypes/register',
        data: {'prototype_id': prototypeId},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to register prototype: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        return {
          'success': false,
          'message': e.response?.data['message'] ?? 'Prototype registration failed',
        };
      } else if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get available prototypes
  static Future<Map<String, dynamic>> getAvailablePrototypes() async {
    try {
      final response = await _dio.get(
        '${AppConfig.baseUrl}/api/prototypes/available',
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to get available prototypes: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  /// Get user's registered prototypes
  static Future<Map<String, dynamic>> getUserPrototypes(String token) async {
    try {
      final response = await _dio.get(
        '${AppConfig.baseUrl}/api/prototypes/user',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to get user prototypes: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication required');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
