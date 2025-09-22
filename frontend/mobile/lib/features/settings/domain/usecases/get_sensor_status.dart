import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/settings/domain/entities/settings_entity.dart';
import 'package:mobile/features/settings/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';

class GetSensorStatus implements UseCase<SensorStatusEntity, NoParams> {
  final SettingsRepository repository;

  GetSensorStatus(this.repository);

  @override
  Future<Either<Failure, SensorStatusEntity>> call(NoParams params) async {
    return await repository.getSensorStatus();
  }
}
