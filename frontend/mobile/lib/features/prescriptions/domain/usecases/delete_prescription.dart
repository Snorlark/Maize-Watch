import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/prescriptions/domain/repositories/prescription_repository.dart';

class DeletePrescription implements UseCase<void, String> {
  final PrescriptionRepository repository;

  const DeletePrescription(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) async {
    if (id.isEmpty) {
      return const Left(ServerFailure('Invalid prescription ID'));
    }
    return await repository.deletePrescription(id);
  }
}
