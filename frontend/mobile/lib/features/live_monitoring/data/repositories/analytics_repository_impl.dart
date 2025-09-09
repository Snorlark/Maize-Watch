import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../datasources/analytics_remote_data_source.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../../domain/entities/analytics_entities.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource remoteDataSource;

  AnalyticsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<CropConditionModel> getCropCondition(
    String farmId, {
    String? fieldId,
  }) async {
    try {
      return await remoteDataSource.getCropCondition(farmId, fieldId: fieldId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to get crop condition: ${e.toString()}');
    }
  }

  @override
  Future<MetricsModel> getCurrentMetrics(
    String farmId, {
    String? fieldId,
  }) async {
    try {
      final data = await remoteDataSource.getCurrentMetrics(
        farmId,
        fieldId: fieldId,
      );
      return MetricsModel.fromJson(data);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to get current metrics: ${e.toString()}');
    }
  }

  @override
  Future<WeeklyDataModel> getWeeklyHistoricalData(
    String farmId, {
    String? fieldId,
  }) async {
    try {
      final data = await remoteDataSource.getWeeklyHistoricalData(
        farmId,
        fieldId: fieldId,
      );
      return WeeklyDataModel.fromJson(data);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to get weekly data: ${e.toString()}');
    }
  }

  @override
  Future<GrowthStageAnalysisModel> getGrowthStageAnalysis(
    String farmId, {
    String? fieldId,
  }) async {
    try {
      return await remoteDataSource.getGrowthStageAnalysis(
        farmId,
        fieldId: fieldId,
      );
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message);
    } catch (e) {
      throw ServerFailure(
        'Failed to get growth stage analysis: ${e.toString()}',
      );
    }
  }
}
