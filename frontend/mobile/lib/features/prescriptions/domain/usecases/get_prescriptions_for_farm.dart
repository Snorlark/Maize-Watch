import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/prescriptions/domain/entities/prescription.dart';
import 'package:mobile/features/prescriptions/domain/repositories/prescription_repository.dart';

class GetPrescriptionsForFarm implements UseCase<List<Prescription>, String> {
  final PrescriptionRepository repository;

  GetPrescriptionsForFarm(this.repository);

  @override
  Future<Either<Failure, List<Prescription>>> call(String farmId) async {
    return await repository.getPrescriptionsForFarm(farmId);
  }
}
