// features/live_monitoring/domain/repositories/weather_repository.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/weather_data.dart';

abstract class WeatherRepository {
  Future<Either<Failure, WeatherData>> getCurrentWeather(String farmId);
  Future<Either<Failure, List<WeatherData>>> getWeatherForecast(String farmId, int days);
}
