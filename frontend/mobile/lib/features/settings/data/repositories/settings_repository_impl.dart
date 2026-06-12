import 'package:mobile/core/error/exceptions.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:mobile/features/settings/data/datasources/settings_remote_data_source.dart';
import 'package:mobile/features/settings/data/models/settings_model.dart';
import 'package:mobile/features/settings/domain/entities/settings_entity.dart';
import 'package:mobile/features/settings/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource remoteDataSource;
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, SettingsEntity>> getSettings() async {
    try {
      print("🔧 SettingsRepository: Trying to get settings from remote...");
      // Try to get from remote first
      final remoteSettings = await remoteDataSource.getSettings();
      print("🔧 SettingsRepository: Remote settings received, caching locally...");
      // Cache locally
      await localDataSource.cacheSettings(remoteSettings);
      print("🔧 SettingsRepository: Settings cached, returning remote settings");
      return Right(remoteSettings.toEntity());
    } catch (e) {
      print("🔧 SettingsRepository: Remote failed with error: $e, trying local...");
      // Fallback to local data
      try {
        final localSettings = await localDataSource.getSettings();
        print("🔧 SettingsRepository: Local settings received");
        return Right(localSettings.toEntity());
      } catch (localError) {
        print("🔧 SettingsRepository: Local also failed with error: $localError, returning default settings");
        // If both remote and local fail, return default settings
        final defaultSettings = const SettingsModel(
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
        return Right(defaultSettings.toEntity());
      }
    }
  }

  @override
  Future<Either<Failure, void>> updateSettings(SettingsEntity settings) async {
    try {
      final settingsModel = SettingsModel.fromEntity(settings);
      await remoteDataSource.updateSettings(settingsModel);
      await localDataSource.cacheSettings(settingsModel);
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } on ConnectionTimeoutException {
      return Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, SensorStatusEntity>> getSensorStatus() async {
    try {
      print("🔧 SettingsRepository: Trying to get sensor status from remote...");
      // Try to get from remote first
      final remoteSensorStatus = await remoteDataSource.getSensorStatus();
      print("🔧 SettingsRepository: Remote sensor status received, caching locally...");
      // Cache locally
      await localDataSource.cacheSensorStatus(remoteSensorStatus);
      print("🔧 SettingsRepository: Sensor status cached, returning remote sensor status");
      return Right(remoteSensorStatus.toEntity());
    } catch (e) {
      print("🔧 SettingsRepository: Remote sensor status failed with error: $e, trying local...");
      // Fallback to local data
      try {
        final localSensorStatus = await localDataSource.getSensorStatus();
        print("🔧 SettingsRepository: Local sensor status received");
        return Right(localSensorStatus.toEntity());
      } catch (localError) {
        print("🔧 SettingsRepository: Local sensor status also failed with error: $localError, returning default sensor status");
        // If both remote and local fail, return default sensor status
        final defaultSensorStatus = const SensorStatusModel(
          ldrSensor: false,
          phLevelSensor: false,
          tempAndHumidSensor: false,
          soilLevelSensor: false,
        );
        return Right(defaultSensorStatus.toEntity());
      }
    }
  }

  @override
  Future<Either<Failure, void>> updateNotificationSettings({
    required bool enabled,
    required bool vibrationOnly,
  }) async {
    try {
      await remoteDataSource.updateNotificationSettings(
        enabled: enabled,
        vibrationOnly: vibrationOnly,
      );
      // Update local cache
      final currentSettings = await localDataSource.getSettings();
      final updatedSettings = currentSettings.copyWith(
        notificationsEnabled: enabled,
        vibrationOnly: vibrationOnly,
      );
      await localDataSource.cacheSettings(SettingsModel.fromEntity(updatedSettings));
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } on ConnectionTimeoutException {
      return Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateLanguage(String language) async {
    try {
      await remoteDataSource.updateLanguage(language);
      // Update local cache
      final currentSettings = await localDataSource.getSettings();
      final updatedSettings = currentSettings.copyWith(language: language);
      await localDataSource.cacheSettings(SettingsModel.fromEntity(updatedSettings));
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } on ConnectionTimeoutException {
      return Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateTheme(bool darkMode) async {
    try {
      await remoteDataSource.updateTheme(darkMode);
      // Update local cache
      final currentSettings = await localDataSource.getSettings();
      final updatedSettings = currentSettings.copyWith(darkMode: darkMode);
      await localDataSource.cacheSettings(SettingsModel.fromEntity(updatedSettings));
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } on ConnectionTimeoutException {
      return Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateSyncSettings({
    required bool autoSync,
    required int syncInterval,
  }) async {
    try {
      await remoteDataSource.updateSyncSettings(
        autoSync: autoSync,
        syncInterval: syncInterval,
      );
      // Update local cache
      final currentSettings = await localDataSource.getSettings();
      final updatedSettings = currentSettings.copyWith(
        autoSync: autoSync,
        syncInterval: syncInterval,
      );
      await localDataSource.cacheSettings(SettingsModel.fromEntity(updatedSettings));
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } on ConnectionTimeoutException {
      return Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateDataCollection(bool enabled) async {
    try {
      await remoteDataSource.updateDataCollection(enabled);
      // Update local cache
      final currentSettings = await localDataSource.getSettings();
      final updatedSettings = currentSettings.copyWith(dataCollectionEnabled: enabled);
      await localDataSource.cacheSettings(SettingsModel.fromEntity(updatedSettings));
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } on ConnectionTimeoutException {
      return Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateAnalytics(bool enabled) async {
    try {
      await remoteDataSource.updateAnalytics(enabled);
      // Update local cache
      final currentSettings = await localDataSource.getSettings();
      final updatedSettings = currentSettings.copyWith(analyticsEnabled: enabled);
      await localDataSource.cacheSettings(SettingsModel.fromEntity(updatedSettings));
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } on ConnectionTimeoutException {
      return Left(ConnectionFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
