import 'package:equatable/equatable.dart';
import 'package:mobile/features/settings/domain/entities/settings_entity.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

class SettingsLoaded extends SettingsState {
  final SettingsEntity settings;
  final SensorStatusEntity? sensorStatus;

  const SettingsLoaded({
    required this.settings,
    this.sensorStatus,
  });

  @override
  List<Object?> get props => [settings, sensorStatus];
}

class SettingsError extends SettingsState {
  final String message;

  const SettingsError(this.message);

  @override
  List<Object?> get props => [message];
}

class SettingsUpdating extends SettingsState {
  final SettingsEntity settings;
  final SensorStatusEntity? sensorStatus;

  const SettingsUpdating({
    required this.settings,
    this.sensorStatus,
  });

  @override
  List<Object?> get props => [settings, sensorStatus];
}

class SettingsUpdated extends SettingsState {
  final SettingsEntity settings;
  final SensorStatusEntity? sensorStatus;
  final String message;

  const SettingsUpdated({
    required this.settings,
    this.sensorStatus,
    required this.message,
  });

  @override
  List<Object?> get props => [settings, sensorStatus, message];
}