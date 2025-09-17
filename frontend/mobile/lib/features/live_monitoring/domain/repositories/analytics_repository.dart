import '../entities/analytics_entities.dart';

abstract class AnalyticsRepository {
  Future<CropConditionModel> getCropCondition(String farmId, {String? fieldId});
  Future<MetricsModel> getCurrentMetrics(String farmId, {String? fieldId});
  Future<WeeklyDataModel> getWeeklyHistoricalData(String farmId, {String? fieldId});
  Future<GrowthStageAnalysisModel> getGrowthStageAnalysis(String farmId, {String? fieldId});
}
