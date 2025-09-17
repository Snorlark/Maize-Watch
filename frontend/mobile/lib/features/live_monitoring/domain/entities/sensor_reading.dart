// features/live_monitoring/domain/entities/sensor_reading.dart
import 'package:equatable/equatable.dart';

class SensorReading extends Equatable {
  final String id;
  final String sensorId;
  final String farmId;
  final double temperature;
  final double humidity;
  final double soilMoisture;
  final double pH;
  final double lightIntensity;
  final DateTime timestamp;
  final String quality;

  const SensorReading({
    required this.id,
    required this.sensorId,
    required this.farmId,
    required this.temperature,
    required this.humidity,
    required this.soilMoisture,
    required this.pH,
    required this.lightIntensity,
    required this.timestamp,
    this.quality = 'good',
  });

  // Helper methods for crop analysis
  bool get isTemperatureOptimal => temperature >= 15 && temperature <= 30;
  bool get isHumidityOptimal => humidity >= 40 && humidity <= 80;
  bool get isSoilMoistureOptimal => soilMoisture >= 40 && soilMoisture <= 70;
  bool get isLightOptimal => lightIntensity >= 30;

  double get averageReading =>
      (temperature + humidity + soilMoisture + lightIntensity) / 4;

  String get cropHealthStatus {
    final optimalCount =
        [
          isTemperatureOptimal,
          isHumidityOptimal,
          isSoilMoistureOptimal,
          isLightOptimal,
        ].where((optimal) => optimal).length;

    switch (optimalCount) {
      case 4:
        return 'Excellent';
      case 3:
        return 'Good';
      case 2:
        return 'Fair';
      case 1:
        return 'Poor';
      default:
        return 'Critical';
    }
  }

  @override
  List<Object?> get props => [
    id,
    sensorId,
    farmId,
    temperature,
    humidity,
    soilMoisture,
    pH,
    lightIntensity,
    timestamp,
    quality,
  ];
}
