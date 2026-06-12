import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/farm.dart';
import '../repositories/farm_repository.dart';

class GetUserFarms implements UseCase<List<Farm>, GetUserFarmsParams> {
  final FarmRepository repository;

  GetUserFarms(this.repository);

  @override
  Future<Either<Failure, List<Farm>>> call(GetUserFarmsParams params) async {
    return await repository.getUserFarms(params.userId);
  }
}

class GetUserFarmsParams {
  final String userId;

  GetUserFarmsParams({required this.userId});
}
