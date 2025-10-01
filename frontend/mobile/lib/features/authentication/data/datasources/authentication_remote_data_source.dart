import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../../core/config/environment.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/secure_storage.dart';
import '../model/user_model.dart';

abstract class AuthenticationRemoteDataSource {
  Future<UserModel> login(String username, String password);
  Future<UserModel> register(Map<String, dynamic> userData);
  Future<UserModel> updateProfile(String userId, Map<String, dynamic> userData);
  Future<String?> refreshToken();
}

class AuthenticationRemoteDataSourceImpl
    implements AuthenticationRemoteDataSource {
  final Dio client;

  AuthenticationRemoteDataSourceImpl({
    required this.client,
  });

  // ---------------- LOGIN ----------------
  @override
  Future<UserModel> login(String username, String password) async {
    try {
      print("🔐 Frontend: Attempting login with username: $username");
      print("🔐 Frontend: Sending request to: /auth/login");
      
      final requestData = {
        "username": username, // Use username for mobile farmers
        "password": password,
        "deviceType": "mobile",
      };
      
      print("🔐 Frontend: Request data: ${requestData.keys.join(', ')}");
      
      final response = await client
          .post(
            '/auth/login',
            data: requestData,
            options: Options(contentType: Headers.jsonContentType),
          )
          .timeout(const Duration(seconds: 10));

      print("🔐 Frontend: Response status: ${response.statusCode}");
      print("🔐 Frontend: Response data: ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        print("🔐 Frontend: Login data structure: $data");

        if (data != null && data['accessToken'] != null) {
          print("🔐 Frontend: Storing tokens...");
          print("🔐 Frontend: Access token preview: ${data['accessToken'].toString().substring(0, 20)}...");
          print("🔐 Frontend: Refresh token preview: ${data['refreshToken']?.toString().substring(0, 20)}...");
          
          try {
            await SecureStorage.storeTokens(data['accessToken'], data['refreshToken']);
            print("🔐 Frontend: Tokens stored successfully");
            
            // Verify tokens were stored
            final storedToken = await SecureStorage.getToken();
            final storedRefreshToken = await SecureStorage.getRefreshToken();
            print("🔐 Frontend: Verification - stored access token: ${storedToken != null ? "exists" : "null"}");
            print("🔐 Frontend: Verification - stored refresh token: ${storedRefreshToken != null ? "exists" : "null"}");
            
            print("🔐 Frontend: Creating user model...");
            final userModel = UserModel.fromJson(data['user']);
            print("🔐 Frontend: User model created: ${userModel.username}");
            return userModel;
          } catch (e) {
            print("🚨 Frontend: Error storing tokens: $e");
            throw ServerException("Failed to store authentication tokens: $e");
          }
        } else {
          print("🚨 Frontend: No valid token in response data");
          throw ServerException(
            "Authentication failed: No valid token received",
          );
        }
      } else {
        print("🚨 Frontend: Login failed - Status: ${response.statusCode}, Success: ${response.data['success']}");
        throw ServerException(
          response.data['message'] ?? "Authentication failed",
        );
      }
    } on DioException catch (e) {
      print("🚨 Frontend: DioException during login: ${e.toString()}");
      print("🚨 Frontend: Response data: ${e.response?.data}");
      print("🚨 Frontend: Status code: ${e.response?.statusCode}");
      throw _mapDioError(e, "Authentication failed");
    } catch (e) {
      print("🚨 Frontend: General exception during login: ${e.toString()}");
      throw ServerException("Login failed: $e");
    }
  }

  // ---------------- REGISTER ----------------
  // Fixed register method in AuthenticationRemoteDataSourceImpl

  // Fixed register method in AuthenticationRemoteDataSourceImpl

  @override
  Future<UserModel> register(Map<String, dynamic> userData) async {
    try {
      // Format contact number to match backend expectations (09xxxxxxxxx - 11 digits with leading 0)
      String formattedContactNumber = userData["contactNumber"];
      final cleanNumber = formattedContactNumber.replaceAll(RegExp(r'\D'), '');
      
      if (cleanNumber.length == 10 && cleanNumber.startsWith('9')) {
        // Add leading 0 to 9xxxxxxxxx to get 09xxxxxxxxx
        formattedContactNumber = '0$cleanNumber';
      } else if (cleanNumber.length == 11 && cleanNumber.startsWith('09')) {
        // Already in correct format
        formattedContactNumber = cleanNumber;
      }

      final payload = {
        "username": userData["username"],
        "email": userData["email"] ?? "${userData["username"]}@maizewatch.com", // Add email field for backend validation
        "password": userData["password"],
        "fullName": userData["fullName"],
        "contactNumber": formattedContactNumber, // Format to 09xxxxxxxxx
        "address": userData["address"],
        "role": userData["role"] ?? "user",
        "deviceType": "mobile", // Add deviceType to indicate mobile registration
      };

      print("📤 Register request payload: $payload");

      final response = await client
          .post(
            '/auth/register',
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
            print("🔐 AuthDataSource: Checking for tokens in response...");
            print("🔐 AuthDataSource: data['accessToken'] exists: ${data['accessToken'] != null}");
            print("🔐 AuthDataSource: data['refreshToken'] exists: ${data['refreshToken'] != null}");
            
            if (data['accessToken'] != null && data['refreshToken'] != null) {
              print("🔐 AuthDataSource: Storing tokens...");
              await SecureStorage.storeTokens(
                data['accessToken'], 
                data['refreshToken']
              );
              print("🔐 AuthDataSource: Tokens stored successfully from registration");
            } else {
              print("⚠️ AuthDataSource: No tokens found in registration response");
              print("⚠️ AuthDataSource: Response structure: ${data.keys.toList()}");
            }

            print("📥 User data found: ${data['user']}");
            return UserModel.fromJson(
              data['user'],
            ); // Pass only the user object
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

  // ---------------- UPDATE PROFILE ----------------
  @override
  Future<UserModel> updateProfile(String userId, Map<String, dynamic> userData) async {
    try {
      print("🔐 Frontend: Attempting to update profile for user: $userId");
      print("🔐 Frontend: Sending request to: /users/$userId");
      
      // Get the access token
      final accessToken = await SecureStorage.getToken();
      if (accessToken == null) {
        throw ServerException("No access token available");
      }

      print("🔐 Frontend: Access token length: ${accessToken.length}");
      print("🔐 Frontend: Access token preview: ${accessToken.substring(0, 20)}...");
      print("📤 Update profile payload: $userData");
      
      final response = await client
          .put(
            '/users/$userId',
            data: userData,
            options: Options(
              contentType: Headers.jsonContentType,
              headers: {
                'Authorization': 'Bearer $accessToken',
              },
            ),
          )
          .timeout(const Duration(seconds: 30));

      print("🔐 Frontend: Response status: ${response.statusCode}");
      print("🔐 Frontend: Response data: ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        print("🔐 Frontend: Profile update data structure: $data");

        if (data != null && data['user'] != null) {
          print("🔐 Frontend: Creating updated user model...");
          final userModel = UserModel.fromJson(data['user']);
          print("🔐 Frontend: Updated user model created: ${userModel.username}");
          
          // Update stored user data
          await SecureStorage.storeUserData(jsonEncode(data['user']));
          
          return userModel;
        } else {
          print("🚨 Frontend: No valid user data in response");
          throw ServerException("Profile update failed: No valid user data received");
        }
      } else {
        print("🚨 Frontend: Profile update failed - Status: ${response.statusCode}, Success: ${response.data['success']}");
        throw ServerException(
          response.data['message'] ?? "Profile update failed",
        );
      }
    } on DioException catch (e) {
      print("🚨 Frontend: DioException during profile update: ${e.toString()}");
      print("🚨 Frontend: Response data: ${e.response?.data}");
      print("🚨 Frontend: Status code: ${e.response?.statusCode}");
      throw _mapDioError(e, "Profile update failed");
    } catch (e) {
      print("🚨 Frontend: General exception during profile update: ${e.toString()}");
      throw ServerException("Profile update failed: $e");
    }
  }

  // ---------------- REFRESH TOKEN ----------------
  @override
  Future<String?> refreshToken() async {
    try {
      final refreshToken = await SecureStorage.getRefreshToken();
      if (refreshToken == null) {
        throw ServerException("No refresh token available");
      }

      final response = await client.post(
        '/auth/refresh',
        data: {"refreshToken": refreshToken}, // ✅ correct key
        options: Options(contentType: Headers.jsonContentType),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final newAccessToken = response.data['data']['accessToken'];
        await SecureStorage.storeTokens(newAccessToken, refreshToken);
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
