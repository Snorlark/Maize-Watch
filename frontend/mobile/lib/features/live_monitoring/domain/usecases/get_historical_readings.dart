import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/sensor_reading.dart';
import '../repositories/monitoring_repository.dart';

class GetHistoricalReadings {
  final MonitoringRepository repository;

  GetHistoricalReadings(this.repository);

  Future<Either<Failure, List<SensorReading>>> call(String farmId, int days) async {
    return await repository.getHistoricalReadings(farmId, days);
  }
}
