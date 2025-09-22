import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/storage/secure_storage.dart';

/// Use case to check if user is authenticated (has valid tokens)
class CheckAuthStatusUseCase {
  CheckAuthStatusUseCase();

  Future<Either<Failure, bool>> call() async {
    try {
      final hasToken = await SecureStorage.getToken();
      final isLoggedIn = await SecureStorage.isLoggedIn();
      final hasTokens = hasToken != null && isLoggedIn;
      return Right(hasTokens);
    } catch (e) {
      return Left(CacheFailure('Failed to check auth status: ${e.toString()}'));
    }
  }

  /// Get stored access token
  Future<String?> getAccessToken() async {
    return await SecureStorage.getToken();
  }

  /// Get stored refresh token
  Future<String?> getRefreshToken() async {
    return await SecureStorage.getRefreshToken();
  }
}
