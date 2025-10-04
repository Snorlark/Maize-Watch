import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mobile/features/settings/domain/entities/settings_entity.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];

  // Add locale getter for compatibility
  Locale get locale {
    if (this is SettingsLoaded) {
      final state = this as SettingsLoaded;
      return state.settings.language == 'tl' ? const Locale('tl', 'PH') : const Locale('en', 'US');
    } else if (this is SettingsUpdated) {
      final state = this as SettingsUpdated;
      return state.settings.language == 'tl' ? const Locale('tl', 'PH') : const Locale('en', 'US');
    }
    return const Locale('en', 'US');
  }
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