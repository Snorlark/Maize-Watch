import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../features/authentication/domain/usecases/login_user.dart';
import '../../features/authentication/domain/usecases/register_user.dart';
import '../../features/live_monitoring/data/datasources/monitoring_remote_datasource.dart';
import '../../features/live_monitoring/data/repositories/monitoring_repository_impl.dart';
import '../../features/live_monitoring/domain/repositories/monitoring_repository.dart';
import '../../features/live_monitoring/domain/usecases/get_latest_readings.dart';
import '../../features/live_monitoring/domain/usecases/get_historical_readings.dart';
import '../../features/live_monitoring/domain/usecases/get_current_weather.dart';
import '../../features/live_monitoring/data/datasources/weather_remote_data_source.dart';
import '../../features/live_monitoring/data/repositories/weather_repository_impl.dart';
import '../../features/live_monitoring/domain/repositories/weather_repository.dart';
import '../../features/live_monitoring/presentation/bloc/monitoring_bloc.dart';
import '../../features/farm/domain/usecases/get_farm_analytics.dart';
import '../storage/secure_storage.dart';
import '../network/network_info.dart';
import '../network/dio_interceptor.dart';
import '../../features/authentication/data/datasources/authentication_remote_data_source.dart';
import '../../features/authentication/data/repositories/authentication_repository_impl.dart';
import '../../features/authentication/domain/repositories/authentication_repository.dart';
import '../../features/authentication/presentation/bloc/authentication_bloc.dart';
import '../config/environment.dart';
import '../../features/farm/injection_container.dart' as farm_di;
import '../../features/live_monitoring/injection_container.dart' as analytics_di;

final sl = GetIt.instance;

Future<void> init() async {
  // Network
  sl.registerLazySingleton<Dio>(
    () => DioFactory.create(baseUrl: AppConfig.baseUrl),
  );

  // Data sources
  sl.registerLazySingleton<AuthenticationRemoteDataSource>(
    () => AuthenticationRemoteDataSourceImpl(client: sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthenticationRepository>(
    () => AuthenticationRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => RegisterUser(sl()));

  // BLoCs
  sl.registerFactory(
    () => AuthenticationBloc(loginUseCase: sl(), registerUseCase: sl()),
  );

  // Initialize farm feature dependencies
  await farm_di.initFarmFeature();
  
  // Initialize analytics feature dependencies
  await analytics_di.initAnalyticsFeature();

  sl.registerLazySingleton<MonitoringRemoteDataSource>(
    () => MonitoringRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // Weather data sources
  sl.registerLazySingleton<WeatherRemoteDataSource>(
    () => WeatherRemoteDataSourceImpl(
      dio: sl<Dio>(),
      secureStorage: sl<SecureStorage>(),
    ),
  );

  // Core services
  sl.registerLazySingleton<SecureStorage>(() => SecureStorage());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  // Repositories
  sl.registerLazySingleton<MonitoringRepository>(
    () => MonitoringRepositoryImpl(
      remoteDataSource: sl<MonitoringRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<WeatherRepository>(
    () => WeatherRepositoryImpl(
      remoteDataSource: sl<WeatherRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetLatestReadings(sl<MonitoringRepository>()));
  sl.registerLazySingleton(
    () => GetHistoricalReadings(sl<MonitoringRepository>()),
  );
  sl.registerLazySingleton(() => GetCurrentWeather(sl<WeatherRepository>()));

  // BLoCs
  sl.registerFactory(
    () => MonitoringBloc(
      getLatestReadings: sl<GetLatestReadings>(),
      getHistoricalReadings: sl<GetHistoricalReadings>(),
      getCurrentWeather: sl<GetCurrentWeather>(),
      getFarmAnalytics: sl<GetFarmAnalytics>(),
    ),
  );
}
