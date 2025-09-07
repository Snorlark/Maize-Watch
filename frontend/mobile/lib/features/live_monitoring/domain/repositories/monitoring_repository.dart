import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/sensor_reading.dart';

abstract class MonitoringRepository {
  Future<Either<Failure, List<SensorReading>>> getLatestReadings();
  Future<Either<Failure, List<SensorReading>>> getHistoricalReadings(
    String farmId,
    int days,
  );
  Future<Either<Failure, List<SensorReading>>> getSensorReadings(
    String sensorId, {
    int? page,
    int? limit,
  });
}
