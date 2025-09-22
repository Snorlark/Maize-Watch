import 'dart:convert';
import 'package:mobile/core/storage/secure_storage.dart';
import 'package:mobile/features/settings/data/models/settings_model.dart';

abstract class SettingsLocalDataSource {
  Future<SettingsModel> getSettings();
  Future<void> cacheSettings(SettingsModel settings);
  Future<SensorStatusModel> getSensorStatus();
  Future<void> cacheSensorStatus(SensorStatusModel sensorStatus);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  SettingsLocalDataSourceImpl();

  @override
  Future<SettingsModel> getSettings() async {
    try {
      final settingsJson = await SecureStorage.read(key: 'settings');
      if (settingsJson != null) {
        final settingsData = Map<String, dynamic>.from(jsonDecode(settingsJson));
        return SettingsModel.fromJson(settingsData);
      }
      return _getDefaultSettings();
    } catch (e) {
      return _getDefaultSettings();
    }
  }

  @override
  Future<void> cacheSettings(SettingsModel settings) async {
    try {
      final settingsJson = jsonEncode(settings.toJson());
      await SecureStorage.write(key: 'settings', value: settingsJson);
    } catch (e) {
      throw Exception('Failed to cache settings: $e');
    }
  }

  @override
  Future<SensorStatusModel> getSensorStatus() async {
    try {
      final sensorStatusJson = await SecureStorage.read(key: 'sensorStatus');
      if (sensorStatusJson != null) {
        final sensorStatusData = Map<String, dynamic>.from(jsonDecode(sensorStatusJson));
        return SensorStatusModel.fromJson(sensorStatusData);
      }
      return _getDefaultSensorStatus();
    } catch (e) {
      return _getDefaultSensorStatus();
    }
  }

  @override
  Future<void> cacheSensorStatus(SensorStatusModel sensorStatus) async {
    try {
      final sensorStatusJson = jsonEncode(sensorStatus.toJson());
      await SecureStorage.write(key: 'sensorStatus', value: sensorStatusJson);
    } catch (e) {
      throw Exception('Failed to cache sensor status: $e');
    }
  }

  SettingsModel _getDefaultSettings() {
    return const SettingsModel(
      notificationsEnabled: true,
      vibrationOnly: false,
      language: 'en',
      sensorStatus: {},
      darkMode: false,
      autoSync: true,
      syncInterval: 30,
      dataCollectionEnabled: true,
      analyticsEnabled: true,
    );
  }

  SensorStatusModel _getDefaultSensorStatus() {
    return const SensorStatusModel(
      ldrSensor: false,
      phLevelSensor: false,
      tempAndHumidSensor: false,
      soilLevelSensor: false,
    );
  }
}
