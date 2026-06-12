import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/settings/domain/entities/settings_entity.dart';
import 'package:mobile/features/settings/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';

class GetSettings implements UseCase<SettingsEntity, NoParams> {
  final SettingsRepository repository;

  GetSettings(this.repository);

  @override
  Future<Either<Failure, SettingsEntity>> call(NoParams params) async {
    return await repository.getSettings();
  }
}
