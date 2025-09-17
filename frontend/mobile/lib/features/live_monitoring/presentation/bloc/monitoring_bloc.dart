// features/live_monitoring/presentation/bloc/monitoring_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/sensor_reading.dart';
import '../../domain/entities/weather_data.dart';
import '../../domain/usecases/get_current_weather.dart';
import '../../domain/usecases/get_historical_readings.dart';
import '../../domain/usecases/get_latest_readings.dart';
import '../../../farm/domain/usecases/get_farm_analytics.dart';
import '../../../../core/services/socket_service.dart';

part 'monitoring_event.dart';
part 'monitoring_state.dart';

class MonitoringBloc extends Bloc<MonitoringEvent, MonitoringState> {
  final GetLatestReadings _getLatestReadings;
  final GetHistoricalReadings _getHistoricalReadings;
  final GetCurrentWeather _getCurrentWeather;
  final GetFarmAnalytics _getFarmAnalytics;

  MonitoringBloc({
    required GetLatestReadings getLatestReadings,
    required GetHistoricalReadings getHistoricalReadings,
    required GetCurrentWeather getCurrentWeather,
    required GetFarmAnalytics getFarmAnalytics,
  }) : _getLatestReadings = getLatestReadings,
       _getHistoricalReadings = getHistoricalReadings,
       _getCurrentWeather = getCurrentWeather,
       _getFarmAnalytics = getFarmAnalytics,
       super(const MonitoringState()) {
    on<LoadLatestReadingsEvent>(_onLoadLatestReadings);
    on<LoadHistoricalReadingsEvent>(_onLoadHistoricalReadings);
    on<LoadFarmAnalyticsEvent>(_onLoadFarmAnalytics);
    on<RefreshReadingsEvent>(_onRefreshReadings);
    on<LoadWeatherDataEvent>(_onLoadWeatherData);
    on<AnalyticsUpdatedEvent>(_onAnalyticsUpdated);
    
    // Initialize Socket.IO connection for real-time updates
    _initializeSocket();
  }

  void _initializeSocket() {
    SocketService.instance.connect();
    SocketService.instance.onAnalyticsUpdated((data) {
      final analytics = data['analytics'] as Map<String, dynamic>?;
      if (analytics != null) {
        add(AnalyticsUpdatedEvent(analytics: analytics));
      }
    });
  }

  Future<void> _onAnalyticsUpdated(
    AnalyticsUpdatedEvent event,
    Emitter<MonitoringState> emit,
  ) async {
    emit(state.copyWith(farmAnalytics: event.analytics));
  }

  @override
  Future<void> close() {
    SocketService.instance.offAnalyticsUpdated();
    return super.close();
  }

  Future<void> _onLoadLatestReadings(
    LoadLatestReadingsEvent event,
    Emitter<MonitoringState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _getLatestReadings();

    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, error: failure.message)),
      (readings) => emit(
        state.copyWith(isLoading: false, latestReadings: readings, error: null),
      ),
    );
  }

  Future<void> _onLoadHistoricalReadings(
    LoadHistoricalReadingsEvent event,
    Emitter<MonitoringState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final result = await _getHistoricalReadings(event.farmId, event.days);

    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, error: failure.message)),
      (readings) => emit(
        state.copyWith(
          isLoading: false,
          historicalReadings: readings,
          error: null,
        ),
      ),
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
      (weatherData) => emit(
        state.copyWith(isLoading: false, weatherData: weatherData, error: null),
      ),
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
      (analytics) => emit(
        state.copyWith(isLoading: false, farmAnalytics: analytics, error: null),
      ),
    );
  }
}