// features/live_monitoring/data/datasources/weather_remote_data_source.dart
import 'package:dio/dio.dart';
import 'package:mobile/core/config/environment.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/weather_model.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherModel> getCurrentWeather(String farmId);
  Future<List<WeatherModel>> getWeatherForecast(String farmId, int days);
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final Dio dio;
  final SecureStorage secureStorage;

  // Base URL for internal analytics API
  final String _baseUrl = AppConfig.baseUrl;

  WeatherRemoteDataSourceImpl({required this.dio, required this.secureStorage});

  @override
  Future<WeatherModel> getCurrentWeather(String farmId) async {
    try {
      final token = await SecureStorage.getToken();
      if (token == null) {
        throw ServerException('Authentication token not found');
      }

      final response = await dio.get(
        '$_baseUrl/api/analytics/weather/current/$farmId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        print('🌐 Weather API Response: $responseData');
        
        if (responseData['success'] == true && responseData['data'] != null) {
          print('✅ Weather data received successfully from backend');
          return WeatherModel.fromInternalApi(responseData['data']);
        } else {
          print('❌ Invalid weather data response: $responseData');
          throw ServerException('Invalid weather data response');
        }
      } else {
        throw ServerException(
          'Failed to fetch weather data: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ServerException('Authentication failed');
      }
      throw ServerException('Network error: ${e.message}');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<List<WeatherModel>> getWeatherForecast(String farmId, int days) async {
    try {
      final token = await SecureStorage.getToken();
      if (token == null) {
        throw ServerException('Authentication token not found');
      }

      final response = await dio.get(
        '$_baseUrl/api/analytics/weather/forecast/$farmId',
        queryParameters: {'days': days},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true && responseData['data'] != null) {
          final List<dynamic> forecastList = responseData['data'];
          return forecastList
              .map((item) => WeatherModel.fromInternalApi(item))
              .toList();
        } else {
          throw ServerException('Invalid weather forecast response');
        }
      } else {
        throw ServerException(
          'Failed to fetch weather forecast: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ServerException('Authentication failed');
      }
      throw ServerException('Network error: ${e.message}');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Unexpected error: ${e.toString()}');
    }
  }
}
