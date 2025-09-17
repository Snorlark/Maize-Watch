import 'package:equatable/equatable.dart';

// Sensor readings model
class SensorReadings extends Equatable {
  final double soilMoisture;
  final double temperature;
  final double humidity;
  final double lightIntensity;
  final double soilPh;

  const SensorReadings({
    this.soilMoisture = 0,
    this.temperature = 0,
    this.humidity = 0,
    this.lightIntensity = 0,
    this.soilPh = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'soilMoisture': soilMoisture,
      'temperature': temperature,
      'humidity': humidity,
      'lightIntensity': lightIntensity,
      'soilPh': soilPh,
    };
  }

  factory SensorReadings.fromJson(Map<String, dynamic> json) {
    return SensorReadings(
      soilMoisture: (json['soilMoisture'] ?? 0).toDouble(),
      temperature: (json['temperature'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? 0).toDouble(),
      lightIntensity: (json['lightIntensity'] ?? 0).toDouble(),
      soilPh: (json['soilPh'] ?? 0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [soilMoisture, temperature, humidity, lightIntensity, soilPh];
}

// Sensor model
class Sensor extends Equatable {
  final String deviceID;
  final String sensorName;
  final String description;
  final String soilType; // loamy, sandy, clay, silty
  final SensorReadings readings;

  const Sensor({
    required this.deviceID,
    required this.sensorName,
    required this.description,
    required this.soilType,
    required this.readings,
  });

  Map<String, dynamic> toJson() {
    return {
      'deviceID': deviceID,
      'sensorName': sensorName,
      'description': description,
      'soilType': soilType,
      'readings': readings.toJson(),
    };
  }

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
      deviceID: json['deviceID'] ?? json['deviceId'] ?? json['_id'] ?? '',
      sensorName: json['sensorName'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      soilType: json['soilType'] ?? 'loamy',
      readings: SensorReadings.fromJson(json['readings'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [deviceID, sensorName, description, soilType, readings];
}

// Field model
class Field extends Equatable {
  final String fieldName;
  final DateTime plantingDate;
  final String growthStage; // VE, V3, V8, VT, R1, R6
  final List<Sensor> sensors;

  const Field({
    required this.fieldName,
    required this.plantingDate,
    required this.growthStage,
    required this.sensors,
  });

  Map<String, dynamic> toJson() {
    return {
      'fieldName': fieldName,
      'plantingDate': plantingDate.toIso8601String(),
      'growthStage': growthStage,
      'sensors': sensors.map((sensor) => sensor.toJson()).toList(),
    };
  }

  factory Field.fromJson(Map<String, dynamic> json) {
    return Field(
      fieldName: json['fieldName'] ?? '',
      plantingDate: DateTime.parse(json['plantingDate']),
      growthStage: json['growthStage'] ?? 'VE',
      sensors: (json['sensors'] as List<dynamic>? ?? [])
          .map((sensorJson) => Sensor.fromJson(sensorJson))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [fieldName, plantingDate, growthStage, sensors];
}

class Farm extends Equatable {
  final String? id;
  final String userId;
  final String farmName;
  final String location;
  final List<Field> fields;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Farm({
    this.id,
    required this.userId,
    required this.farmName,
    required this.location,
    required this.fields,
    required this.createdAt,
    required this.updatedAt,
  });

  Farm copyWith({
    String? id,
    String? userId,
    String? farmName,
    String? location,
    List<Field>? fields,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Farm(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      farmName: farmName ?? this.farmName,
      location: location ?? this.location,
      fields: fields ?? this.fields,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'farmName': farmName,
      'location': location,
      'fields': fields.map((field) => field.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Farm.fromJson(Map<String, dynamic> json) {
    // Handle userId - it can be either a string or an object with _id
    String userIdValue = '';
    if (json['userId'] is String) {
      userIdValue = json['userId'];
    } else if (json['userId'] is Map<String, dynamic>) {
      userIdValue = json['userId']['_id'] ?? '';
    }

    return Farm(
      id: json['id'] ?? json['_id'],
      userId: userIdValue,
      farmName: json['farmName'] ?? '',
      location: json['location'] ?? '',
      fields: (json['fields'] as List<dynamic>? ?? [])
          .map((fieldJson) => Field.fromJson(fieldJson))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        farmName,
        location,
        fields,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'Farm('
        'id: $id, '
        'userId: $userId, '
        'farmName: $farmName, '
        'fields: ${fields.length}, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt'
        ')';
  }
}