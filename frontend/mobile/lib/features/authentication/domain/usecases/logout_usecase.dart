import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/storage/secure_storage.dart';

/// Logout use case following clean architecture principles
class LogoutUseCase {
  LogoutUseCase();

  Future<Either<Failure, void>> call() async {
    try {
      // Clear all stored tokens and user data
      await SecureStorage.clearUserSession();
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to logout: ${e.toString()}'));
    }
  }
}
