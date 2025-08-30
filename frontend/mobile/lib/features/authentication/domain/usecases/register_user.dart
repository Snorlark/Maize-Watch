import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/authentication_repository.dart';

/// Register use case following clean architecture principles
class RegisterUser {
  final AuthenticationRepository repository;

  RegisterUser(this.repository);

  Future<Either<Failure, User>> call({
    required String username,
    required String password,
    required String fullName,
    required String contactNumber,
    required Map<String, dynamic> address,
    required String role,
  }) async {
    return await repository.register(
      username,
      password,
      fullName,
      contactNumber,
      address,
      role,
    );
  }
}
