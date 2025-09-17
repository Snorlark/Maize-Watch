import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/analytics_model.dart';

abstract class AnalyticsRemoteDataSource {
  Future<CropConditionModel> getCropCondition(String farmId, {String? fieldId});
  Future<Map<String, dynamic>> getCurrentMetrics(
    String farmId, {
    String? fieldId,
  });
  Future<Map<String, dynamic>> getWeeklyHistoricalData(
    String farmId, {
    String? fieldId,
  });
  Future<GrowthStageAnalysisModel> getGrowthStageAnalysis(
    String farmId, {
    String? fieldId,
  });
}

class AnalyticsRemoteDataSourceImpl implements AnalyticsRemoteDataSource {
  final Dio dio;
  final SecureStorage secureStorage;

  AnalyticsRemoteDataSourceImpl({
    required this.dio,
    required this.secureStorage,
  });

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      throw UnauthorizedException('Authentication token not found');
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  @override
  Future<CropConditionModel> getCropCondition(
    String farmId, {
    String? fieldId,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await dio.get(
        '/api/analytics/crop-status/$farmId',
        queryParameters: fieldId != null ? {'fieldId': fieldId} : null,
        options: Options(headers: headers),
      );

      if (response.data['success'] == true) {
        return CropConditionModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to get crop condition',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Session expired');
      }
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException('Failed to get crop condition');
    }
  }

  @override
  Future<Map<String, dynamic>> getCurrentMetrics(
    String farmId, {
    String? fieldId,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await dio.get(
        '/api/analytics/crop/$farmId',
        queryParameters: fieldId != null ? {'fieldId': fieldId} : null,
        options: Options(headers: headers),
      );

      if (response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to get current metrics',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Session expired');
      }
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException('Failed to get current metrics');
    }
  }

  @override
  Future<Map<String, dynamic>> getWeeklyHistoricalData(
    String farmId, {
    String? fieldId,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await dio.get(
        '/api/analytics/farms/$farmId/weekly-data',
        queryParameters: fieldId != null ? {'fieldId': fieldId} : null,
        options: Options(headers: headers),
      );

      if (response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to get historical data',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Session expired');
      }
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException('Failed to get historical data');
    }
  }

  @override
  Future<GrowthStageAnalysisModel> getGrowthStageAnalysis(
    String farmId, {
    String? fieldId,
  }) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await dio.get(
        '/api/analytics/farms/$farmId/growth-stage',
        queryParameters: fieldId != null ? {'fieldId': fieldId} : null,
        options: Options(headers: headers),
      );

      if (response.data['success'] == true) {
        return GrowthStageAnalysisModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Failed to get growth stage analysis',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException('Session expired');
      }
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      if (e is ServerException || e is UnauthorizedException) rethrow;
      throw ServerException('Failed to get growth stage analysis');
    }
  }
}
