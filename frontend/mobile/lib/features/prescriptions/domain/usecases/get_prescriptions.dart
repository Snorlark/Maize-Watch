import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/prescriptions/domain/entities/prescription.dart';
import 'package:mobile/features/prescriptions/domain/repositories/prescription_repository.dart';

class GetPrescriptions implements UseCase<List<Prescription>, NoParams> {
  final PrescriptionRepository repository;

  GetPrescriptions(this.repository);

  @override
  Future<Either<Failure, List<Prescription>>> call(NoParams params) async {
    return await repository.getPrescriptions();
  }
}
