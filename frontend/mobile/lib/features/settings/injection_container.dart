import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:mobile/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:mobile/features/settings/data/datasources/settings_remote_data_source.dart';
import 'package:mobile/features/settings/data/datasources/sensor_status_remote_data_source.dart';
import 'package:mobile/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:mobile/features/settings/data/repositories/sensor_status_repository_impl.dart';
import 'package:mobile/features/settings/domain/repositories/settings_repository.dart';
import 'package:mobile/features/settings/domain/repositories/sensor_status_repository.dart';
import 'package:mobile/features/settings/domain/usecases/get_settings.dart';
import 'package:mobile/features/settings/domain/usecases/get_sensor_status.dart';
import 'package:mobile/features/settings/domain/usecases/update_settings.dart' as update_usecases;
import 'package:mobile/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:mobile/features/settings/presentation/bloc/sensor_status_bloc.dart';

final sl = GetIt.instance;

Future<void> initSettings() async {
  // Data sources
  sl.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<SettingsRemoteDataSource>(
    () => SettingsRemoteDataSourceImpl(httpClient: sl<Dio>()),
  );

  sl.registerLazySingleton<SensorStatusRemoteDataSource>(
    () => SensorStatusRemoteDataSourceImpl(client: sl<Dio>()),
  );

  // Repository
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      remoteDataSource: sl<SettingsRemoteDataSource>(),
      localDataSource: sl<SettingsLocalDataSource>(),
    ),
  );

  sl.registerLazySingleton<SensorStatusRepository>(
    () => SensorStatusRepositoryImpl(remoteDataSource: sl<SensorStatusRemoteDataSource>()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetSettings(sl<SettingsRepository>()));
  sl.registerLazySingleton(() => GetSensorStatus(sl<SensorStatusRepository>()));
  sl.registerLazySingleton(() => update_usecases.UpdateSettings(sl<SettingsRepository>()));
  sl.registerLazySingleton(() => update_usecases.UpdateNotificationSettings(sl<SettingsRepository>()));
  sl.registerLazySingleton(() => update_usecases.UpdateLanguage(sl<SettingsRepository>()));
  sl.registerLazySingleton(() => update_usecases.UpdateTheme(sl<SettingsRepository>()));
  sl.registerLazySingleton(() => update_usecases.UpdateSyncSettings(sl<SettingsRepository>()));
  sl.registerLazySingleton(() => update_usecases.UpdateDataCollection(sl<SettingsRepository>()));
  sl.registerLazySingleton(() => update_usecases.UpdateAnalytics(sl<SettingsRepository>()));

  // BLoC
  sl.registerLazySingleton(
    () => SettingsBloc(
      getSettings: sl<GetSettings>(),
      getSensorStatus: sl<GetSensorStatus>(),
      updateSettings: sl<update_usecases.UpdateSettings>(),
      updateNotificationSettings: sl<update_usecases.UpdateNotificationSettings>(),
      updateLanguage: sl<update_usecases.UpdateLanguage>(),
      updateTheme: sl<update_usecases.UpdateTheme>(),
      updateSyncSettings: sl<update_usecases.UpdateSyncSettings>(),
      updateDataCollection: sl<update_usecases.UpdateDataCollection>(),
      updateAnalytics: sl<update_usecases.UpdateAnalytics>(),
    ),
  );

  sl.registerFactory(
    () => SensorStatusBloc(getSensorStatusUseCase: sl<GetSensorStatus>()),
  );
}
