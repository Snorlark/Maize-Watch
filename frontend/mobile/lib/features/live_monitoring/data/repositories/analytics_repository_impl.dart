import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../datasources/analytics_remote_data_source.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../../domain/entities/analytics_entities.dart';
import '../models/analytics_model.dart' as data_models;

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRemoteDataSource remoteDataSource;

  AnalyticsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<CropConditionModel> getCropCondition(
    String farmId, {
    String? fieldId,
  }) async {
    try {
      final model = await remoteDataSource.getCropCondition(farmId, fieldId: fieldId);
      // Convert from data model to domain entity
      return CropConditionModel(
        status: model.status,
        message: model.message,
        color: model.color,
        icon: model.icon,
      );
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
      final model = data_models.MetricsModel.fromJson(data);
      // Convert from data model to domain entity
      return MetricsModel(
        soilPh: model.soilPh,
        soilMoisture: model.soilMoisture,
        temperature: model.temperature,
        humidity: model.humidity,
        lightIntensity: model.lightIntensity,
        timestamp: model.timestamp,
      );
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
      final model = data_models.WeeklyDataModel.fromJson(data);
      // Convert from data model to domain entity
      return WeeklyDataModel(
        dailyData: model.dailyData.map((d) => DailyDataModel(
          date: d.date,
          temperature: d.temperature,
          humidity: d.humidity,
          soilMoisture: d.soilMoisture,
          soilPh: d.soilPh,
          lightIntensity: d.lightIntensity,
        )).toList(),
        summary: model.summary,
      );
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
      final model = await remoteDataSource.getGrowthStageAnalysis(
        farmId,
        fieldId: fieldId,
      );
      // Convert from data model to domain entity
      return GrowthStageAnalysisModel(
        currentStage: model.currentStage,
        progressPercentage: model.progressPercentage,
        stageDescription: model.stageDescription,
        expectedHarvest: model.expectedHarvest,
        stageInfo: model.stageInfo.map((s) => GrowthStageInfo(
          stage: s.stage,
          name: s.name,
          description: s.description,
          days: s.days,
        )).toList(),
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

  @override
  Future<Map<String, dynamic>> getCompleteAnalytics(
    String farmId, {
    String? fieldId,
  }) async {
    try {
      return await remoteDataSource.getCompleteAnalytics(farmId, fieldId: fieldId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message);
    } catch (e) {
      throw ServerFailure('Failed to get complete analytics: ${e.toString()}');
    }
  }
}
