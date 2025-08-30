import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/authentication_repository.dart';
import '../datasources/authentication_remote_data_source.dart';

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  final AuthenticationRemoteDataSource remoteDataSource;

  AuthenticationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, User>> login(String username, String password) async {
    try {
      final user = await remoteDataSource.login(username, password);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message)); // cleaner error
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> register(
    String username,
    String password,
    String fullName,
    String contactNumber,
    Map<String, dynamic> address,
    String role,
  ) async {
    try {
      // ✅ Always build proper payload here
      final userData = {
        "username": username,
        "password": password,
        "fullName": fullName,
        "contactNumber": contactNumber,
        "address": address,
        "role": role,
      };

      print("📤 Register payload: $userData");

      final user = await remoteDataSource.register(userData);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
