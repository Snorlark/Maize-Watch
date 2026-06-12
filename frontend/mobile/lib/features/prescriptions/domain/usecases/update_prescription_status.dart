import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/prescriptions/domain/repositories/prescription_repository.dart';

class UpdatePrescriptionStatus implements UseCase<void, UpdatePrescriptionStatusParams> {
  final PrescriptionRepository repository;

  UpdatePrescriptionStatus(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdatePrescriptionStatusParams params) async {
    return await repository.updatePrescriptionStatus(
      fieldId: params.fieldId,
      prescriptionId: params.prescriptionId,
      isCompleted: params.isCompleted,
    );
  }
}

class UpdatePrescriptionStatusParams {
  final String fieldId;
  final String prescriptionId;
  final bool isCompleted;

  UpdatePrescriptionStatusParams({
    required this.fieldId,
    required this.prescriptionId,
    required this.isCompleted,
  });
}
