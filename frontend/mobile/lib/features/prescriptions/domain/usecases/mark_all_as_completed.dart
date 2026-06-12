import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import 'package:mobile/features/prescriptions/domain/repositories/prescription_repository.dart';

class MarkAllAsCompleted implements UseCase<void, bool> {
  final PrescriptionRepository repository;

  MarkAllAsCompleted(this.repository);

  @override
  Future<Either<Failure, void>> call(bool isCompleted) async {
    return await repository.markAllAsCompleted(isCompleted);
  }
}
