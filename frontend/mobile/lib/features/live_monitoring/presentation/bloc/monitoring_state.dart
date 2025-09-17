// monitoring_state.dart
part of 'monitoring_bloc.dart';

class MonitoringState extends Equatable {
  final bool isLoading;
  final List<SensorReading> latestReadings;
  final List<SensorReading> historicalReadings;
  final WeatherData? weatherData;
  final Map<String, dynamic>? farmAnalytics;
  final String? error;

  const MonitoringState({
    this.isLoading = false,
    this.latestReadings = const [],
    this.historicalReadings = const [],
    this.weatherData,
    this.farmAnalytics,
    this.error,
  });

  MonitoringState copyWith({
    bool? isLoading,
    List<SensorReading>? latestReadings,
    List<SensorReading>? historicalReadings,
    WeatherData? weatherData,
    Map<String, dynamic>? farmAnalytics,
    String? error,
  }) {
    return MonitoringState(
      isLoading: isLoading ?? this.isLoading,
      latestReadings: latestReadings ?? this.latestReadings,
      historicalReadings: historicalReadings ?? this.historicalReadings,
      weatherData: weatherData ?? this.weatherData,
      farmAnalytics: farmAnalytics ?? this.farmAnalytics,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    latestReadings,
    historicalReadings,
    weatherData,
    farmAnalytics,
    error,
  ];
}