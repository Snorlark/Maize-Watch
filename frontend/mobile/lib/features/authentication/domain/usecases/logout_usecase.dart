import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/services/secure_storage_service.dart';

/// Logout use case following clean architecture principles
class LogoutUseCase {
  final SecureStorageService secureStorage;

  LogoutUseCase({required this.secureStorage});

  Future<Either<Failure, void>> call() async {
    try {
      // Clear all stored tokens and user data
      await secureStorage.clearTokens();
      
      // You can also clear other user-specific data if needed
      // await secureStorage.clearUserData('user_preferences');
      // await secureStorage.clearUserData('farm_data');
      
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to logout: ${e.toString()}'));
    }
  }
}
