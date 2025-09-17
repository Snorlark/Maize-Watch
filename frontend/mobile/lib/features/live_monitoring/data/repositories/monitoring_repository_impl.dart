// features/live_monitoring/data/repositories/monitoring_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../domain/entities/sensor_reading.dart';
import '../../domain/repositories/monitoring_repository.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../datasources/monitoring_remote_datasource.dart';

class MonitoringRepositoryImpl implements MonitoringRepository {
  final MonitoringRemoteDataSource remoteDataSource;

  MonitoringRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<SensorReading>>> getLatestReadings() async {
    try {
      final readings = await remoteDataSource.getLatestReadings();
      return Right(readings.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get latest readings'));
    }
  }

  @override
  Future<Either<Failure, List<SensorReading>>> getHistoricalReadings(
    String farmId,
    int days,
  ) async {
    try {
      final readings = await remoteDataSource.getHistoricalReadings(
        farmId,
        days,
      );
      return Right(readings.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get historical readings'));
    }
  }

  @override
  Future<Either<Failure, List<SensorReading>>> getSensorReadings(
    String sensorId, {
    int? page,
    int? limit,
  }) async {
    try {
      final readings = await remoteDataSource.getSensorReadings(
        sensorId,
        page: page,
        limit: limit,
      );
      return Right(readings.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get sensor readings'));
    }
  }
}
