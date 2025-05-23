// This is what the Flutter app is expecting based on sensor_data_model.dart
class SensorReading {
  final String id;
  final DateTime timestamp;
  final String fieldId;
  final double temperature;
  final double humidity;
  final int soilMoisture;
  final double soilPh;
  final int lightIntensity;

  SensorReading({
    required this.id,
    required this.timestamp,
    required this.fieldId,
    required this.temperature,
    required this.humidity,
    required this.soilMoisture,
    required this.soilPh,
    required this.lightIntensity,
  });

  factory SensorReading.fromJson(Map<String, dynamic> json) {
  final measurements = json['measurements'] ?? {};
  return SensorReading(
    id: json['_id'] ?? '',
    timestamp: json['timestamp'] != null 
        ? DateTime.parse(json['timestamp']) 
        : DateTime.now(),
    fieldId: json['field_id'] ?? '',
    temperature: measurements['temperature']?.toDouble() ?? 0.0,
    humidity: measurements['humidity']?.toDouble() ?? 0.0,
    soilMoisture: measurements['soil_moisture'] ?? 0,
    soilPh: measurements['soil_ph']?.toDouble() ?? 0.0,
    lightIntensity: measurements['light_intensity'] ?? 0,
  );
}


  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'timestamp': timestamp.toIso8601String(),
      'field_id': fieldId,
      'measurements': {
        'temperature': temperature,
        'humidity': humidity,
        'soil_moisture': soilMoisture,
        'soil_ph': soilPh,
        'light_intensity': lightIntensity,
      },
    };
  }
}