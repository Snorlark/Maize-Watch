// features/live_monitoring/presentation/bloc/monitoring_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/sensor_reading.dart';
import '../../domain/entities/weather_data.dart';
import '../../domain/usecases/get_current_weather.dart';
import '../../domain/usecases/get_historical_readings.dart';
import '../../domain/usecases/get_latest_readings.dart';
import '../../domain/usecases/get_weekly_data.dart';
import '../../domain/usecases/get_latest_data.dart';
import '../../../farm/domain/usecases/get_farm_analytics.dart';

part 'monitoring_event.dart';
part 'monitoring_state.dart';

class MonitoringBloc extends Bloc<MonitoringEvent, MonitoringState> {
  final GetLatestReadings _getLatestReadings;
  final GetHistoricalReadings _getHistoricalReadings;
  final GetCurrentWeather _getCurrentWeather;
  final GetFarmAnalytics _getFarmAnalytics;
  final GetWeeklyData _getWeeklyData;
  final GetLatestData _getLatestData;

  MonitoringBloc({
    required GetLatestReadings getLatestReadings,
    required GetHistoricalReadings getHistoricalReadings,
    required GetCurrentWeather getCurrentWeather,
    required GetFarmAnalytics getFarmAnalytics,
    required GetWeeklyData getWeeklyData,
    required GetLatestData getLatestData,
  }) : _getLatestReadings = getLatestReadings,
       _getHistoricalReadings = getHistoricalReadings,
       _getCurrentWeather = getCurrentWeather,
       _getFarmAnalytics = getFarmAnalytics,
       _getWeeklyData = getWeeklyData,
       _getLatestData = getLatestData,
       super(const MonitoringState()) {
    on<LoadLatestReadingsEvent>(_onLoadLatestReadings);
    on<LoadHistoricalReadingsEvent>(_onLoadHistoricalReadings);
    on<LoadFarmAnalyticsEvent>(_onLoadFarmAnalytics);
    on<LoadWeeklyDataEvent>(_onLoadWeeklyData);
    on<LoadLatestDataEvent>(_onLoadLatestData);
    on<RefreshReadingsEvent>(_onRefreshReadings);
    on<LoadWeatherDataEvent>(_onLoadWeatherData);
    on<AnalyticsUpdatedEvent>(_onAnalyticsUpdated);
    on<ClearErrorEvent>(_onClearError);
    
    // Initialize Socket.IO connection for real-time updates
    _initializeSocket();
  }

  void _initializeSocket() {
    // Socket connection will be initialized when needed
    // For now, we'll skip socket initialization to avoid errors
  }

  Future<void> _onAnalyticsUpdated(
    AnalyticsUpdatedEvent event,
    Emitter<MonitoringState> emit,
  ) async {
    emit(state.copyWith(farmAnalytics: event.analytics));
  }

  @override
  Future<void> close() {
    // Socket cleanup will be handled when needed
    return super.close();
  }

  Future<void> _onLoadLatestReadings(
    LoadLatestReadingsEvent event,
    Emitter<MonitoringState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _getLatestReadings();

    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (readings) => emit(state.copyWith(isLoading: false, latestReadings: readings, clearError: true)),
    );
  }

  Future<void> _onLoadHistoricalReadings(
    LoadHistoricalReadingsEvent event,
    Emitter<MonitoringState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _getHistoricalReadings(event.farmId, event.days);

    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (readings) => emit(state.copyWith(isLoading: false, historicalReadings: readings, clearError: true)),
    );
  }

  Future<void> _onRefreshReadings(
    RefreshReadingsEvent event,
    Emitter<MonitoringState> emit,
  ) async {
    // Refresh both latest and historical readings
    add(LoadLatestReadingsEvent());
    if (event.farmId != null) {
      add(LoadHistoricalReadingsEvent(farmId: event.farmId!, days: 7));
    }
  }

  Future<void> _onLoadWeatherData(
    LoadWeatherDataEvent event,
    Emitter<MonitoringState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _getCurrentWeather(event.farmId);

    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (weatherData) => emit(state.copyWith(isLoading: false, weatherData: weatherData, clearError: true)),
    );
  }

  Future<void> _onLoadFarmAnalytics(
    LoadFarmAnalyticsEvent event,
    Emitter<MonitoringState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _getFarmAnalytics(event.farmId);

    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (analytics) => emit(state.copyWith(isLoading: false, farmAnalytics: analytics, clearError: true)),
    );
  }

  Future<void> _onLoadWeeklyData(
    LoadWeeklyDataEvent event,
    Emitter<MonitoringState> emit,
  ) async {
    // Use isLoadingWeekly — completely independent of the shared isLoading flag.
    // Clear weeklyData so the widget always shows a spinner (not stale data from a different week).
    emit(state.copyWith(isLoadingWeekly: true, clearWeeklyError: true, clearWeeklyData: true));

    try {
      final result = await _getWeeklyData(GetWeeklyDataParams(
        farmId: event.farmId,
        fieldId: event.fieldId,
        weekOffset: event.weekOffset,
      ));

      result.fold(
        (failure) {
          emit(state.copyWith(
            isLoadingWeekly: false,
            weeklyData: [],
            weeklyError: failure.message,
          ));
        },
        (weeklyData) {
          final List<Map<String, dynamic>> formattedData = [];
          if (weeklyData['dailyData'] != null) {
            for (var dayData in weeklyData['dailyData']) {
              if (dayData['readingCount'] != null && (dayData['readingCount'] as num) > 0) {
                formattedData.add({
                  'timestamp': dayData['date'],
                  'hasData': true,
                  'measurements': {
                    'temperature': (dayData['temperature'] as num?)?.toDouble(),
                    'humidity': (dayData['humidity'] as num?)?.toDouble(),
                    'soilMoisture': (dayData['soilMoisture'] as num?)?.toDouble(),
                    'soilPh': (dayData['soilPh'] as num?)?.toDouble(),
                    'lightIntensity': (dayData['lightIntensity'] as num?)?.toDouble(),
                  },
                });
              }
            }
          }
          emit(state.copyWith(
            isLoadingWeekly: false,
            weeklyData: formattedData,
            clearWeeklyError: true,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        isLoadingWeekly: false,
        weeklyData: [],
        weeklyError: 'Failed to load weekly data. Please retry.',
      ));
    }
  }

  Future<void> _onLoadLatestData(
    LoadLatestDataEvent event,
    Emitter<MonitoringState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _getLatestData(event.farmId);

    result.fold(
      (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
      (latestData) => emit(
        state.copyWith(isLoading: false, latestData: latestData, error: null),
      ),
    );
  }

  Future<void> _onClearError(
    ClearErrorEvent event,
    Emitter<MonitoringState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: false,
      isLoadingWeekly: false,
      clearError: true,
      clearWeeklyError: true,
    ));
  }
}