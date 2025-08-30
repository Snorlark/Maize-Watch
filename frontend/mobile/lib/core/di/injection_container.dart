import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../features/authentication/domain/usecases/login_user.dart';
import '../../features/authentication/domain/usecases/register_user.dart';
import '../network/dio_interceptor.dart';
import '../../features/authentication/data/datasources/authentication_remote_data_source.dart';
import '../../features/authentication/data/repositories/authentication_repository_impl.dart';
import '../../features/authentication/domain/repositories/authentication_repository.dart';
import '../../features/authentication/presentation/bloc/authentication_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Network
  sl.registerLazySingleton<Dio>(
    () => DioFactory.create(
      baseUrl: 'http://10.250.104.206:8080',
    ),
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
}
