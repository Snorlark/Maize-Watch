import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/settings/domain/entities/settings_entity.dart';
import 'package:mobile/features/settings/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';

class UpdateSettings implements UseCase<void, SettingsEntity> {
  final SettingsRepository repository;

  UpdateSettings(this.repository);

  @override
  Future<Either<Failure, void>> call(SettingsEntity settings) async {
    return await repository.updateSettings(settings);
  }
}

class UpdateNotificationSettings implements UseCase<void, NotificationSettingsParams> {
  final SettingsRepository repository;

  UpdateNotificationSettings(this.repository);

  @override
  Future<Either<Failure, void>> call(NotificationSettingsParams params) async {
    return await repository.updateNotificationSettings(
      enabled: params.enabled,
      vibrationOnly: params.vibrationOnly,
    );
  }
}

class UpdateLanguage implements UseCase<void, String> {
  final SettingsRepository repository;

  UpdateLanguage(this.repository);

  @override
  Future<Either<Failure, void>> call(String language) async {
    return await repository.updateLanguage(language);
  }
}

class UpdateTheme implements UseCase<void, bool> {
  final SettingsRepository repository;

  UpdateTheme(this.repository);

  @override
  Future<Either<Failure, void>> call(bool darkMode) async {
    return await repository.updateTheme(darkMode);
  }
}

class UpdateSyncSettings implements UseCase<void, SyncSettingsParams> {
  final SettingsRepository repository;

  UpdateSyncSettings(this.repository);

  @override
  Future<Either<Failure, void>> call(SyncSettingsParams params) async {
    return await repository.updateSyncSettings(
      autoSync: params.autoSync,
      syncInterval: params.syncInterval,
    );
  }
}

class UpdateDataCollection implements UseCase<void, bool> {
  final SettingsRepository repository;

  UpdateDataCollection(this.repository);

  @override
  Future<Either<Failure, void>> call(bool enabled) async {
    return await repository.updateDataCollection(enabled);
  }
}

class UpdateAnalytics implements UseCase<void, bool> {
  final SettingsRepository repository;

  UpdateAnalytics(this.repository);

  @override
  Future<Either<Failure, void>> call(bool enabled) async {
    return await repository.updateAnalytics(enabled);
  }
}

class NotificationSettingsParams {
  final bool enabled;
  final bool vibrationOnly;

  NotificationSettingsParams({
    required this.enabled,
    required this.vibrationOnly,
  });
}

class SyncSettingsParams {
  final bool autoSync;
  final int syncInterval;

  SyncSettingsParams({
    required this.autoSync,
    required this.syncInterval,
  });
}
