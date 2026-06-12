import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/sensor_reading_model.dart';

abstract class MonitoringRemoteDataSource {
  Future<List<SensorReadingModel>> getLatestReadings();
  Future<List<SensorReadingModel>> getHistoricalReadings(
    String farmId,
    int days,
  );
  Future<List<SensorReadingModel>> getSensorReadings(
    String sensorId, {
    int? page,
    int? limit,
  });
}

class MonitoringRemoteDataSourceImpl implements MonitoringRemoteDataSource {
  final Dio dio;

  MonitoringRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<SensorReadingModel>> getLatestReadings() async {
    try {
      print('🔍 MonitoringDataSource: Getting latest readings from analytics...');
      
      // Get user farms first to get farm IDs
      final farmsResponse = await dio.get('/farms');
      print('🔍 MonitoringDataSource: Farms response: ${farmsResponse.data}');

      if (farmsResponse.data['success'] != true) {
        throw ServerException('Failed to get farms');
      }

      final responseData = farmsResponse.data['data'];
      final farms = (responseData is Map ? responseData['farms'] : responseData) as List;
      if (farms.isEmpty) {
        print('🔍 MonitoringDataSource: No farms found');
        return [];
      }

      // Get analytics data for the first farm (which contains field-specific sensor data)
      final farmId = farms.first['_id'] as String;
      print('🔍 MonitoringDataSource: Using farm ID: $farmId');
      
      final response = await dio.get('/analytics/farms/$farmId/complete');
      print('🔍 MonitoringDataSource: Analytics response received');

      if (response.data['success'] != true) {
        throw ServerException(
          response.data['message'] ?? 'Failed to get analytics data',
        );
      }

      final analyticsData = response.data['data'] as Map<String, dynamic>;
      final descriptive = analyticsData['descriptive'] as Map<String, dynamic>;
      final fieldAnalyses = descriptive['field_analyses'] as Map<String, dynamic>;
      
      print('🔍 MonitoringDataSource: Found ${fieldAnalyses.length} field analyses');
      
      // Convert field analyses to sensor readings
      final sensorReadings = <SensorReadingModel>[];
      
      fieldAnalyses.forEach((fieldName, fieldData) {
        final fieldAnalysis = fieldData as Map<String, dynamic>;
        final weatherSummary = fieldAnalysis['weather_summary'] as Map<String, dynamic>;
        
        // Create a sensor reading from the field-specific data
        final sensorReading = SensorReadingModel(
          id: '${fieldName}_${DateTime.now().millisecondsSinceEpoch}',
          sensorId: fieldName, // Use fieldName as sensorId
          farmId: farmId,
          temperature: (weatherSummary['avg_temp'] as num?)?.toDouble() ?? 0.0,
          humidity: (weatherSummary['avg_humidity'] as num?)?.toDouble() ?? 0.0,
          soilMoisture: (weatherSummary['avg_soil_moisture'] as num?)?.toDouble() ?? 0.0,
          pH: (weatherSummary['avg_soil_ph'] as num?)?.toDouble() ?? 0.0, // Use pH instead of soilPh
          lightIntensity: (weatherSummary['avg_light_intensity'] as num?)?.toDouble() ?? 0.0,
          timestamp: DateTime.now(),
        );
        
        print('🔍 MonitoringDataSource: Field $fieldName - Temp: ${sensorReading.temperature}°C, Humidity: ${sensorReading.humidity}%, Soil Moisture: ${sensorReading.soilMoisture}%');
        sensorReadings.add(sensorReading);
      });
      
      return sensorReadings;
    } on DioException catch (e) {
      print('🔍 MonitoringDataSource: DioException: ${e.message}');
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Session expired');
      }
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      print('🔍 MonitoringDataSource: Exception: $e');
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException('Failed to get latest readings');
    }
  }

  @override
  Future<List<SensorReadingModel>> getHistoricalReadings(
    String farmId,
    int days,
  ) async {
    try {
      final response = await dio.get(
        '/farms/$farmId/readings/historical',
        queryParameters: {'days': days},
      );

      if (response.data['success'] != true) {
        throw ServerException(
          response.data['message'] ?? 'Failed to get historical readings',
        );
      }

      final data = response.data['data'] as Map<String, dynamic>;
      final readings = data['readings'] as List;
      return readings.map((json) => SensorReadingModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Session expired');
      }
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException('Failed to get historical readings');
    }
  }

  @override
  Future<List<SensorReadingModel>> getSensorReadings(
    String sensorId, {
    int? page,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;

      final response = await dio.get(
        '/sensors/$sensorId/readings',
        queryParameters: queryParams,
      );

      if (response.data['success'] != true) {
        throw ServerException(
          response.data['message'] ?? 'Failed to get sensor readings',
        );
      }

      final readings = response.data['data'] as List;
      return readings.map((json) => SensorReadingModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Session expired');
      }
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException('Failed to get sensor readings');
    }
  }
}
