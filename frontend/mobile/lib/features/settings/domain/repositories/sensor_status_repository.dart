import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class SensorStatusRepository {
  Future<Either<Failure, Map<String, dynamic>>> getSensorStatus();
}
