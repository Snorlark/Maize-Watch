import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../../core/storage/secure_storage.dart';
import 'data/datasources/analytics_remote_data_source.dart';
import 'data/repositories/analytics_repository_impl.dart';
import 'domain/repositories/analytics_repository.dart';
import 'presentation/bloc/analytics_bloc.dart';

final sl = GetIt.instance;

Future<void> initAnalyticsFeature() async {
  // Data sources
  sl.registerLazySingleton<AnalyticsRemoteDataSource>(
    () => AnalyticsRemoteDataSourceImpl(
      dio: sl<Dio>(),
      secureStorage: sl<SecureStorage>(),
    ),
  );

  // Repository
  sl.registerLazySingleton<AnalyticsRepository>(
    () => AnalyticsRepositoryImpl(
      remoteDataSource: sl<AnalyticsRemoteDataSource>(),
    ),
  );

  // BLoC
  sl.registerLazySingleton(
    () => AnalyticsBloc(
      repository: sl<AnalyticsRepository>(),
    ),
  );
}
