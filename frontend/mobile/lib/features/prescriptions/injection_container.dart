import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../../core/network/network_info.dart';
import '../../core/services/socket_service.dart';
import 'data/datasources/prescription_local_data_source.dart';
import 'data/datasources/prescription_remote_data_source.dart';
import 'data/repositories/prescription_repository_impl.dart';
import 'domain/repositories/prescription_repository.dart';
import 'domain/usecases/get_prescriptions.dart';
import 'domain/usecases/update_prescription_status.dart';
import 'domain/usecases/delete_prescription.dart';
import 'domain/usecases/mark_all_as_completed.dart';
import 'domain/usecases/delete_completed_prescriptions.dart';
import 'domain/usecases/delete_all_prescriptions.dart';
import 'domain/usecases/sync_analytics_prescriptions.dart';
import 'presentation/bloc/prescription_bloc.dart';

final sl = GetIt.instance;

Future<void> initPrescriptionFeature() async {
  // Data sources
  sl.registerLazySingleton<PrescriptionLocalDataSource>(
    () => PrescriptionLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<PrescriptionRemoteDataSource>(
    () => PrescriptionRemoteDataSourceImpl(
      httpClient: sl<Dio>(),
    ),
  );

  // Repository
  sl.registerLazySingleton<PrescriptionRepository>(
    () => PrescriptionRepositoryImpl(
      localDataSource: sl<PrescriptionLocalDataSource>(),
      remoteDataSource: sl<PrescriptionRemoteDataSource>(),
      networkInfo: sl<NetworkInfo>(),
      socketService: sl<SocketService>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetPrescriptions(sl<PrescriptionRepository>()));
  sl.registerLazySingleton(() => UpdatePrescriptionStatus(sl<PrescriptionRepository>()));
  sl.registerLazySingleton(() => DeletePrescription(sl<PrescriptionRepository>()));
  sl.registerLazySingleton(() => MarkAllAsCompleted(sl<PrescriptionRepository>()));
  sl.registerLazySingleton(() => DeleteCompletedPrescriptions(sl<PrescriptionRepository>()));
  sl.registerLazySingleton(() => DeleteAllPrescriptions(sl<PrescriptionRepository>()));
  sl.registerLazySingleton(() => SyncAnalyticsPrescriptions(sl<PrescriptionRepository>()));

  // BLoC
  sl.registerLazySingleton(
    () => PrescriptionBloc(
      getPrescriptions: sl<GetPrescriptions>(),
      updatePrescriptionStatus: sl<UpdatePrescriptionStatus>(),
      deletePrescription: sl<DeletePrescription>(),
      markAllAsCompleted: sl<MarkAllAsCompleted>(),
      deleteCompletedPrescriptions: sl<DeleteCompletedPrescriptions>(),
      deleteAllPrescriptions: sl<DeleteAllPrescriptions>(),
      syncAnalyticsPrescriptions: sl<SyncAnalyticsPrescriptions>(),
    ),
  );
}
