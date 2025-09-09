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
      final results = await Future.wait([
        repository.getCropCondition(event.farmId, fieldId: event.fieldId),
        repository.getCurrentMetrics(event.farmId, fieldId: event.fieldId),
        repository.getWeeklyHistoricalData(
          event.farmId,
          fieldId: event.fieldId,
        ),
        repository.getGrowthStageAnalysis(event.farmId, fieldId: event.fieldId),
      ]);

      final loaded = AnalyticsLoaded(
        cropCondition: results[0] as CropConditionModel,
        currentMetrics: results[1] as MetricsModel,
        weeklyData: results[2] as WeeklyDataModel,
        growthStageAnalysis: results[3] as GrowthStageAnalysisModel,
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
