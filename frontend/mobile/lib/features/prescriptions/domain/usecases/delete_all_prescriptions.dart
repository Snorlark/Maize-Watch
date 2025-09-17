import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/prescriptions/domain/repositories/prescription_repository.dart';

class DeleteAllPrescriptions implements UseCase<void, NoParams> {
  final PrescriptionRepository repository;

  const DeleteAllPrescriptions(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.deleteAllPrescriptions();
  }
}
