import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/historical_repository.dart';

class GetWeeklyData implements UseCase<Map<String, dynamic>, GetWeeklyDataParams> {
  final HistoricalRepository repository;

  GetWeeklyData(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(GetWeeklyDataParams params) async {
    return await repository.getWeeklyData(
      params.farmId,
      fieldId: params.fieldId,
      weekOffset: params.weekOffset,
    );
  }
}

class GetWeeklyDataParams {
  final String farmId;
  final String? fieldId;
  final int? weekOffset;

  GetWeeklyDataParams({
    required this.farmId,
    this.fieldId,
    this.weekOffset,
  });
}
