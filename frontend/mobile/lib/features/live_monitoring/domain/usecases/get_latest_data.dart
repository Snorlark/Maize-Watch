import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/historical_repository.dart';

class GetLatestData implements UseCase<Map<String, dynamic>, String> {
  final HistoricalRepository repository;

  GetLatestData(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String farmId) async {
    return await repository.getLatestData(farmId);
  }
}
