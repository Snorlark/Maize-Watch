import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/config/environment.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/farm_model.dart';
import '../../domain/entities/farm.dart';

abstract class FarmRemoteDataSource {
  Future<FarmModel> createFarm(FarmModel farm);
  Future<FarmModel> createFarmWithField(Farm farm, Map<String, dynamic> fieldData);
  Future<List<FarmModel>> getUserFarms(String userId);
  Future<FarmModel> getFarmById(String farmId);
  Future<FarmModel> updateFarm(FarmModel farm);
  Future<void> deleteFarm(String farmId);
  Future<FarmModel> linkDevice(
    String farmId,
    String deviceId,
    String? macAddress,
  );
  Future<FarmModel> unlinkDevice(String farmId);
  Future<void> createSensor(String farmId, Map<String, dynamic> sensorData);
  Future<Map<String, dynamic>> getFarmAnalytics(String farmId);
}

class FarmRemoteDataSourceImpl implements FarmRemoteDataSource {
  final http.Client client;
  final Dio dioClient;

  FarmRemoteDataSourceImpl({required this.client, required this.dioClient});

  Future<Map<String, String>> _authHeaders() async {
    final token = await SecureStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<String?> _refreshTokenIfNeeded() async {
    try {
      final refreshToken = await SecureStorage.getRefreshToken();
      final currentToken = await SecureStorage.getToken();
      
      print('🔄 Attempting token refresh...');
      print('🔄 Has refresh token: ${refreshToken != null}');
      print('🔄 Has access token: ${currentToken != null}');
      
      if (refreshToken == null) {
        if (currentToken != null) {
          print('🔄 No refresh token, returning current access token');
          return currentToken;
        }
        print('🔄 No tokens available');
        throw ServerException("No refresh token available");
      }

      print('🔄 Making refresh request to backend...');
      final response = await dioClient.post(
        '${AppConfig.baseUrl}/api/auth/refresh',
        data: {"refreshToken": refreshToken},
        options: Options(
          contentType: Headers.jsonContentType,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      print('🔄 Refresh response status: ${response.statusCode}');
      print('🔄 Refresh response data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final newAccessToken = response.data['data']['accessToken'];
        await SecureStorage.storeTokens(newAccessToken, refreshToken);
        print('🔄 Token refreshed successfully');
        return newAccessToken;
      } else {
        print('🔄 Token refresh failed, clearing session');
        await SecureStorage.clearUserSession();
        throw ServerException("Authentication expired. Please log in again.");
      }
    } catch (e) {
      print('🔄 Token refresh error: $e');
      await SecureStorage.clearUserSession();
      throw ServerException("Authentication expired. Please log in again.");
    }
  }


  @override
  Future<FarmModel> createFarm(FarmModel farm) async {
    try {
      final apiPayload = farm.toApiJson();
      print('🚀 Frontend: Sending farm creation request');
      print('🚀 API Payload: ${json.encode(apiPayload)}');
      print('🚀 Farm Name: ${apiPayload['farmName']}');
      print('🚀 Fields Count: ${(apiPayload['fields'] as List).length}');
      
      if ((apiPayload['fields'] as List).isNotEmpty) {
        final fields = apiPayload['fields'] as List;
        for (int i = 0; i < fields.length; i++) {
          final field = fields[i];
          print('🚀 Field ${i + 1}: ${json.encode(field)}');
        }
      }

      // First attempt
      var response = await client.post(
        Uri.parse('${AppConfig.baseUrl}/api/farms'),
        headers: await _authHeaders(),
        body: json.encode(apiPayload),
      );

      print('🚀 Response Status: ${response.statusCode}');
      print('🚀 Response Body: ${response.body}');

      // If token expired, try to refresh and retry
      if (response.statusCode == 401) {
        final responseBody = json.decode(response.body);
        if (responseBody['message']?.toString().contains('jwt expired') == true ||
            responseBody['message']?.toString().contains('TokenExpiredError') == true) {
          
          try {
            // Try to refresh token
            await _refreshTokenIfNeeded();
            
            // Retry with new token
            print('🔄 Retrying farm creation with refreshed token');
            response = await client.post(
              Uri.parse('${AppConfig.baseUrl}/api/farms'),
              headers: await _authHeaders(),
              body: json.encode(apiPayload),
            );
            print('🔄 Retry Response Status: ${response.statusCode}');
            print('🔄 Retry Response Body: ${response.body}');
          } catch (refreshError) {
            // If refresh fails, clear all tokens and throw authentication error
            await SecureStorage.clearUserSession();
            throw ServerException('Authentication expired. Please log in again.');
          }
        }
      }

      if (response.statusCode == 201) {
        print('✅ Farm created successfully');
        final responseData = json.decode(response.body);
        print('✅ Response data: ${json.encode(responseData)}');
        return FarmModel.fromJson(responseData['data']['farm']);
      } else if (response.statusCode == 401) {
        // Still unauthorized after refresh attempt - clear session
        print('🚨 Still unauthorized after refresh attempt');
        await SecureStorage.clearUserSession();
        throw ServerException('Authentication expired. Please log in again.');
      } else {
        print('🚨 Farm creation failed with status: ${response.statusCode}');
        final responseBody = json.decode(response.body);
        print('🚨 Error response: ${json.encode(responseBody)}');
        throw ServerException(responseBody['message'] ?? 'Failed to create farm');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Network error: Failed to create farm - $e');
    }
  }

  @override
  Future<List<FarmModel>> getUserFarms(String userId) async {
    try {
      // Backend uses authenticated user; userId param not required
      final response = await client.get(
        Uri.parse('${AppConfig.baseUrl}/api/farms'),
        headers: await _authHeaders(),
      );

      print('🌽 Farm API Response: ${response.statusCode}');
      print('🌽 Farm API Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> farmsJson = responseData['data']['farms'];
        return farmsJson.map((json) => FarmModel.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw ServerException('Authentication expired. Please log in again.');
      } else if (response.statusCode >= 500) {
        throw ServerException('Server error. Please try again later.');
      } else {
        final responseData = json.decode(response.body);
        final message = responseData['message'] ?? 'Failed to load farms';
        throw ServerException(message);
      }
    } catch (e) {
      print('🚨 Farm loading error: $e');
      if (e is ServerException) {
        rethrow;
      }
      // Network or other errors
      throw ServerException('Network error. Please check your internet connection.');
    }
  }

  @override
  Future<FarmModel> getFarmById(String farmId) async {
    final response = await client.get(
      Uri.parse('${AppConfig.baseUrl}/api/farms/$farmId'),
      headers: await _authHeaders(),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return FarmModel.fromJson(responseData['data']['farm']);
    } else {
      throw ServerException('Failed to load farm');
    }
  }

  @override
  Future<FarmModel> updateFarm(FarmModel farm) async {
    final response = await client.put(
      Uri.parse('${AppConfig.baseUrl}/api/farms/${farm.id}'),
      headers: await _authHeaders(),
      body: json.encode(farm.toJson()),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return FarmModel.fromJson(responseData['data']['farm']);
    } else {
      throw ServerException('Failed to update farm');
    }
  }

  @override
  Future<void> deleteFarm(String farmId) async {
    final response = await client.delete(
      Uri.parse('${AppConfig.baseUrl}/api/farms/$farmId'),
      headers: await _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw ServerException('Failed to delete farm');
    }
  }

  @override
  Future<FarmModel> linkDevice(
    String farmId,
    String deviceId,
    String? macAddress,
  ) async {
    final response = await client.post(
      Uri.parse('${AppConfig.baseUrl}/api/farms/$farmId/link-device'),
      headers: await _authHeaders(),
      body: json.encode({
        'deviceId': deviceId,
        if (macAddress != null) 'macAddress': macAddress,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return FarmModel.fromJson(responseData['data']['farm']);
    } else {
      throw ServerException('Failed to link device');
    }
  }

  @override
  Future<FarmModel> unlinkDevice(String farmId) async {
    final response = await client.delete(
      Uri.parse('${AppConfig.baseUrl}/api/farms/$farmId/unlink-device'),
      headers: await _authHeaders(),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return FarmModel.fromJson(responseData['data']['farm']);
    } else {
      throw ServerException('Failed to unlink device');
    }
  }

  @override
  Future<FarmModel> createFarmWithField(Farm farm, Map<String, dynamic> fieldData) async {
    try {
      // Prepare the complete farm payload with field data
      final farmPayload = {
        'farmName': farm.farmName,
        'fields': farm.fields.map((field) => field.toJson()).toList(),
      };

      // First attempt
      var response = await client.post(
        Uri.parse('${AppConfig.baseUrl}/api/farms'),
        headers: await _authHeaders(),
        body: json.encode(farmPayload),
      );

      // If token expired, try to refresh and retry
      if (response.statusCode == 401) {
        final responseBody = json.decode(response.body);
        if (responseBody['message']?.toString().contains('jwt expired') == true ||
            responseBody['message']?.toString().contains('TokenExpiredError') == true) {
          
          try {
            // Try to refresh token
            await _refreshTokenIfNeeded();
            
            // Retry with refreshed token
            response = await client.post(
              Uri.parse('${AppConfig.baseUrl}/api/farms'),
              headers: await _authHeaders(),
              body: json.encode(farmPayload),
            );
          } catch (refreshError) {
            // If refresh fails, clear all tokens and throw authentication error
            await SecureStorage.clearUserSession();
            throw ServerException('Authentication expired. Please log in again.');
          }
        }
      }

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return FarmModel.fromJson(responseData['data']['farm']);
      } else if (response.statusCode == 401) {
        // Still unauthorized after refresh attempt - clear session
        await SecureStorage.clearUserSession();
        throw ServerException('Authentication expired. Please log in again.');
      } else {
        final responseBody = json.decode(response.body);
        throw ServerException(responseBody['message'] ?? 'Failed to create farm with field');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Network error: Failed to create farm with field - $e');
    }
  }

  @override
  Future<void> createSensor(String farmId, Map<String, dynamic> sensorData) async {
    try {
      // Add farm ID to sensor data
      final sensorPayload = {
        ...sensorData,
        'farm': farmId,
      };

      // First attempt
      var response = await client.post(
        Uri.parse('${AppConfig.baseUrl}/api/sensors'),
        headers: await _authHeaders(),
        body: json.encode(sensorPayload),
      );

      // If token expired, try to refresh and retry
      if (response.statusCode == 401) {
        final responseBody = json.decode(response.body);
        if (responseBody['message']?.toString().contains('jwt expired') == true ||
            responseBody['message']?.toString().contains('TokenExpiredError') == true) {
          
          try {
            // Try to refresh token
            await _refreshTokenIfNeeded();
            
            // Retry with new token
            response = await client.post(
              Uri.parse('${AppConfig.baseUrl}/api/sensors'),
              headers: await _authHeaders(),
              body: json.encode(sensorPayload),
            );
          } catch (refreshError) {
            // If refresh fails, clear all tokens and throw authentication error
            await SecureStorage.clearUserSession();
            throw ServerException('Authentication expired. Please log in again.');
          }
        }
      }

      if (response.statusCode == 201) {
        // Sensor created successfully
        return;
      } else if (response.statusCode == 401) {
        // Still unauthorized after refresh attempt - clear session
        await SecureStorage.clearUserSession();
        throw ServerException('Authentication expired. Please log in again.');
      } else {
        final responseBody = json.decode(response.body);
        throw ServerException(responseBody['message'] ?? 'Failed to create sensor');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Network error: Failed to create sensor - $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getFarmAnalytics(String farmId) async {
    try {
      final headers = await _authHeaders();
      final response = await client.get(
        Uri.parse('${AppConfig.baseUrl}/api/farms/$farmId/analytics'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['data'] as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        // Try to refresh token
        final newToken = await _refreshTokenIfNeeded();
        if (newToken != null) {
          final newHeaders = await _authHeaders();
          final retryResponse = await client.get(
            Uri.parse('${AppConfig.baseUrl}/api/farms/$farmId/analytics'),
            headers: newHeaders,
          );
          
          if (retryResponse.statusCode == 200) {
            final responseData = json.decode(retryResponse.body);
            return responseData['data'] as Map<String, dynamic>;
          }
        }
        
        await SecureStorage.clearUserSession();
        throw ServerException('Authentication expired. Please log in again.');
      } else {
        final responseBody = json.decode(response.body);
        throw ServerException(responseBody['message'] ?? 'Failed to get farm analytics');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Network error: Failed to get farm analytics - $e');
    }
  }
}
