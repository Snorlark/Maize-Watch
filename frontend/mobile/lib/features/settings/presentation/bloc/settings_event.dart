import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

class UpdateNotificationSettings extends SettingsEvent {
  final bool enabled;
  final bool vibrationOnly;

  const UpdateNotificationSettings({
    required this.enabled,
    required this.vibrationOnly,
  });

  @override
  List<Object?> get props => [enabled, vibrationOnly];
}

class UpdateLanguage extends SettingsEvent {
  final String language;

  const UpdateLanguage(this.language);

  @override
  List<Object?> get props => [language];
}

class UpdateTheme extends SettingsEvent {
  final bool darkMode;

  const UpdateTheme(this.darkMode);

  @override
  List<Object?> get props => [darkMode];
}

class UpdateSyncSettings extends SettingsEvent {
  final bool autoSync;
  final int syncInterval;

  const UpdateSyncSettings({
    required this.autoSync,
    required this.syncInterval,
  });

  @override
  List<Object?> get props => [autoSync, syncInterval];
}

class UpdateDataCollection extends SettingsEvent {
  final bool enabled;

  const UpdateDataCollection(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdateAnalytics extends SettingsEvent {
  final bool enabled;

  const UpdateAnalytics(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class LoadSensorStatus extends SettingsEvent {
  const LoadSensorStatus();
}

class RefreshSettings extends SettingsEvent {
  const RefreshSettings();
}