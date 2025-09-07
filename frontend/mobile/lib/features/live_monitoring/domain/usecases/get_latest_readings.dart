// features/live_monitoring/domain/usecases/get_latest_readings.dart
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/sensor_reading.dart';
import '../repositories/monitoring_repository.dart';

class GetLatestReadings {
  final MonitoringRepository repository;

  GetLatestReadings(this.repository);

  Future<Either<Failure, List<SensorReading>>> call() async {
    return await repository.getLatestReadings();
  }
}
