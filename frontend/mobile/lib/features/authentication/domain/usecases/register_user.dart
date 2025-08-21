import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/authentication_repository.dart';

class RegisterUser {
  final AuthenticationRepository repository;

  RegisterUser({required this.repository});

  Future<Either<Failure, User>> call(
    String username,
    String password,
    String fullName,
    String contactNumber,
    String address,
    String role,
  ) async {
    return await repository.register(
      username,
      password,
      fullName,
      contactNumber,
      address,
      role, // Use the passed role instead of hardcoded 'user'
    );
  }
}
