import 'package:equatable/equatable.dart';

class SettingsEntity extends Equatable {
  final bool notificationsEnabled;
  final bool vibrationOnly;
  final String language;
  final Map<String, bool> sensorStatus;
  final bool darkMode;
  final bool autoSync;
  final int syncInterval; // in minutes
  final bool dataCollectionEnabled;
  final bool analyticsEnabled;

  const SettingsEntity({
    required this.notificationsEnabled,
    required this.vibrationOnly,
    required this.language,
    required this.sensorStatus,
    required this.darkMode,
    required this.autoSync,
    required this.syncInterval,
    required this.dataCollectionEnabled,
    required this.analyticsEnabled,
  });

  @override
  List<Object?> get props => [
        notificationsEnabled,
        vibrationOnly,
        language,
        sensorStatus,
        darkMode,
        autoSync,
        syncInterval,
        dataCollectionEnabled,
        analyticsEnabled,
      ];

  SettingsEntity copyWith({
    bool? notificationsEnabled,
    bool? vibrationOnly,
    String? language,
    Map<String, bool>? sensorStatus,
    bool? darkMode,
    bool? autoSync,
    int? syncInterval,
    bool? dataCollectionEnabled,
    bool? analyticsEnabled,
  }) {
    return SettingsEntity(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      vibrationOnly: vibrationOnly ?? this.vibrationOnly,
      language: language ?? this.language,
      sensorStatus: sensorStatus ?? this.sensorStatus,
      darkMode: darkMode ?? this.darkMode,
      autoSync: autoSync ?? this.autoSync,
      syncInterval: syncInterval ?? this.syncInterval,
      dataCollectionEnabled: dataCollectionEnabled ?? this.dataCollectionEnabled,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
    );
  }
}

class SensorStatusEntity extends Equatable {
  final bool ldrSensor;
  final bool phLevelSensor;
  final bool tempAndHumidSensor;
  final bool soilLevelSensor;

  const SensorStatusEntity({
    required this.ldrSensor,
    required this.phLevelSensor,
    required this.tempAndHumidSensor,
    required this.soilLevelSensor,
  });

  @override
  List<Object?> get props => [
        ldrSensor,
        phLevelSensor,
        tempAndHumidSensor,
        soilLevelSensor,
      ];

  Map<String, bool> toMap() {
    return {
      'ldr': ldrSensor,
      'ph': phLevelSensor,
      'dht': tempAndHumidSensor,
      'soil': soilLevelSensor,
    };
  }
}
