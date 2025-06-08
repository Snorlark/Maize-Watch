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
    // Try to get measurements from nested structure first
    final measurements = json['measurements'] ?? {};
    
    // If measurements is empty, use the root object
    final data = measurements.isEmpty ? json : measurements;
    
    return SensorReading(
      id: json['_id'] ?? json['id'] ?? '',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
      fieldId: json['field_id'] ?? json['fieldId'] ?? '',
      temperature: data['temperature']?.toDouble() ?? 0.0,
      humidity: data['humidity']?.toDouble() ?? 0.0,
      soilMoisture: data['soil_moisture'] ?? data['soilMoisture'] ?? 0,
      soilPh: data['soil_ph']?.toDouble() ?? data['soilPh']?.toDouble() ?? 0.0,
      lightIntensity: data['light_intensity'] ?? data['lightIntensity'] ?? 0,
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