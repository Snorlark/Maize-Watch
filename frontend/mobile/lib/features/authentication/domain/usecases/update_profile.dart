import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/authentication_repository.dart';

class UpdateProfile {
  final AuthenticationRepository repository;

  UpdateProfile(this.repository);

  Future<Either<Failure, User>> call({
    required String userId,
    required String fullName,
    required String contactNumber,
    required Map<String, dynamic> address,
  }) async {
    return await repository.updateProfile(
      userId,
      fullName,
      contactNumber,
      address,
    );
  }
}
