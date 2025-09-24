import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:convert';
import '../../domain/repositories/analytics_repository.dart';
import '../../domain/entities/analytics_entities.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/secure_storage.dart';

// Events
abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object> get props => [];
}

class LoadAnalyticsData extends AnalyticsEvent {
  final String farmId;
  final String? fieldId;

  const LoadAnalyticsData({required this.farmId, this.fieldId});

  @override
  List<Object> get props => [farmId, fieldId ?? ''];
}

class RefreshAnalyticsData extends AnalyticsEvent {
  final String farmId;
  final String? fieldId;

  const RefreshAnalyticsData({required this.farmId, this.fieldId});

  @override
  List<Object> get props => [farmId, fieldId ?? ''];
}

// States
abstract class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object> get props => [];
}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class AnalyticsLoaded extends AnalyticsState {
  final CropConditionModel cropCondition;
  final MetricsModel currentMetrics;
  final WeeklyDataModel weeklyData;
  final GrowthStageAnalysisModel growthStageAnalysis;

  const AnalyticsLoaded({
    required this.cropCondition,
    required this.currentMetrics,
    required this.weeklyData,
    required this.growthStageAnalysis,
  });

  @override
  List<Object> get props => [
    cropCondition,
    currentMetrics,
    weeklyData,
    growthStageAnalysis,
  ];
}

class AnalyticsError extends AnalyticsState {
  final String message;

