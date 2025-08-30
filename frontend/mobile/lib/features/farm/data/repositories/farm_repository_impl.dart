import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/farm.dart';
import '../../domain/repositories/farm_repository.dart';
import '../datasources/farm_remote_data_source.dart';
import '../models/farm_model.dart';

class FarmRepositoryImpl implements FarmRepository {
  final FarmRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  FarmRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Farm>> createFarm(Farm farm) async {
    if (await networkInfo.isConnected) {
      try {
        final farmModel = FarmModel.fromEntity(farm);
        final result = await remoteDataSource.createFarm(farmModel);
        return Right(result);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, List<Farm>>> getUserFarms(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getUserFarms(userId);
        return Right(result);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Farm>> getFarmById(String farmId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.getFarmById(farmId);
        return Right(result);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Farm>> updateFarm(Farm farm) async {
    if (await networkInfo.isConnected) {
      try {
        final farmModel = FarmModel.fromEntity(farm);
        final result = await remoteDataSource.updateFarm(farmModel);
        return Right(result);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteFarm(String farmId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteFarm(farmId);
        return const Right(null);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Farm>> linkDevice(String farmId, String deviceId, String? macAddress) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.linkDevice(farmId, deviceId, macAddress);
        return Right(result);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, Farm>> unlinkDevice(String farmId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.unlinkDevice(farmId);
        return Right(result);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
