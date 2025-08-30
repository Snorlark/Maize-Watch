import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/secure_storage_service.dart';

/// Use case to check if user is authenticated (has valid tokens)
class CheckAuthStatusUseCase {
  final SecureStorageService secureStorage;

  CheckAuthStatusUseCase({required this.secureStorage});

  Future<Either<Failure, bool>> call() async {
    try {
      final hasTokens = await secureStorage.hasValidTokens();
      return Right(hasTokens);
    } catch (e) {
      return Left(CacheFailure('Failed to check auth status: ${e.toString()}'));
    }
  }

  /// Get stored access token
  Future<String?> getAccessToken() async {
    return await secureStorage.getAccessToken();
  }

  /// Get stored refresh token
  Future<String?> getRefreshToken() async {
    return await secureStorage.getRefreshToken();
  }
}
