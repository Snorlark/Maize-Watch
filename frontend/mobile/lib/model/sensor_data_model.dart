class SensorReading {
  final DateTime timestamp;
  final String fieldId;
  final Measurements measurements;

  SensorReading({
    required this.timestamp,
    required this.fieldId,
    required this.measurements,
  });

  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      timestamp: DateTime.parse(json['timestamp']),
      fieldId: json['field_id'],
      measurements: Measurements.fromJson(json['measurements']),
    );
  }
}

class Measurements {
  final double temperature;
  final double humidity;
  final double soilMoisture;
  final double lightLevel;

  Measurements({
    required this.temperature,
    required this.humidity,
    required this.soilMoisture,
    required this.lightLevel,
  });

  factory Measurements.fromJson(Map<String, dynamic> json) {
    return Measurements(
      temperature: json['temperature'].toDouble(),
      humidity: json['humidity'].toDouble(),
      soilMoisture: json['soil_moisture'].toDouble(),
      lightLevel: json['light_level'].toDouble(),
    );
  }
}