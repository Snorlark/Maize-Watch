// features/live_monitoring/data/repositories/weather_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/weather_data.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_remote_data_source.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  WeatherRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, WeatherData>> getCurrentWeather(String farmId) async {
    if (await networkInfo.isConnected) {
      try {
        final weatherData = await remoteDataSource.getCurrentWeather(farmId);
        return Right(weatherData);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<WeatherData>>> getWeatherForecast(String farmId, int days) async {
    if (await networkInfo.isConnected) {
      try {
        final forecastData = await remoteDataSource.getWeatherForecast(farmId, days);
        return Right(forecastData);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}
