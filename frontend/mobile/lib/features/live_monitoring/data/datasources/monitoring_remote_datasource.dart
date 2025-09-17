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
      // Get user farms first to get farm IDs
      final farmsResponse = await dio.get('/api/farms');

      if (farmsResponse.data['success'] != true) {
        throw ServerException('Failed to get farms');
      }

      final farms = farmsResponse.data['data'] as List;
      if (farms.isEmpty) {
        return [];
      }

      // Get latest readings for the first farm (or all farms)
      final farmId = farms.first['_id'] as String;
      final response = await dio.get('/api/farms/$farmId/readings/latest');

      if (response.data['success'] != true) {
        throw ServerException(
          response.data['message'] ?? 'Failed to get latest readings',
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
        '/api/farms/$farmId/readings/historical',
        queryParameters: {'days': days},
      );

      if (response.data['success'] != true) {
        throw ServerException(
          response.data['message'] ?? 'Failed to get historical readings',
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
        '/api/sensors/$sensorId/readings',
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
