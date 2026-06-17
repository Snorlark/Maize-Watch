// monitoring_state.dart
part of 'monitoring_bloc.dart';

class MonitoringState extends Equatable {
  final bool isLoading;
  final bool isLoadingWeekly;
  final List<SensorReading> latestReadings;
  final List<SensorReading> historicalReadings;
  final WeatherData? weatherData;
  final Map<String, dynamic>? farmAnalytics;
  final List<Map<String, dynamic>>? weeklyData;
  final Map<String, dynamic>? latestData;
  final String? error;
  final String? weeklyError;

  const MonitoringState({
    this.isLoading = false,
    this.isLoadingWeekly = false,
    this.latestReadings = const [],
    this.historicalReadings = const [],
    this.weatherData,
    this.farmAnalytics,
    this.weeklyData,
    this.latestData,
    this.error,
    this.weeklyError,
  });

  MonitoringState copyWith({
    bool? isLoading,
    bool? isLoadingWeekly,
    List<SensorReading>? latestReadings,
    List<SensorReading>? historicalReadings,
    WeatherData? weatherData,
    Map<String, dynamic>? farmAnalytics,
    List<Map<String, dynamic>>? weeklyData,
    Map<String, dynamic>? latestData,
    String? error,
    String? weeklyError,
    bool clearWeeklyError = false,
    bool clearWeeklyData = false,
    bool clearError = false,
  }) {
    return MonitoringState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingWeekly: isLoadingWeekly ?? this.isLoadingWeekly,
      latestReadings: latestReadings ?? this.latestReadings,
      historicalReadings: historicalReadings ?? this.historicalReadings,
      weatherData: weatherData ?? this.weatherData,
      farmAnalytics: farmAnalytics ?? this.farmAnalytics,
      weeklyData: clearWeeklyData ? null : (weeklyData ?? this.weeklyData),
      latestData: latestData ?? this.latestData,
      error: clearError ? null : (error ?? this.error),
      weeklyError: clearWeeklyError ? null : (weeklyError ?? this.weeklyError),
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isLoadingWeekly,
    latestReadings,
    historicalReadings,
    weatherData,
    farmAnalytics,
    weeklyData,
    latestData,
    error,
    weeklyError,
  ];
}