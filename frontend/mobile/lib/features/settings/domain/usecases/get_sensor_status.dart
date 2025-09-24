import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/sensor_status_repository.dart';

class GetSensorStatus {
  final SensorStatusRepository repository;

  GetSensorStatus(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call() async {
    return await repository.getSensorStatus();
  }
}