import 'dart:async';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../model/user_model.dart';

abstract class AuthenticationRemoteDataSource {
  Future<UserModel> login(String username, String password);
  Future<UserModel> register(Map<String, dynamic> userData);
  Future<String?> refreshToken();
}

class AuthenticationRemoteDataSourceImpl
    implements AuthenticationRemoteDataSource {
  final Dio client;
  final String baseUrl = 'http://10.250.104.206:8080';

  AuthenticationRemoteDataSourceImpl({required this.client});

  // ---------------- LOGIN ----------------
  @override
  Future<UserModel> login(String username, String password) async {
    try {
      final response = await client
          .post(
            '$baseUrl/api/auth/login',
            data: {
              "username": username,
              "password": password,
              "deviceType": "mobile",
            },
            options: Options(contentType: Headers.jsonContentType),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];

        if (data != null && data['token'] != null) {
          await _saveTokens(data['token'], data['refreshToken']);
          return UserModel.fromJson(data['user']);
        } else {
          throw ServerException(
            "Authentication failed: No valid token received",
          );
        }
      } else {
        throw ServerException(
          response.data['message'] ?? "Authentication failed",
        );
      }
    } on DioException catch (e) {
      throw _mapDioError(e, "Authentication failed");
    }
  }

  // ---------------- REGISTER ----------------
  // Fixed register method in AuthenticationRemoteDataSourceImpl

  // Fixed register method in AuthenticationRemoteDataSourceImpl

  @override
  Future<UserModel> register(Map<String, dynamic> userData) async {
    try {
      final payload = {
        "username": userData["username"],
        "password": userData["password"],
        "fullName": userData["fullName"],
        "contactNumber": userData["contactNumber"],
        "address": userData["address"],
        "role": userData["role"] ?? "user",
      };

      print("📤 Register request payload: $payload");

      final response = await client
          .post(
            '$baseUrl/api/auth/register',
            data: payload,
            options: Options(contentType: Headers.jsonContentType),
          )
          .timeout(const Duration(seconds: 20));

      print("📥 Register response status: ${response.statusCode}");
      print("📥 Register full response: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map && response.data['success'] == true) {
          final data = response.data['data'];

          if (data != null && data['user'] != null) {
            // Save tokens if they exist (like in login)
            if (data['token'] != null) {
              await _saveTokens(data['token'], data['refreshToken']);
            }

            print("📥 User data found: ${data['user']}");
            return UserModel.fromJson(
              data['user'],
            ); // ✅ Pass only the user object
          } else {
            throw ServerException("Registration failed: No user data received");
          }
        } else {
          throw ServerException(
            response.data['message'] ?? "Registration failed",
          );
        }
      } else {
        throw ServerException(
          response.data['message'] ?? "Registration failed",
        );
      }
    } on DioException catch (e) {
      print("🚨 DioException in register: ${e.toString()}");
      print("🚨 Response data: ${e.response?.data}");
      throw _mapDioError(e, "Registration failed");
    } catch (e) {
      print("🚨 General exception in register: ${e.toString()}");
      throw ServerException("Registration failed: $e");
    }
  }

  // ---------------- REFRESH TOKEN ----------------
  @override
  Future<String?> refreshToken() async {
    try {
      final refreshToken = await _getRefreshToken();
      if (refreshToken == null) {
        throw ServerException("No refresh token available");
      }

      final response = await client.post(
        '$baseUrl/api/auth/refresh',
        data: {"refreshToken": refreshToken}, // ✅ correct key
        options: Options(contentType: Headers.jsonContentType),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final newAccessToken = response.data['token'];
        await _saveTokens(newAccessToken, refreshToken);
        return newAccessToken;
      } else {
        throw ServerException(
          response.data['message'] ?? "Failed to refresh token",
        );
      }
    } on DioException catch (e) {
      throw _mapDioError(e, "Refresh token request failed");
    }
  }

  // ---------------- HELPERS ----------------
  Future<void> _saveTokens(String accessToken, String? refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("access_token", accessToken);
    if (refreshToken != null) {
      await prefs.setString("refresh_token", refreshToken);
    }
  }

  Future<String?> _getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("refresh_token");
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
