import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/sensor_status_repository.dart';
import '../datasources/sensor_status_remote_data_source.dart';

class SensorStatusRepositoryImpl implements SensorStatusRepository {
  final SensorStatusRemoteDataSource remoteDataSource;

  SensorStatusRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSensorStatus() async {
    try {
      final sensorStatus = await remoteDataSource.getSensorStatus();
      return Right(sensorStatus);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
