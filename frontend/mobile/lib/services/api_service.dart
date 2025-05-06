import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:maize_watch/services/translation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/sensor_data_model.dart';

class ApiResponse {
  final bool success;
  final String? message;
  final Map<String, dynamic>? data;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
  });
}

class ApiService {
  final TranslationService _translationService = TranslationService();
   
  final String baseUrl = 'http://localhost:8080';
  
  static Map<String, dynamic>? currentUser;

  // Custom HTTP client that bypasses certificate verification, for the cloud-hosted backend
  http.Client _getClient() {
    final httpClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    return IOClient(httpClient);
  }

  // Get token from shared preferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Save token to shared preferences
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Clear token from shared preferences
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Save user data to shared preferences
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(userData));
    
    // Also store the login timestamp
    await prefs.setInt('login_timestamp', DateTime.now().millisecondsSinceEpoch);
  }
  
  // Get user data from shared preferences
  Future<Map<String, dynamic>?> getUserData() async {
    if (currentUser != null) return currentUser;
    
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      currentUser = json.decode(userData);
      return currentUser;
    }
    return null;
  }
  
  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _getToken();
    final userData = await getUserData();
    return token != null && userData != null;
  }
  
  // Logout and clear all user data
  Future<void> logout() async {
    try {
      // Clear API tokens or session data
      final prefs = await SharedPreferences.getInstance();
      
      // Keep language preference
      final translationService = TranslationService();
      final currentLang = await translationService.getSavedLanguage();
      
      // Clear user-related data but keep necessary app settings
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      await prefs.remove('user_id');
      await prefs.remove('login_timestamp');
      currentUser = null;
      
      // Optionally, make an API call to invalidate the session server-side
      // await _dio.post('/logout');
      
      print('User logged out successfully');
    } catch (e) {
      print('Error during logout: $e');
      throw Exception('Failed to logout');
    }
  }

  // Login method
  Future<ApiResponse> login(String username, String password) async {
    try {
      final client = _getClient();
      final response = await client
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'username': username,
              'password': password,
            }),
          )
          .timeout(Duration(seconds: 20));
      
      client.close();

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        if (responseData['data'] != null &&
            responseData['data']['token'] != null) {
          await _saveToken(responseData['data']['token']);
          
          // Store the user data if available
          if (responseData['data']['user'] != null) {
            currentUser = responseData['data']['user'];
            await _saveUserData(responseData['data']['user']);
          }
        }

        return ApiResponse(
          success: true,
          message: responseData['message'] ?? 'Login successful',
          data: responseData['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: responseData['message'] ?? 'Login failed',
        );
      }
    } on http.ClientException catch (e) {
      print('HTTP client error: ${e.toString()}');
      return ApiResponse(
        success: false,
        message: 'Client error occurred.',
      );
    } on Exception catch (e) {
      print('Login error: ${e.toString()}');
      return ApiResponse(
        success: false,
        message: 'Connection error. Please check your internet connection.',
      );
    }
  }

  // Registration method
  Future<ApiResponse> register(Map<String, dynamic> userData) async {
    try {
      final client = _getClient();
      final response = await client
          .post(
            Uri.parse('$baseUrl/auth/register'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(userData),
          )
          .timeout(Duration(seconds: 20)); // Increased a bit
      
      client.close();

      final responseData = json.decode(response.body);

      if (response.statusCode == 201 && responseData['success'] == true) {
        print('✅ Registration successful');
        return ApiResponse(
          success: true,
          message: responseData['message'] ?? 'Registration successful',
          data: responseData['data'],
        );
      } else {
        print('❌ Registration failed: ${responseData['message']}');
        return ApiResponse(
          success: false,
          message: responseData['message'] ?? 'Registration failed',
        );
      }
    } on TimeoutException catch (e) {
      print('Timeout error: ${e.toString()}');
      // Since we know the account might have been created
      return ApiResponse(
        success: false,
        message: 'The server is taking too long to respond. Your account may have been created. Please try logging in.',
      );
    } on http.ClientException catch (e) {
      print('HTTP client error: ${e.toString()}');
      return ApiResponse(
        success: false,
        message: 'Client error occurred.',
      );
    } on Exception catch (e) {
      print('Registration error: ${e.toString()}');
      return ApiResponse(
        success: false,
        message: 'Connection error. Please check your internet connection.',
      );
    }
  }
  
  // Get user greeting based on time of day
  String getGreeting(String name) {
    final hour = DateTime.now().hour;
    String greetingKey;

    if (hour < 12) {
      greetingKey = 'greeting_morning';
    } else if (hour < 17) {
      greetingKey = 'greeting_afternoon';
    } else {
      greetingKey = 'greeting_evening';
    }

    final greeting = _translationService.translate(greetingKey);
    return '$greeting, $name';
  }

  Future<List<String>> getFields() async {
    final response = await http.get(Uri.parse('$baseUrl/api/fields'));
    
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((field) => field.toString()).toList();
    } else {
      throw Exception('Failed to load fields');
    }
  }

  Future<List<SensorReading>> getLatestReadings() async {
    final response = await http.get(Uri.parse('$baseUrl/api/latest'));
    
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => SensorReading.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load latest readings');
    }
  }

  Future<List<SensorReading>> getHistoricalData(String fieldId, int hours) async {
    final response = await http.get(
      Uri.parse('$baseUrl/historical/$fieldId?hours=$hours')
    );
    
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => SensorReading.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load historical data');
    }
  }
}