// features/live_monitoring/domain/usecases/get_current_weather.dart
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/weather_data.dart';
import '../repositories/weather_repository.dart';

class GetCurrentWeather {
  final WeatherRepository repository;

  GetCurrentWeather(this.repository);

  Future<Either<Failure, WeatherData>> call(String farmId) async {
    return await repository.getCurrentWeather(farmId);
  }
}
