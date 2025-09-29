import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class HistoricalRepository {
  Future<Either<Failure, Map<String, dynamic>>> getWeeklyData(String farmId, {String? fieldId, int? weekOffset});
  Future<Either<Failure, Map<String, dynamic>>> getLatestData(String farmId);
}
