import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/features/settings/domain/entities/settings_entity.dart';

abstract class SettingsRepository {
  Future<Either<Failure, SettingsEntity>> getSettings();
  Future<Either<Failure, void>> updateSettings(SettingsEntity settings);
  Future<Either<Failure, SensorStatusEntity>> getSensorStatus();
  Future<Either<Failure, void>> updateNotificationSettings({
    required bool enabled,
    required bool vibrationOnly,
  });
  Future<Either<Failure, void>> updateLanguage(String language);
  Future<Either<Failure, void>> updateTheme(bool darkMode);
  Future<Either<Failure, void>> updateSyncSettings({
    required bool autoSync,
    required int syncInterval,
  });
  Future<Either<Failure, void>> updateDataCollection(bool enabled);
  Future<Either<Failure, void>> updateAnalytics(bool enabled);
}
