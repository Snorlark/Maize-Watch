// features/live_monitoring/data/models/weather_model.dart
import '../../domain/entities/weather_data.dart';

class WeatherModel extends WeatherData {
  const WeatherModel({
    required super.temperature,
    required super.humidity,
    required super.windSpeed,
    required super.condition,
    required super.description,
    required super.icon,
    required super.pressure,
    required super.visibility,
    required super.uvIndex,
    required super.timestamp,
    required super.location,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: (json['main']['temp'] as num).toDouble(),
      humidity: (json['main']['humidity'] as num).toDouble(),
      windSpeed: json['wind'] != null ? (json['wind']['speed'] as num).toDouble() : 0.0,
      condition: json['weather'][0]['main'] as String,
      description: json['weather'][0]['description'] as String,
      icon: json['weather'][0]['icon'] as String,
      pressure: (json['main']['pressure'] as num).toDouble(),
      visibility: json['visibility'] != null ? (json['visibility'] as num).toDouble() : 10000.0,
      uvIndex: 0.0, // OpenWeather doesn't provide UV in basic weather endpoint
      timestamp: DateTime.now(),
      location: json['name'] as String,
    );
  }

  factory WeatherModel.fromForecastJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: (json['main']['temp'] as num).toDouble(),
      humidity: (json['main']['humidity'] as num).toDouble(),
      windSpeed: json['wind'] != null ? (json['wind']['speed'] as num).toDouble() : 0.0,
      condition: json['weather'][0]['main'] as String,
      description: json['weather'][0]['description'] as String,
      icon: json['weather'][0]['icon'] as String,
      pressure: (json['main']['pressure'] as num).toDouble(),
      visibility: json['visibility'] != null ? (json['visibility'] as num).toDouble() : 10000.0,
      uvIndex: 0.0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      location: '',
    );
  }

  factory WeatherModel.fromInternalApi(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: (json['temperature'] as num?)?.toDouble() ?? 25.0,
      humidity: (json['humidity'] as num?)?.toDouble() ?? 65.0,
      windSpeed: (json['windSpeed'] as num?)?.toDouble() ?? 5.2,
      condition: json['condition'] as String? ?? 'partly_cloudy',
      description: json['description'] as String? ?? 'Partly cloudy',
      icon: json['icon'] as String? ?? '02d',
      pressure: (json['pressure'] as num?)?.toDouble() ?? 1013.25,
      visibility: (json['visibility'] as num?)?.toDouble() ?? 10.0,
      uvIndex: (json['uvIndex'] as num?)?.toDouble() ?? 5.0,
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
      location: json['location'] as String? ?? 'Farm Location',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'condition': condition,
      'description': description,
      'icon': icon,
      'pressure': pressure,
      'visibility': visibility,
      'uvIndex': uvIndex,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'location': location,
    };
  }
}
