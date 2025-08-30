import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/authentication_repository.dart';

/// Login use case following clean architecture principles
class LoginUser {
  final AuthenticationRepository repository;

  LoginUser(this.repository);

  Future<Either<Failure, User>> call({
    required String username,
    required String password,
  }) async {
    return await repository.login(username, password);
  }
}
