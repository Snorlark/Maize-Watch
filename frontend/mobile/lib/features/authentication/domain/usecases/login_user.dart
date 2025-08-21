import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/authentication_repository.dart';

class LoginUser {
  final AuthenticationRepository repository;

  LoginUser({required this.repository});

  Future<Either<Failure, User>> call(String username, String password) async {
    return await repository.login(username, password);
  }
}
