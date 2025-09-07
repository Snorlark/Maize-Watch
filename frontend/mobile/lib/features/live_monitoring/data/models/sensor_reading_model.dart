import '../../domain/entities/sensor_reading.dart';

class SensorReadingModel extends SensorReading {
  const SensorReadingModel({
    required super.id,
    required super.sensorId,
    required super.farmId,
    required super.temperature,
    required super.humidity,
    required super.soilMoisture,
    required super.pH,
    required super.lightIntensity,
    required super.timestamp,
    super.quality,
  });

  factory SensorReadingModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;

    return SensorReadingModel(
      id: json['_id'] as String,
      sensorId: json['sensor'] as String,
      farmId: json['farm'] as String,
      temperature: _parseDouble(data['temperature'] ?? 0.0),
      humidity: _parseDouble(data['humidity'] ?? 0.0),
      soilMoisture: _parseDouble(data['soilMoisture'] ?? 0.0),
      pH: _parseDouble(data['pH'] ?? 7.0),
      lightIntensity: _parseDouble(data['lightLevel'] ?? 0.0),
      timestamp: DateTime.parse(json['timestamp'] as String),
      quality: json['quality'] as String? ?? 'good',
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'sensor': sensorId,
      'farm': farmId,
      'data': {
        'temperature': temperature,
        'humidity': humidity,
        'soilMoisture': soilMoisture,
        'pH': pH,
        'lightLevel': lightIntensity,
      },
      'timestamp': timestamp.toIso8601String(),
      'quality': quality,
    };
  }

  SensorReading toEntity() {
    return SensorReading(
      id: id,
      sensorId: sensorId,
      farmId: farmId,
      temperature: temperature,
      humidity: humidity,
      soilMoisture: soilMoisture,
      pH: pH,
      lightIntensity: lightIntensity,
      timestamp: timestamp,
      quality: quality,
    );
  }

  SensorReadingModel copyWith({
    String? id,
    String? sensorId,
    String? farmId,
    double? temperature,
    double? humidity,
    double? soilMoisture,
    double? pH,
    double? lightIntensity,
    DateTime? timestamp,
    String? quality,
  }) {
    return SensorReadingModel(
      id: id ?? this.id,
      sensorId: sensorId ?? this.sensorId,
      farmId: farmId ?? this.farmId,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      soilMoisture: soilMoisture ?? this.soilMoisture,
      pH: pH ?? this.pH,
      lightIntensity: lightIntensity ?? this.lightIntensity,
      timestamp: timestamp ?? this.timestamp,
      quality: quality ?? this.quality,
    );
  }
}
