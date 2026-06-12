import 'package:dio/dio.dart';
import 'package:mobile/core/error/exceptions.dart';
import 'package:mobile/features/settings/data/models/settings_model.dart';

abstract class SettingsRemoteDataSource {
  Future<SettingsModel> getSettings();
  Future<void> updateSettings(SettingsModel settings);
  Future<SensorStatusModel> getSensorStatus();
  Future<void> updateNotificationSettings({
    required bool enabled,
    required bool vibrationOnly,
  });
  Future<void> updateLanguage(String language);
  Future<void> updateTheme(bool darkMode);
  Future<void> updateSyncSettings({
    required bool autoSync,
    required int syncInterval,
  });
  Future<void> updateDataCollection(bool enabled);
  Future<void> updateAnalytics(bool enabled);
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final Dio httpClient;

  SettingsRemoteDataSourceImpl({required this.httpClient});

  @override
  Future<SettingsModel> getSettings() async {
    try {
      final response = await httpClient.get('/settings');
      
      if (response.statusCode == 200) {
        return SettingsModel.fromJson(response.data['data']);
      } else {
        throw ServerException('Failed to load settings: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ConnectionTimeoutException();
      } else {
        throw ServerException('An unknown error occurred: ${e.message}');
      }
    }
  }

  @override
  Future<void> updateSettings(SettingsModel settings) async {
    try {
      final response = await httpClient.put('/settings', data: settings.toJson());
      
      if (response.statusCode != 200) {
        throw ServerException('Failed to update settings: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ConnectionTimeoutException();
      } else {
        throw ServerException('An unknown error occurred: ${e.message}');
      }
    }
  }

  @override
  Future<SensorStatusModel> getSensorStatus() async {
    try {
      final response = await httpClient.get('/settings/sensors/status');
      
      if (response.statusCode == 200) {
        return SensorStatusModel.fromJson(response.data['data']);
      } else {
        throw ServerException('Failed to load sensor status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ConnectionTimeoutException();
      } else {
        throw ServerException('An unknown error occurred: ${e.message}');
      }
    }
  }

  @override
  Future<void> updateNotificationSettings({
    required bool enabled,
    required bool vibrationOnly,
  }) async {
    try {
      final response = await httpClient.patch('/settings/notifications', data: {
        'enabled': enabled,
        'vibrationOnly': vibrationOnly,
      });
      
      if (response.statusCode != 200) {
        throw ServerException('Failed to update notification settings: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ConnectionTimeoutException();
      } else {
        throw ServerException('An unknown error occurred: ${e.message}');
      }
    }
  }

  @override
  Future<void> updateLanguage(String language) async {
    try {
      final response = await httpClient.patch('/settings/language', data: {
        'language': language,
      });
      
      if (response.statusCode != 200) {
        throw ServerException('Failed to update language: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ConnectionTimeoutException();
      } else {
        throw ServerException('An unknown error occurred: ${e.message}');
      }
    }
  }

  @override
  Future<void> updateTheme(bool darkMode) async {
    try {
      final response = await httpClient.patch('/settings/theme', data: {
        'darkMode': darkMode,
      });
      
      if (response.statusCode != 200) {
        throw ServerException('Failed to update theme: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ConnectionTimeoutException();
      } else {
        throw ServerException('An unknown error occurred: ${e.message}');
      }
    }
  }

  @override
  Future<void> updateSyncSettings({
    required bool autoSync,
    required int syncInterval,
  }) async {
    try {
      final response = await httpClient.patch('/settings/sync', data: {
        'autoSync': autoSync,
        'syncInterval': syncInterval,
      });
      
      if (response.statusCode != 200) {
        throw ServerException('Failed to update sync settings: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ConnectionTimeoutException();
      } else {
        throw ServerException('An unknown error occurred: ${e.message}');
      }
    }
  }

  @override
  Future<void> updateDataCollection(bool enabled) async {
    try {
      final response = await httpClient.patch('/settings/data-collection', data: {
        'enabled': enabled,
      });
      
      if (response.statusCode != 200) {
        throw ServerException('Failed to update data collection: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ConnectionTimeoutException();
      } else {
        throw ServerException('An unknown error occurred: ${e.message}');
      }
    }
  }

  @override
  Future<void> updateAnalytics(bool enabled) async {
    try {
      final response = await httpClient.patch('/settings/analytics', data: {
        'enabled': enabled,
      });
      
      if (response.statusCode != 200) {
        throw ServerException('Failed to update analytics: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ConnectionTimeoutException();
      } else {
        throw ServerException('An unknown error occurred: ${e.message}');
      }
    }
  }
}
