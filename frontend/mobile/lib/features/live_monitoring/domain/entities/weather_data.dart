// features/live_monitoring/domain/entities/weather_data.dart
import 'package:equatable/equatable.dart';

class WeatherData extends Equatable {
  final double temperature;
  final double humidity;
  final double windSpeed;
  final String condition;
  final String description;
  final String icon;
  final double pressure;
  final double visibility;
  final double uvIndex;
  final DateTime timestamp;
  final String location;

  const WeatherData({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.condition,
    required this.description,
    required this.icon,
    required this.pressure,
    required this.visibility,
    required this.uvIndex,
    required this.timestamp,
    required this.location,
  });

  @override
  List<Object?> get props => [
    temperature,
    humidity,
    windSpeed,
    condition,
    description,
    icon,
    pressure,
    visibility,
    uvIndex,
    timestamp,
    location,
  ];
}
