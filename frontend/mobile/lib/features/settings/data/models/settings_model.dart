import 'package:mobile/features/settings/domain/entities/settings_entity.dart';

class SettingsModel extends SettingsEntity {
  const SettingsModel({
    required super.notificationsEnabled,
    required super.vibrationOnly,
    required super.language,
    required super.sensorStatus,
    required super.darkMode,
    required super.autoSync,
    required super.syncInterval,
    required super.dataCollectionEnabled,
    required super.analyticsEnabled,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      notificationsEnabled: json['notificationsEnabled'] ?? false,
      vibrationOnly: json['vibrationOnly'] ?? false,
      language: json['language'] ?? 'en',
      sensorStatus: Map<String, bool>.from(json['sensorStatus'] ?? {}),
      darkMode: json['darkMode'] ?? false,
      autoSync: json['autoSync'] ?? true,
      syncInterval: json['syncInterval'] ?? 30,
      dataCollectionEnabled: json['dataCollectionEnabled'] ?? true,
      analyticsEnabled: json['analyticsEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'vibrationOnly': vibrationOnly,
      'language': language,
      'sensorStatus': sensorStatus,
      'darkMode': darkMode,
      'autoSync': autoSync,
      'syncInterval': syncInterval,
      'dataCollectionEnabled': dataCollectionEnabled,
      'analyticsEnabled': analyticsEnabled,
    };
  }

  factory SettingsModel.fromEntity(SettingsEntity entity) {
    return SettingsModel(
      notificationsEnabled: entity.notificationsEnabled,
      vibrationOnly: entity.vibrationOnly,
      language: entity.language,
      sensorStatus: entity.sensorStatus,
      darkMode: entity.darkMode,
      autoSync: entity.autoSync,
      syncInterval: entity.syncInterval,
      dataCollectionEnabled: entity.dataCollectionEnabled,
      analyticsEnabled: entity.analyticsEnabled,
    );
  }

  SettingsEntity toEntity() {
    return SettingsEntity(
      notificationsEnabled: notificationsEnabled,
      vibrationOnly: vibrationOnly,
      language: language,
      sensorStatus: sensorStatus,
      darkMode: darkMode,
      autoSync: autoSync,
      syncInterval: syncInterval,
      dataCollectionEnabled: dataCollectionEnabled,
      analyticsEnabled: analyticsEnabled,
    );
  }
}

class SensorStatusModel extends SensorStatusEntity {
  const SensorStatusModel({
    required super.ldrSensor,
    required super.phLevelSensor,
    required super.tempAndHumidSensor,
    required super.soilLevelSensor,
  });

  factory SensorStatusModel.fromJson(Map<String, dynamic> json) {
    return SensorStatusModel(
      ldrSensor: json['ldr'] ?? false,
      phLevelSensor: json['ph'] ?? false,
      tempAndHumidSensor: json['dht'] ?? false,
      soilLevelSensor: json['soil'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ldr': ldrSensor,
      'ph': phLevelSensor,
      'dht': tempAndHumidSensor,
      'soil': soilLevelSensor,
    };
  }

  factory SensorStatusModel.fromEntity(SensorStatusEntity entity) {
    return SensorStatusModel(
      ldrSensor: entity.ldrSensor,
      phLevelSensor: entity.phLevelSensor,
      tempAndHumidSensor: entity.tempAndHumidSensor,
      soilLevelSensor: entity.soilLevelSensor,
    );
  }

  SensorStatusEntity toEntity() {
    return SensorStatusEntity(
      ldrSensor: ldrSensor,
      phLevelSensor: phLevelSensor,
      tempAndHumidSensor: tempAndHumidSensor,
      soilLevelSensor: soilLevelSensor,
    );
  }
}
