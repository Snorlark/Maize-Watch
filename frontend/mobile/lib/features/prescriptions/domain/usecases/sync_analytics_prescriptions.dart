import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/prescriptions/domain/repositories/prescription_repository.dart';

class SyncAnalyticsPrescriptions implements UseCase<Map<String, dynamic>, SyncAnalyticsPrescriptionsParams> {
  final PrescriptionRepository repository;

  SyncAnalyticsPrescriptions(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(SyncAnalyticsPrescriptionsParams params) async {
    return await repository.syncAnalyticsPrescriptions(params.farmId, params.prescriptions);
  }
}

class SyncAnalyticsPrescriptionsParams {
  final String farmId;
  final List<Map<String, dynamic>> prescriptions;

  SyncAnalyticsPrescriptionsParams({
    required this.farmId,
    required this.prescriptions,
  });
}
