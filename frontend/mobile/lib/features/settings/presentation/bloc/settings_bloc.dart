import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/settings/domain/entities/settings_entity.dart';
import 'package:mobile/features/settings/domain/usecases/get_settings.dart';
import 'package:mobile/features/settings/domain/usecases/get_sensor_status.dart';
import 'package:mobile/features/settings/domain/usecases/update_settings.dart' as update_usecases;
import 'package:mobile/features/settings/presentation/bloc/settings_event.dart';
import 'package:mobile/features/settings/presentation/bloc/settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetSettings getSettings;
  final GetSensorStatus getSensorStatus;
  final update_usecases.UpdateSettings updateSettings;
  final update_usecases.UpdateNotificationSettings updateNotificationSettings;
  final update_usecases.UpdateLanguage updateLanguage;
  final update_usecases.UpdateTheme updateTheme;
  final update_usecases.UpdateSyncSettings updateSyncSettings;
  final update_usecases.UpdateDataCollection updateDataCollection;
  final update_usecases.UpdateAnalytics updateAnalytics;

  SettingsBloc({
    required this.getSettings,
    required this.getSensorStatus,
    required this.updateSettings,
    required this.updateNotificationSettings,
    required this.updateLanguage,
    required this.updateTheme,
    required this.updateSyncSettings,
    required this.updateDataCollection,
    required this.updateAnalytics,
  }) : super(const SettingsInitial()) {
    print("🔧 SettingsBloc: Constructor called - SettingsBloc created");
    on<LoadSettings>(_onLoadSettings);
    on<UpdateNotificationSettings>(_onUpdateNotificationSettings);
    on<UpdateLanguage>(_onUpdateLanguage);
    on<UpdateTheme>(_onUpdateTheme);
    on<UpdateSyncSettings>(_onUpdateSyncSettings);
    on<UpdateDataCollection>(_onUpdateDataCollection);
    on<UpdateAnalytics>(_onUpdateAnalytics);
    on<LoadSensorStatus>(_onLoadSensorStatus);
    on<RefreshSettings>(_onRefreshSettings);
  }

  Future<void> _onLoadSettings(LoadSettings event, Emitter<SettingsState> emit) async {
    print("🔧 SettingsBloc: Starting to load settings...");
    emit(const SettingsLoading());
    
    try {
      print("🔧 SettingsBloc: Calling getSettings use case...");
      final result = await getSettings(NoParams());
      print("🔧 SettingsBloc: getSettings result received");
      
      await result.fold(
        (failure) async {
          print("🔧 SettingsBloc: Settings failed with error: ${failure.toString()}");
          emit(SettingsError('Failed to load settings: ${failure.toString()}'));
        },
        (settings) async {
          print("🔧 SettingsBloc: Settings loaded successfully - emitting immediately");
          // Load settings immediately without waiting for sensor status
          emit(SettingsLoaded(settings: settings));
        },
      );
    } catch (e) {
      print("🔧 SettingsBloc: Unexpected error loading settings: $e");
      emit(SettingsError('Unexpected error loading settings: $e'));
    }
  }

  Future<void> _onUpdateNotificationSettings(
    UpdateNotificationSettings event,
    Emitter<SettingsState> emit,
  ) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      
      // Update immediately for instant response
      final updatedSettings = currentState.settings.copyWith(
        notificationsEnabled: event.enabled,
        vibrationOnly: event.vibrationOnly,
      );
      
      emit(SettingsUpdated(
        settings: updatedSettings,
        sensorStatus: currentState.sensorStatus,
        message: 'Notification settings updated',
      ));

      // Update backend in background (non-blocking)
      updateNotificationSettings(update_usecases.NotificationSettingsParams(
        enabled: event.enabled,
        vibrationOnly: event.vibrationOnly,
      )).then((result) {
        result.fold(
          (failure) => print("🔧 SettingsBloc: Background notification update failed: $failure"),
          (_) => print("🔧 SettingsBloc: Background notification update successful"),
        );
      });
    }
  }

  Future<void> _onUpdateLanguage(UpdateLanguage event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      emit(SettingsUpdating(
        settings: currentState.settings,
        sensorStatus: currentState.sensorStatus,
      ));

      final result = await updateLanguage(event.language);

      result.fold(
        (failure) => emit(SettingsError('Failed to update language')),
        (_) {
          final updatedSettings = currentState.settings.copyWith(language: event.language);
          emit(SettingsUpdated(
            settings: updatedSettings,
            sensorStatus: currentState.sensorStatus,
            message: 'Language updated',
          ));
        },
      );
    }
  }

  Future<void> _onUpdateTheme(UpdateTheme event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      emit(SettingsUpdating(
        settings: currentState.settings,
        sensorStatus: currentState.sensorStatus,
      ));

      final result = await updateTheme(event.darkMode);

      result.fold(
        (failure) => emit(SettingsError('Failed to update theme')),
        (_) {
          final updatedSettings = currentState.settings.copyWith(darkMode: event.darkMode);
          emit(SettingsUpdated(
            settings: updatedSettings,
            sensorStatus: currentState.sensorStatus,
            message: 'Theme updated',
          ));
        },
      );
    }
  }

  Future<void> _onUpdateSyncSettings(UpdateSyncSettings event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      emit(SettingsUpdating(
        settings: currentState.settings,
        sensorStatus: currentState.sensorStatus,
      ));

      final result = await updateSyncSettings(update_usecases.SyncSettingsParams(
        autoSync: event.autoSync,
        syncInterval: event.syncInterval,
      ));

      result.fold(
        (failure) => emit(SettingsError('Failed to update sync settings')),
        (_) {
          final updatedSettings = currentState.settings.copyWith(
            autoSync: event.autoSync,
            syncInterval: event.syncInterval,
          );
          emit(SettingsUpdated(
            settings: updatedSettings,
            sensorStatus: currentState.sensorStatus,
            message: 'Sync settings updated',
          ));
        },
      );
    }
  }

  Future<void> _onUpdateDataCollection(UpdateDataCollection event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      emit(SettingsUpdating(
        settings: currentState.settings,
        sensorStatus: currentState.sensorStatus,
      ));

      final result = await updateDataCollection(event.enabled);

      result.fold(
        (failure) => emit(SettingsError('Failed to update data collection')),
        (_) {
          final updatedSettings = currentState.settings.copyWith(dataCollectionEnabled: event.enabled);
          emit(SettingsUpdated(
            settings: updatedSettings,
            sensorStatus: currentState.sensorStatus,
            message: 'Data collection settings updated',
          ));
        },
      );
    }
  }

  Future<void> _onUpdateAnalytics(UpdateAnalytics event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      emit(SettingsUpdating(
        settings: currentState.settings,
        sensorStatus: currentState.sensorStatus,
      ));

      final result = await updateAnalytics(event.enabled);

      result.fold(
        (failure) => emit(SettingsError('Failed to update analytics')),
        (_) {
          final updatedSettings = currentState.settings.copyWith(analyticsEnabled: event.enabled);
          emit(SettingsUpdated(
            settings: updatedSettings,
            sensorStatus: currentState.sensorStatus,
            message: 'Analytics settings updated',
          ));
        },
      );
    }
  }

  Future<void> _onLoadSensorStatus(LoadSensorStatus event, Emitter<SettingsState> emit) async {
    if (state is SettingsLoaded) {
      final currentState = state as SettingsLoaded;
      
      final result = await getSensorStatus();
      result.fold(
        (failure) => emit(SettingsError('Failed to load sensor status')),
        (sensorStatusMap) {
          // Convert Map<String, dynamic> to SensorStatusEntity
          final sensorStatus = SensorStatusEntity(
            ldrSensor: sensorStatusMap['ldr'] ?? false,
            phLevelSensor: sensorStatusMap['ph'] ?? false,
            tempAndHumidSensor: sensorStatusMap['dht'] ?? false,
            soilLevelSensor: sensorStatusMap['soil'] ?? false,
          );
          
          emit(SettingsLoaded(
            settings: currentState.settings,
            sensorStatus: sensorStatus,
          ));
        },
      );
    }
  }

  Future<void> _onRefreshSettings(RefreshSettings event, Emitter<SettingsState> emit) async {
    add(const LoadSettings());
  }
}