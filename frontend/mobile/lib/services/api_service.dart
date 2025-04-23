import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // For storing token

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
  // Change this to your actual server IP address or domain
  final String baseUrl = 'http://localhost:8080/api'; // For Android emulator
  // final String baseUrl = 'http://localhost:8080/api'; // For iOS simulator

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

  // Clear token from shared preferences (for logout)
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Login method
  Future<ApiResponse> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Save token if provided
        if (responseData['data'] != null && responseData['data']['token'] != null) {
          await _saveToken(responseData['data']['token']);
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
    } catch (e) {
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
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(userData),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201 && responseData['success'] == true) {
        return ApiResponse(
          success: true,
          message: responseData['message'] ?? 'Registration successful',
          data: responseData['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: responseData['message'] ?? 'Registration failed',
        );
      }
    } catch (e) {
      print('Registration error: ${e.toString()}');
      return ApiResponse(
        success: false,
        message: 'Connection error. Please check your internet connection.',
      );
    }
  }

  // For testing purposes during development - remove in production
  Future<ApiResponse> localLogin(String username, String password) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));
    
    // Mock login validation
    if (username == 'farmer1' && password == 'farmer1') {
      return ApiResponse(
        success: true,
        message: 'Login successful',
        data: {
          'user': {
            'username': username,
            'fullName': 'Demo Farmer',
            'role': 'farmer'
          },
          'token': 'mock-token-for-testing'
        },
      );
    } else {
      return ApiResponse(
        success: false,
        message: 'Invalid username or password',
      );
    }
  }

  // For testing purposes during development - remove in production
  Future<ApiResponse> localRegister(Map<String, dynamic> userData) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 2));
    
    // Check if username is already taken (just for demonstration)
    if (userData['username'] == 'farmer1') {
      return ApiResponse(
        success: false,
        message: 'Username already taken',
      );
    }
    
    // Mock successful registration
    return ApiResponse(
      success: true,
      message: 'Registration successful',
      data: {
        'id': 'new-user-id',
        'username': userData['username'],
        'fullName': userData['fullName'],
        'role': 'farmer',
      },
    );
  }
}