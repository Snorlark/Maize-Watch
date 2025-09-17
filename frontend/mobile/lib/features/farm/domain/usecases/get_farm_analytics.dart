// features/farm/domain/usecases/get_farm_analytics.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/farm_repository.dart';

class GetFarmAnalytics implements UseCase<Map<String, dynamic>, String> {
  final FarmRepository repository;

  GetFarmAnalytics(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String farmId) async {
    return await repository.getFarmAnalytics(farmId);
  }
}
