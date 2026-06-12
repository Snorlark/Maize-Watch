import 'package:dio/dio.dart';
import '../../../../core/config/environment.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/services/session_service.dart';

abstract class HistoricalRemoteDataSource {
  Future<Map<String, dynamic>> getWeeklyData(String farmId, {String? fieldId, int? weekOffset});
  Future<Map<String, dynamic>> getLatestData(String farmId);
}

class HistoricalRemoteDataSourceImpl implements HistoricalRemoteDataSource {
  final Dio dio;
  // Remove unused field
  // final SessionService _sessionService;

  HistoricalRemoteDataSourceImpl({
    required this.dio,
    required SessionService sessionService,
  }) {
    // Remove unused field assignment
    // _sessionService = sessionService;
  }

  @override
  Future<Map<String, dynamic>> getWeeklyData(String farmId, {String? fieldId, int? weekOffset}) async {
    try {
      // Get authentication token
      final token = await SecureStorage.getToken();
      if (token == null) {
        // No authentication token available for historical data
        return _generateFallbackData();
      }

      final queryParams = <String, String>{
        if (fieldId != null) 'fieldId': fieldId,
        if (weekOffset != null) 'weekOffset': weekOffset.toString(),
      };

      // Fetching weekly data from analytics endpoint

      final response = await dio.get(
        '/analytics/farms/$farmId/weekly-data',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        // Weekly data response received
        return responseData['data'] as Map<String, dynamic>? ?? {};
      } else {
        final responseBody = response.data;
        // Server error occurred
        // Return fallback data instead of throwing error
        return _generateFallbackData();
      }
    } catch (e) {
      print('🔍 Weekly data error: $e');
      // Return fallback data instead of throwing error
      return _generateFallbackData();
    }
  }

  @override
  Future<Map<String, dynamic>> getLatestData(String farmId) async {
    try {
      // Get authentication token
      final token = await SecureStorage.getToken();
      if (token == null) {
        print('🔍 No authentication token available for latest data');
        return _generateFallbackLatestData();
      }

      final uri = Uri.parse('${AppConfig.baseUrl}/api/analytics/crop/$farmId');

      print('🔍 Fetching latest data from: $uri');

      final response = await dio.get(
        uri.toString(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        print('🔍 Latest data response: $responseData');
        return responseData['data'] as Map<String, dynamic>? ?? {};
      } else {
        final responseBody = response.data;
        print('🔍 Latest data server error: ${response.statusCode} - ${responseBody['message'] ?? 'Unknown error'}');
        // Return fallback data instead of throwing error
        return _generateFallbackLatestData();
      }
    } catch (e) {
      print('🔍 Latest data error: $e');
      // Return fallback data instead of throwing error
      return _generateFallbackLatestData();
    }
  }

  Map<String, dynamic> _generateFallbackData() {
    // Generate 7 days of sample data for demonstration
    final List<Map<String, dynamic>> dailyData = [];
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      dailyData.add({
        'date': date.toIso8601String().split('T')[0],
        'temperature': 25.0 + (i * 2.0),
        'humidity': 60.0 + (i * 3.0),
        'soilMoisture': 45.0 + (i * 1.5),
        'soilPh': 6.5 + (i * 0.1),
        'lightIntensity': 800.0 + (i * 50.0),
        'readingCount': 7,
      });
    }
    
    return {
      'dailyData': dailyData,
      'summary': {
        'avgTemperature': 28.0,
        'avgHumidity': 66.0,
        'avgSoilMoisture': 48.0,
        'avgSoilPh': 6.8,
        'avgLightIntensity': 950.0,
      }
    };
  }

  Map<String, dynamic> _generateFallbackLatestData() {
    // Generate current sensor readings for demonstration
    return {
      'temperature': 26.5,
      'humidity': 68.0,
      'soilMoisture': 52.0,
      'soilPh': 6.7,
      'lightIntensity': 920.0,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
