import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/farm_repository.dart';

class CreateSensor implements UseCase<void, CreateSensorParams> {
  final FarmRepository repository;

  CreateSensor(this.repository);

  @override
  Future<Either<Failure, void>> call(CreateSensorParams params) async {
    return await repository.createSensor(params.farmId, params.sensorData);
  }
}

class CreateSensorParams {
  final String farmId;
  final Map<String, dynamic> sensorData;

  CreateSensorParams({
    required this.farmId,
    required this.sensorData,
  });
}
