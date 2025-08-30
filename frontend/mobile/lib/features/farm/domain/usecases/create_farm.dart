import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/farm.dart';
import '../repositories/farm_repository.dart';

class CreateFarm implements UseCase<Farm, CreateFarmParams> {
  final FarmRepository repository;

  CreateFarm(this.repository);

  @override
  Future<Either<Failure, Farm>> call(CreateFarmParams params) async {
    return await repository.createFarm(params.farm);
  }
}

class CreateFarmParams {
  final Farm farm;

  CreateFarmParams({required this.farm});
}
