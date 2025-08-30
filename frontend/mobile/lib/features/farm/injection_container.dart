import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import '../../core/network/network_info.dart';
import 'data/datasources/farm_remote_data_source.dart';
import 'data/repositories/farm_repository_impl.dart';
import 'domain/repositories/farm_repository.dart';
import 'domain/usecases/create_farm.dart';
import 'domain/usecases/get_user_farms.dart';
import 'presentation/bloc/farm_bloc.dart';

final sl = GetIt.instance;

Future<void> initFarmFeature() async {
  // BLoC
  sl.registerFactory(
    () => FarmBloc(
      createFarm: sl(),
      getUserFarms: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => CreateFarm(sl()));
  sl.registerLazySingleton(() => GetUserFarms(sl()));

  // Repository
  sl.registerLazySingleton<FarmRepository>(
    () => FarmRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<FarmRemoteDataSource>(
    () => FarmRemoteDataSourceImpl(
      client: sl(),
    ),
  );

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  sl.registerLazySingleton(() => http.Client());
}
