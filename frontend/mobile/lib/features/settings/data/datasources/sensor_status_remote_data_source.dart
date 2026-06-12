import 'dart:async';
import 'package:dio/dio.dart';
import '../../../../core/config/environment.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/secure_storage.dart';

abstract class SensorStatusRemoteDataSource {
  Future<Map<String, dynamic>> getSensorStatus();
}

class SensorStatusRemoteDataSourceImpl implements SensorStatusRemoteDataSource {
  final Dio client;
  final String baseUrl = AppConfig.baseUrl;

  SensorStatusRemoteDataSourceImpl({required this.client});

  @override
  Future<Map<String, dynamic>> getSensorStatus() async {
    try {
      print("🔍 Frontend: Getting sensor status from: $baseUrl/api/settings/sensors/status");
      
      // Get the access token
      final accessToken = await SecureStorage.getToken();
      if (accessToken == null) {
        throw ServerException("No access token available");
      }

      final response = await client
          .get(
            '/settings/sensors/status',
            options: Options(
              headers: {
                'Authorization': 'Bearer $accessToken',
              },
            ),
          )
          .timeout(const Duration(seconds: 10));

      print("🔍 Frontend: Response status: ${response.statusCode}");
      print("🔍 Frontend: Response data: ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        print("🔍 Frontend: Sensor status data: $data");
        return data;
      } else {
        throw ServerException(
          response.data['message'] ?? "Failed to get sensor status",
        );
      }
    } on DioException catch (e) {
      print("🚨 Frontend: DioException during sensor status fetch: ${e.toString()}");
      print("🚨 Frontend: Response data: ${e.response?.data}");
      print("🚨 Frontend: Status code: ${e.response?.statusCode}");
      throw _mapDioError(e, "Failed to get sensor status");
    } catch (e) {
      print("🚨 Frontend: General exception during sensor status fetch: ${e.toString()}");
      throw ServerException("Failed to get sensor status: $e");
    }
  }

  ServerException _mapDioError(DioException e, String defaultMessage) {
    if (e.type == DioExceptionType.connectionTimeout) {
      return ServerException("Connection timed out. Please try again.");
    } else if (e.response != null) {
      return ServerException(e.response!.data['message'] ?? defaultMessage);
    } else {
      return ServerException("Network error: ${e.message}");
    }
  }
}