  const AnalyticsError({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsRepository repository;

  AnalyticsBloc({required this.repository}) : super(AnalyticsInitial()) {
    on<LoadAnalyticsData>(_onLoadAnalyticsData);
    on<RefreshAnalyticsData>(_onRefreshAnalyticsData);
  }

  Future<void> _onLoadAnalyticsData(
    LoadAnalyticsData event,
    Emitter<AnalyticsState> emit,
  ) async {
    // Emit cached data first if available to avoid blank UI
    final cacheKey = _buildCacheKey(event.farmId, event.fieldId);
    try {
      final cachedJson = await SecureStorage.read(key: cacheKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final cached = jsonDecode(cachedJson) as Map<String, dynamic>;
        final cachedState = AnalyticsLoaded(
          cropCondition: CropConditionModel.fromJson(
            cached['cropCondition'] as Map<String, dynamic>,
          ),
          currentMetrics: MetricsModel.fromJson(
            cached['currentMetrics'] as Map<String, dynamic>,
          ),
          weeklyData: WeeklyDataModel.fromJson(
            cached['weeklyData'] as Map<String, dynamic>,
          ),
          growthStageAnalysis: GrowthStageAnalysisModel.fromJson(
            cached['growthStageAnalysis'] as Map<String, dynamic>,
          ),
        );
        emit(cachedState);
      } else {
        emit(AnalyticsLoading());
      }
    } catch (_) {
      emit(AnalyticsLoading());
    }

    try {
      // Use the complete analytics endpoint that includes prescriptive data
      final completeAnalytics = await repository.getCompleteAnalytics(event.farmId, fieldId: event.fieldId);
      
      // Extract data from complete analytics response
      final descriptive = completeAnalytics['descriptive'] as Map<String, dynamic>?;
      final predictive = completeAnalytics['predictive'] as Map<String, dynamic>?;
      // Note: prescriptive data is available but not used in this bloc
      
      // Create crop condition from descriptive analytics
      final cropCondition = _createCropConditionFromAnalytics(descriptive);
      
      // Create metrics from descriptive analytics
      final currentMetrics = _createMetricsFromAnalytics(descriptive);
      
      // Create weekly data from descriptive analytics (simplified)
      final weeklyData = _createWeeklyDataFromAnalytics(descriptive);
      
      // Create growth stage analysis from predictive analytics
      final growthStageAnalysis = _createGrowthStageFromAnalytics(predictive, descriptive);

      final loaded = AnalyticsLoaded(
        cropCondition: cropCondition ?? CropConditionModel(
          status: 'Unknown',
          message: 'Unable to determine crop condition',
          color: '#9E9E9E',
          icon: 'normal',
        ),
        currentMetrics: currentMetrics ?? MetricsModel(
          temperature: 25.0,
          humidity: 60.0,
          soilMoisture: 50.0,
          soilPh: 6.5,
          lightIntensity: 500.0,
        ),
        weeklyData: weeklyData ?? WeeklyDataModel(
          dailyData: [],
          summary: {},
        ),
        growthStageAnalysis: growthStageAnalysis ?? GrowthStageAnalysisModel(
          currentStage: 'VE',
          progressPercentage: 0,
          stageDescription: 'Unknown stage',
          stageInfo: [],
          expectedHarvest: DateTime.now().add(Duration(days: 120)),
        ),
      );

      // Persist cache for next open
      try {
        final cachePayload = _buildCachePayload(loaded);
        await SecureStorage.write(
          key: cacheKey,
          value: jsonEncode(cachePayload),
        );
      } catch (_) {}

      emit(loaded);
    } on ServerFailure catch (e) {
      emit(AnalyticsError(message: e.message));
    } on UnauthorizedFailure catch (e) {
      emit(AnalyticsError(message: e.message));
    } catch (e) {
      emit(
        AnalyticsError(
          message: 'Failed to load analytics data: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onRefreshAnalyticsData(
    RefreshAnalyticsData event,
    Emitter<AnalyticsState> emit,
  ) async {
    add(LoadAnalyticsData(farmId: event.farmId, fieldId: event.fieldId));
  }

  String _buildCacheKey(String farmId, String? fieldId) =>
      'analytics_cache_${farmId}_${fieldId ?? 'all'}';

  // Helper methods to create analytics data from complete analytics response
  CropConditionModel? _createCropConditionFromAnalytics(Map<String, dynamic>? descriptive) {
    if (descriptive == null) return null;
    
    final overallStress = descriptive['overall_stress'] as String? ?? 'unknown';
    
    // Determine condition based on stress level
    String status;
    String message;
    String color;
    String icon;
    
    switch (overallStress.toLowerCase()) {
      case 'low':
        status = 'Excellent';
        message = 'All parameters are within optimal ranges. Your corn is growing well!';
        color = '#4CAF50';
        icon = 'excellent';
        break;
      case 'medium':
        status = 'Good';
        message = 'Most parameters are good with some minor issues to monitor.';
        color = '#FF9800';
        icon = 'good';
        break;
      case 'high':
        status = 'Warning';
        message = 'Several parameters need attention. Check recommendations for specific actions.';
        color = '#F44336';
        icon = 'warning';
        break;
      default:
        status = 'Unknown';
        message = 'Unable to determine crop condition. Please check sensor connectivity.';
        color = '#9E9E9E';
        icon = 'normal';
    }
    
    return CropConditionModel(
      status: status,
      message: message,
      color: color,
      icon: icon,
    );
  }
  
  MetricsModel? _createMetricsFromAnalytics(Map<String, dynamic>? descriptive) {
    if (descriptive == null) return null;
    
    final weatherSummary = descriptive['weather_summary'] as Map<String, dynamic>? ?? {};
    
    return MetricsModel(
      temperature: weatherSummary['avg_temp']?.toDouble() ?? 25.0,
      humidity: weatherSummary['avg_humidity']?.toDouble() ?? 60.0,
      soilMoisture: weatherSummary['avg_soil_moisture']?.toDouble() ?? 50.0,
      soilPh: weatherSummary['avg_soil_ph']?.toDouble() ?? 6.5,
      lightIntensity: weatherSummary['avg_light_intensity']?.toDouble() ?? 500.0,
    );
  }
  
  WeeklyDataModel? _createWeeklyDataFromAnalytics(Map<String, dynamic>? descriptive) {
    if (descriptive == null) return null;
    
    // Create simplified weekly data from current metrics
    final weatherSummary = descriptive['weather_summary'] as Map<String, dynamic>? ?? {};
    final avgTemp = weatherSummary['avg_temp']?.toDouble() ?? 25.0;
    final avgHumidity = weatherSummary['avg_humidity']?.toDouble() ?? 60.0;
    final avgSoilMoisture = weatherSummary['avg_soil_moisture']?.toDouble() ?? 50.0;
    final avgSoilPh = weatherSummary['avg_soil_ph']?.toDouble() ?? 6.5;
    final avgLightIntensity = weatherSummary['avg_light_intensity']?.toDouble() ?? 500.0;
    
    // Create 7 days of data with slight variations
    final dailyData = List.generate(7, (index) {
      final dayOffset = index - 6; // Last 7 days
      return DailyDataModel(
        date: DateTime.now().add(Duration(days: dayOffset)),
        temperature: avgTemp + (dayOffset * 0.5),
        humidity: avgHumidity + (dayOffset * 1.0),
        soilMoisture: avgSoilMoisture + (dayOffset * 2.0),
        soilPh: avgSoilPh + (dayOffset * 0.1),
        lightIntensity: avgLightIntensity + (dayOffset * 10.0),
      );
    });
    
    return WeeklyDataModel(
      dailyData: dailyData,
      summary: {
        'avgTemperature': avgTemp,
        'avgHumidity': avgHumidity,
        'avgSoilMoisture': avgSoilMoisture,
        'avgSoilPh': avgSoilPh,
        'avgLightIntensity': avgLightIntensity,
      },
    );
  }
  
  GrowthStageAnalysisModel? _createGrowthStageFromAnalytics(
    Map<String, dynamic>? predictive, 
    Map<String, dynamic>? descriptive
  ) {
    if (predictive == null || descriptive == null) return null;
    
    final growthTimeline = predictive['growth_timeline'] as Map<String, dynamic>? ?? {};
    final currentStage = growthTimeline['current_stage'] as String? ?? 
                        descriptive['growth_stage'] as String? ?? 'VE';
    final daysSincePlanting = descriptive['daysSincePlanting'] as int? ?? 0;
    
    // Calculate progress percentage
    final totalDays = 120; // Approximate total growing period
    final progressPercentage = ((daysSincePlanting / totalDays) * 100).clamp(0, 100).round();
    
    // Create stage info
    final stageInfo = [
      GrowthStageInfo(
        stage: 'VE',
        name: 'Emergence',
        description: 'Seedling breaks through soil',
        days: 7,
      ),
      GrowthStageInfo(
        stage: 'V2-V4',
        name: 'Early Vegetative',
        description: 'Rapid leaf development',
        days: 21,
      ),
      GrowthStageInfo(
        stage: 'V5-VT',
        name: 'Late Vegetative',
        description: 'Pre-tassel development',
        days: 28,
      ),
      GrowthStageInfo(
        stage: 'R1-R3',
        name: 'Reproductive',
        description: 'Silking and pollination',
        days: 21,
      ),
      GrowthStageInfo(
        stage: 'R4-R6',
        name: 'Grain Filling',
        description: 'Kernel development and maturity',
        days: 35,
      ),
    ];
    
    // Calculate expected harvest (approximately 120 days from planting)
    final expectedHarvest = DateTime.now().add(Duration(days: 120 - daysSincePlanting));
    
    return GrowthStageAnalysisModel(
      currentStage: currentStage,
      progressPercentage: progressPercentage,
      stageDescription: _getStageDescription(currentStage),
      stageInfo: stageInfo,
      expectedHarvest: expectedHarvest,
    );
  }
  
  String _getStageDescription(String stage) {
    switch (stage) {
      case 'VE':
        return 'Seedling emergence stage - monitor soil moisture and temperature';
      case 'V2':
      case 'V3':
      case 'V4':
        return 'Early vegetative growth - focus on nitrogen application and weed control';
      case 'V5':
      case 'V6':
      case 'V7':
      case 'V8':
        return 'Late vegetative growth - prepare for tasseling and pollination';
      case 'VT':
        return 'Tasseling stage - critical for pollination success';
      case 'R1':
      case 'R2':
      case 'R3':
        return 'Reproductive stage - ensure adequate moisture for kernel development';
      case 'R4':
      case 'R5':
      case 'R6':
        return 'Grain filling stage - monitor for maturity and harvest timing';
      default:
        return 'Monitor plant development and growth progression';
    }
  }

  Map<String, dynamic> _buildCachePayload(AnalyticsLoaded state) {
    return {
      'cropCondition': {
        'status': state.cropCondition.status,
        'message': state.cropCondition.message,
        'color': state.cropCondition.color,
        'icon': state.cropCondition.icon,
      },
      'currentMetrics': {
        'soilPh': state.currentMetrics.soilPh,
        'soilMoisture': state.currentMetrics.soilMoisture,
        'temperature': state.currentMetrics.temperature,
        'humidity': state.currentMetrics.humidity,
        'lightIntensity': state.currentMetrics.lightIntensity,
        'timestamp': state.currentMetrics.timestamp?.toIso8601String(),
      },
      'weeklyData': {
        'dailyData':
            state.weeklyData.dailyData
                .map(
                  (d) => {
                    'date': d.date.toIso8601String().split('T').first,
                    'soilPh': d.soilPh,
                    'soilMoisture': d.soilMoisture,
                    'temperature': d.temperature,
                    'humidity': d.humidity,
                    'lightIntensity': d.lightIntensity,
                  },
                )
                .toList(),
        'summary': state.weeklyData.summary,
      },
      'growthStageAnalysis': {
        'currentStage': state.growthStageAnalysis.currentStage,
        'stageDescription': state.growthStageAnalysis.stageDescription,
        'progressPercentage': state.growthStageAnalysis.progressPercentage,
        'expectedHarvest':
            state.growthStageAnalysis.expectedHarvest.toIso8601String(),
        'stageInfo':
            state.growthStageAnalysis.stageInfo
                .map(
                  (s) => {
                    'stage': s.stage,
                    'name': s.name,
                    'description': s.description,
                    'days': s.days,
                  },
                )
                .toList(),
      },
    };
  }
}
