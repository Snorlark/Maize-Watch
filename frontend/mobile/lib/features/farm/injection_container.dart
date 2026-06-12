import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'data/datasources/farm_remote_data_source.dart';
import 'data/repositories/farm_repository_impl.dart';
import 'domain/repositories/farm_repository.dart';
import 'domain/usecases/create_farm.dart';
import 'domain/usecases/get_user_farms.dart';
import 'domain/usecases/create_sensor.dart';
import 'domain/usecases/get_farm_analytics.dart';
import 'presentation/bloc/farm_bloc.dart';

final sl = GetIt.instance;

Future<void> initFarmFeature() async {
  // Use cases
  sl.registerLazySingleton(() => CreateFarm(sl()));
  sl.registerLazySingleton(() => GetUserFarms(sl()));
  sl.registerLazySingleton(() => CreateSensor(sl()));
  sl.registerLazySingleton(() => GetFarmAnalytics(sl()));

  // Repository
  sl.registerLazySingleton<FarmRepository>(
    () => FarmRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // BLoC
  sl.registerFactory(
    () => FarmBloc(
      createFarm: sl(),
      getUserFarms: sl(),
      createSensor: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<FarmRemoteDataSource>(
    () => FarmRemoteDataSourceImpl(
      client: sl(),
      dioClient: sl(),
    ),
  );

  // Core
  sl.registerLazySingleton(() => http.Client());
}
