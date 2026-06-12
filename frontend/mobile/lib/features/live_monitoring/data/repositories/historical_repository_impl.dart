import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../datasources/historical_remote_data_source.dart';
import '../../domain/repositories/historical_repository.dart';

class HistoricalRepositoryImpl implements HistoricalRepository {
  final HistoricalRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  HistoricalRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> getWeeklyData(String farmId, {String? fieldId, int? weekOffset}) async {
    try {
      final result = await remoteDataSource.getWeeklyData(farmId, fieldId: fieldId, weekOffset: weekOffset);
      return Right(result);
    } on ServerException {
      return Left(ServerFailure());
    } catch (_) {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getLatestData(String farmId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getLatestData(farmId);
        return Right(result);
      } on ServerException {
        return Left(ServerFailure());
      } catch (_) {
        return Left(NetworkFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
