import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthenticationRepository {
  Future<Either<Failure, User>> login(String username, String password);
  Future<Either<Failure, User>> register(
    String username,
    String password,
    String fullName,
    String contactNumber,
    String address,
    String role,
  );
}
