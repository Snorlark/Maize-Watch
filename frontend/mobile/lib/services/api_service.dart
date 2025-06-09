import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/sensor_data_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
  final String baseUrl = 'http://localhost:8080';

  static Map<String, dynamic>? currentUser;
  bool _isRefreshing = false;
  final _refreshQueue = <Future Function()>[];

  // Helper function for min calculation
  int min(int a, int b) {
    return (a < b) ? a : b;
  }

  // Custom HTTP client that bypasses certificate verification, for the cloud-hosted backend
  http.Client getClient() {
    final httpClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    return IOClient(httpClient);
  }

  // Get token from shared preferences with improved error handling and logging
  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      // Add debug logging to check if token exists
      if (token == null || token.isEmpty) {
        print('🔴 Warning: No auth token found in storage');
      } else {
        // Don't print the full token for security, just the first few characters
        print(
            '🟢 Token retrieved from storage: ${token.substring(0, min(token.length, 10))}...');
      }

      return token;
    } catch (e) {
      print('❌ Error retrieving token: $e');
      return null;
    }
  }

  // Save token to shared preferences
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    print('Token saved: $token');
  }

  // Save refresh token to shared preferences
  Future<void> _saveRefreshToken(String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('refresh_token', refreshToken);
  }

  // Get refresh token from shared preferences
  Future<String?> _getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('refresh_token');
    } catch (e) {
      print('❌ Error retrieving refresh token: $e');
      return null;
    }
  }

  // Clear token from shared preferences
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
  }

  // Save user data to shared preferences
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(userData));

    // Store the login timestamp
    await prefs.setInt('login_timestamp', DateTime.now().millisecondsSinceEpoch);
    print('✅ Login timestamp stored: ${DateTime.now().millisecondsSinceEpoch}');
  }

  // Get user data from shared preferences
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      // First check if we have the data in memory
      if (currentUser != null) return currentUser;

      // Then check in shared preferences
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');

      if (userData != null) {
        try {
          currentUser = json.decode(userData);
          print('Successfully retrieved user data: ${currentUser != null}');
          return currentUser;
        } catch (e) {
          print('Error parsing user data from shared preferences: $e');
          // Clear corrupted data
          await prefs.remove('user_data');
          return null;
        }
      } else {
        print('No user data found in shared preferences');
        return null;
      }
    } catch (e) {
      print('Error retrieving user data: $e');
      return null;
    }
  }

  // Check if session is expired (1 week)
  Future<bool> isSessionExpired() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loginTimestamp = prefs.getInt('login_timestamp');
      
      if (loginTimestamp == null) {
        print('⚠️ No login timestamp found');
        return true;
      }

      final loginDate = DateTime.fromMillisecondsSinceEpoch(loginTimestamp);
      final now = DateTime.now();
      final difference = now.difference(loginDate);
      
      // Session expires after 7 days
      final isExpired = difference.inDays >= 7;
      
      if (isExpired) {
        print('⚠️ Session expired. Last login: $loginDate');
        // Clear session data
        await logout();
      } else {
        print('✅ Session valid. Days remaining: ${7 - difference.inDays}');
      }
      
      return isExpired;
    } catch (e) {
      print('❌ Error checking session expiration: $e');
      return true;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      // First check if session is expired
      if (await isSessionExpired()) {
        print('❌ Session expired');
        return false;
      }

      final token = await _getToken();
      final userData = await getUserData();
      print('Retrieved token: ${token != null ? 'Present' : 'Missing'}');
      print('Retrieved user data: ${userData != null ? 'Present' : 'Missing'}');
      return token != null && userData != null;
    } catch (e) {
      print('❌ Error checking login status: $e');
      return false;
    }
  }

  // Logout and clear all user data
  Future<void> logout() async {
    try {
      // Clear API tokens or session data
      final prefs = await SharedPreferences.getInstance();

      // Clear user-related data but keep necessary app settings
      await prefs.remove('auth_token');
      await prefs.remove('refresh_token');
      await prefs.remove('user_data');
      await prefs.remove('user_id');
      await prefs.remove('login_timestamp');
      currentUser = null;

      // Optionally, make an API call to invalidate the session server-side
      // await _dio.post('/logout');

      print('✅ User logged out successfully');
    } catch (e) {
      print('❌ Error during logout: $e');
      throw Exception('Failed to logout');
    }
  }

  // Login method
  Future<ApiResponse> login(String username, String password) async {
    try {
      print('🔑 Attempting login for username: $username');
      final client = getClient();
      
      final loginUrl = Uri.parse('$baseUrl/api/auth/login');
      print('🌐 Login URL: $loginUrl');
      
      final response = await client
          .post(
            loginUrl,
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'username': username,
              'password': password,
              'deviceType': 'mobile',
            }),
          )
          .timeout(Duration(seconds: 20));

      print('📡 Login response status: ${response.statusCode}');
      print('📦 Login response body: ${response.body}');

      client.close();

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        final data = responseData['data'];
        if (data != null && data['token'] != null) {
          // Save the token after successful login
          final token = data['token'];
          print('🎟️ Token received: ${token.substring(0, min(token.length, 10))}...');
          
          // Check if token is properly formatted by decoding it
          try {
            final parts = token.split('.');
            if (parts.length != 3) {
              print('❌ Invalid token format: token does not have 3 parts');
              return ApiResponse(success: false, message: 'Invalid token format received');
            }
            
            // Decode payload to verify structure
            final payload = json.decode(
              utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
            );
            print('🔑 Token payload: $payload');
            
            // Check for required fields
            if (payload['id'] == null) {
              print('❌ Token missing required field: id');
              return ApiResponse(success: false, message: 'Invalid token format received');
            }
            
            await _saveToken(token);
            
            // Store the user data if available
            if (data['user'] != null) {
              currentUser = data['user'];
              await _saveUserData(currentUser!);
              
              // Explicitly store the user ID
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('user_id', payload['id'].toString());
              print('✅ User ID stored: ${payload['id']}');
            } else {
              print('⚠️ No user data in response');
            }
            
            return ApiResponse(
              success: true,
              data: {
                'token': token,
                'user': data['user']
              },
            );
          } catch (e) {
            print('❌ Error processing token: $e');
            return ApiResponse(success: false, message: 'Error processing login response');
          }
        } else {
          print('❌ No token in response data');
          print('Response data: $responseData');
          return ApiResponse(
            success: false,
            message: 'No token received from server',
          );
        }
      } else {
        print('❌ Login failed with status ${response.statusCode}');
        print('Error message: ${responseData['message']}');
      }
      
      return ApiResponse(
        success: false,
        message: responseData['message'] ?? 'Login failed',
      );
    } catch (e) {
      print('❌ Login error: $e');
      return ApiResponse(
        success: false,
        message: 'Network error during login',
      );
    }
  }

  // Register method
  Future<ApiResponse> register(Map<String, dynamic> userData) async {
    try {
      final client = getClient();
      final response = await client
          .post(
            Uri.parse('$baseUrl/api/auth/register'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode(userData),
          )
          .timeout(Duration(seconds: 20));

      client.close();

      final responseData = json.decode(response.body);

      if (response.statusCode == 201 && responseData['success'] == true) {
        print('✅ Registration successful');
        // Save user data if present
        if (responseData['data'] != null) {
          // Store the user data in memory
          currentUser = responseData['data'];
          
          // Save user data to shared preferences
          await _saveUserData(responseData['data']);
          
          // Explicitly store the user ID
          final prefs = await SharedPreferences.getInstance();
          final userId = responseData['data']['id'] ?? responseData['data']['_id'];
          if (userId != null) {
            await prefs.setString('user_id', userId.toString());
            print('✅ User ID stored after registration: $userId');
            print('✅ User data stored in shared preferences');
          }
        }
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
      return ApiResponse(
        success: false,
        message:
            'The server is taking too long to respond. Your account may have been created. Please try logging in.',
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
  String getGreeting(BuildContext context, String name) {
    final hour = DateTime.now().hour;
    final localizations = AppLocalizations.of(context)!;

    String greeting;

    if (hour < 12) {
      greeting = localizations.greeting_morning;
    } else if (hour < 17) {
      greeting = localizations.greeting_afternoon;
    } else {
      greeting = localizations.greeting_evening;
    }

    return '$greeting, $name';
  }

  // Get field statistics (no field ID required)
  Future<Map<String, dynamic>> getFieldStatistics([int days = 7]) async {
    try {
      final client = getClient();
      final response = await client
          .get(Uri.parse('$baseUrl/api/sensors/statistics?days=$days'))
          .timeout(Duration(seconds: 15));
      
      client.close();
      
      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(json.decode(response.body));
      } else {
        throw Exception('Failed to load field statistics. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching field statistics: ${e.toString()}');
      throw Exception('Failed to load field statistics: ${e.toString()}');
    }
  }

  Future<List<String>> getFields() async {
    final response = await http.get(Uri.parse('$baseUrl/api/sensors/fields'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((field) => field.toString()).toList();
    } else {
      throw Exception('Failed to load fields');
    }
  }

  // Get daily aggregated data (no field ID required)
  Future<List<Map<String, dynamic>>> getDailyAggregates([int days = 7]) async {
    try {
      final client = getClient();
      final response = await client
          .get(Uri.parse('$baseUrl/api/sensors/daily?days=$days'))
          .timeout(Duration(seconds: 15));

      client.close();

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception(
            'Failed to load daily data. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching daily data: ${e.toString()}');
      throw Exception('Failed to load daily data: ${e.toString()}');
    }
  }

  // Updated to match the backend API response structure
  Future<List<SensorReading>> getLatestReadings() async {
    try {
      print('📊 Fetching latest readings at ${DateTime.now()}');
      final client = getClient();
      final response = await client
          .get(Uri.parse('$baseUrl/api/sensors/latest'))
          .timeout(Duration(seconds: 15));

      client.close();

      if (response.statusCode == 200) {
        print('✅ Got response with status ${response.statusCode}');
        final responseBody = json.decode(response.body);

        // Handle response based on the backend API structure
        if (responseBody['success'] == true && responseBody['data'] != null) {
          // Create a sensor reading from the data object
          final data = responseBody['data'];
          print('📈 Latest reading timestamp: ${data['timestamp'] ?? 'No timestamp'}');
          
          // Create a single SensorReading with the data in the expected format
          // Adjust the id and fieldId as needed
          final reading = SensorReading(
            id: "latest_reading", // Use a default ID or generate one
            timestamp: data['timestamp'] != null 
                ? DateTime.parse(data['timestamp']) 
                : DateTime.now(),
            fieldId: "default_field", // Since your API doesn't return fieldId
            temperature: data['temperature']?.toDouble() ?? 0.0,
            humidity: data['humidity']?.toDouble() ?? 0.0,
            soilMoisture: data['soilMoisture'] ?? 0,
            soilPh: data['soilPh']?.toDouble() ?? 0.0,
            lightIntensity: data['lightIntensity'] ?? 0,
          );
          
          return [reading];
        } else {
          print('❌ Error: Response data structure is not as expected');
          throw Exception('Failed to parse latest readings response');
        }
      } else {
        print('❌ Error status: ${response.statusCode}, Body: ${response.body}');
        throw Exception(
            'Failed to load latest readings. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching latest readings: ${e.toString()}');
      throw Exception('Failed to load latest readings: ${e.toString()}');
    }
  }

  // Updated to match the backend API response structure
  Future<List<SensorReading>> getHistoricalData(int hours) async {
    try {
      final client = getClient();
      final response = await client
          .get(Uri.parse('$baseUrl/api/sensors/historical?minutes=${hours * 60}'))
          .timeout(Duration(seconds: 15));

      client.close();

      if (response.statusCode == 200) {
        // Handle success response based on the expected backend structure
        final responseData = json.decode(response.body);
        
        if (responseData['success'] == true && responseData['data'] != null) {
          // Convert the data to a list of SensorReading objects
          List<dynamic> dataList = responseData['data'];
          
          return dataList.map((item) {
            // For each data point, create a SensorReading with the correct structure
            return SensorReading(
              id: item['_id'] ?? "historical_${DateTime.now().millisecondsSinceEpoch}",
              timestamp: item['timestamp'] != null 
                  ? DateTime.parse(item['timestamp']) 
                  : DateTime.now(),
              fieldId: item['field_id'] ?? "default_field",
              temperature: item['temperature']?.toDouble() ?? 0.0,
              humidity: item['humidity']?.toDouble() ?? 0.0,
              soilMoisture: item['soilMoisture'] ?? 0,
              soilPh: item['soilPh']?.toDouble() ?? 0.0,
              lightIntensity: item['lightIntensity'] ?? 0,
            );
          }).toList();
        } else {
          throw Exception('Failed to parse historical data response');
        }
      } else {
        throw Exception(
            'Failed to load historical data. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching historical data: ${e.toString()}');
      throw Exception('Failed to load historical data: ${e.toString()}');
    }
  }

  // Method to force sync with ThingSpeak
  Future<ApiResponse> syncSensorData() async {
    try {
      final token = await _getToken();
      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Authentication token not found. Please log in again.',
        );
      }

      final client = getClient();
      final response = await client
          .post(
            Uri.parse('$baseUrl/api/sensors/sync'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(Duration(seconds: 30));

      client.close();

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return ApiResponse(
          success: true,
          message: responseData['message'] ?? 'Sensor data synced successfully',
          data: responseData['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to sync sensor data',
        );
      }
    } catch (e) {
      print('Error syncing sensor data: ${e.toString()}');
      return ApiResponse(
        success: false,
        message: 'Connection error during data sync.',
      );
    }
  }

  // Get specific field data from ThingSpeak
  Future<List<Map<String, dynamic>>> getFieldData(int fieldNumber, [int results = 10]) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Authentication token not found. Please log in again.');
      }

      final client = getClient();
      final response = await client
          .get(
            Uri.parse('$baseUrl/api/sensors/field/$fieldNumber?results=$results'),
            headers: {
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(Duration(seconds: 15));

      client.close();

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['success'] == true && responseData['data'] != null) {
          return List<Map<String, dynamic>>.from(responseData['data']);
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception(
            'Failed to load field data. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching field data: ${e.toString()}');
      throw Exception('Failed to load field data: ${e.toString()}');
    }
  }

  // Register corn field for a user
  Future<ApiResponse> registerCornField(
    String userId, Map<String, dynamic> cornData) async {
    try {
      var token = await _getToken();
      if (token == null) {
        return ApiResponse(
          success: false,
          message: 'Authentication token not found. Please log in again.',
        );
      }

      // Get user data from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final userDataStr = prefs.getString('user_data');
      
      if (userDataStr == null) {
        print('No user data found in shared preferences');
        return ApiResponse(
          success: false,
          message: 'User data not found. Please log in again.',
        );
      }

      // Parse user data
      final userData = json.decode(userDataStr);
      userId = userData['id'] ?? userData['_id'];
      
      if (userId == null) {
        print('User ID not found in user data');
        return ApiResponse(
          success: false,
          message: 'User ID not found. Please log in again.',
        );
      }

      print('Using user ID for corn field registration: $userId');

      // Ensure growth stage is correctly formatted
      if (cornData.containsKey('growthStage')) {
        cornData['growthStage'] =
            cornData['growthStage'].toString().trim().toUpperCase();
        print('Sending growth stage to API: ${cornData['growthStage']}');
      }

      final client = getClient();
      try {
        final response = await client
            .post(
              Uri.parse('$baseUrl/api/corn/register'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: json.encode({
                'userId': userId,
                ...cornData,
              }),
            )
            .timeout(Duration(seconds: 20));

        final responseData = json.decode(response.body);

        // Check if token is invalid or expired
        if (response.statusCode == 401) {
          print('🔄 Token expired or invalid. Attempting to refresh token...');
          
          // Try to refresh the token
          bool refreshed = await refreshToken();
          if (refreshed) {
            // Retry the request with the new token
            token = await _getToken();
            return await registerCornField(userId, cornData);
          } else {
            // If refresh failed, need to re-login
            return ApiResponse(
              success: false,
              message: 'Your session has expired. Please log in again.',
            );
          }
        }

        if (response.statusCode == 201 && responseData['success'] == true) {
          print('✅ Corn field registration successful');
          return ApiResponse(
            success: true,
            message:
                responseData['message'] ?? 'Corn field registered successfully',
            data: responseData['data'],
          );
        } else {
          print('❌ Corn field registration failed: ${responseData['message']}');
          return ApiResponse(
            success: false,
            message: responseData['message'] ?? 'Corn field registration failed',
          );
        }
      } finally {
        client.close();
      }
    } on TimeoutException catch (e) {
      print('Timeout error: ${e.toString()}');
      return ApiResponse(
        success: false,
        message: 'The server is taking too long to respond.',
      );
    } on http.ClientException catch (e) {
      print('HTTP client error: ${e.toString()}');
      return ApiResponse(
        success: false,
        message: 'Client error occurred: ${e.toString()}',
      );
    } on Exception catch (e) {
      print('Corn registration error: ${e.toString()}');
      return ApiResponse(
        success: false,
        message: 'Connection error. Please check your internet connection.',
      );
    }
  }
  

  // Helper function for the days-based calculation
  void _useDefaultDaysBasedCalculation(
      int daysSincePlanting,
      AppLocalizations appLocalizations,
      Function(String stage, String description, int index) callback) {
    if (daysSincePlanting <= 7) {
      callback('${appLocalizations.growth_stage_ve} Stage',
          appLocalizations.growth_stage_ve_desc, 0);
    } else if (daysSincePlanting <= 21) {
      callback('${appLocalizations.growth_stage_v3} Stage',
          appLocalizations.growth_stage_v3_desc, 1);
    } else if (daysSincePlanting <= 60) {
      callback('${appLocalizations.growth_stage_v8} Stage',
          appLocalizations.growth_stage_v8_desc, 2);
    } else if (daysSincePlanting <= 67) {
      callback('${appLocalizations.growth_stage_vt} Stage',
          appLocalizations.growth_stage_vt_desc, 3);
    } else if (daysSincePlanting <= 75) {
      callback('${appLocalizations.growth_stage_r1} Stage',
          appLocalizations.growth_stage_r1_desc, 4);
    } else {
      callback('${appLocalizations.growth_stage_r6} Stage',
          appLocalizations.growth_stage_r6_desc, 5);
    }
  }

  // Updated getCropData method with improved error handling and authentication
  Future<Map<String, dynamic>?> getCropData(BuildContext context) async {
    try {
      // First, check if we're logged in
      final isUserLoggedIn = await isLoggedIn();
      if (!isUserLoggedIn) {
        print('User is not logged in. Please log in first.');
        return null;
      }

      // Get auth token - with better error handling
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        print('Authentication token not found or empty. Please log in again.');
        // Consider redirecting to login here
        return null;
      }

      // Make sure we have valid user data
      final userData = await getUserData();
      if (userData == null) {
        print('User data not found. Attempting to refresh from API...');
        // Here you could potentially make an API call to refresh user data
        return null;
      }

      // Check if the userData has an ID - could be 'id' or '_id' (MongoDB format)
      final userId = userData['id'] ?? userData['_id'];
      if (userId == null) {
        print(
            'User ID not found in user data. User data format may be incorrect.');
        print('Available user data keys: ${userData.keys.toList()}');
        return null;
      }

      print('Fetching corn data for user ID: $userId');

      // Create a custom client with timeout handling
      final client = getClient();
      try {
        // Add debug logging to check request headers
        print('🔄 Making API request with token authentication');
        print('🔗 URL: $baseUrl/api/corn/user/$userId');

        final response = await client.get(
          Uri.parse('$baseUrl/api/corn/user/$userId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 15));

        print('📊 Response status code: ${response.statusCode}');

        if (response.statusCode == 401) {
          print(
              '🔴 Authentication failed (401). Token may be expired or invalid.');
          // Token is invalid, clear it and suggest re-login
          await clearToken();
          return null;
        }

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);

          if (responseData['success'] == true && responseData['data'] != null) {
            // Check if we have any fields
            if (responseData['data'] is List &&
                responseData['data'].isNotEmpty) {
              // Get the most recent corn field
              final cornField =
                  responseData['data'][0]; // Already sorted by createdAt desc

              // DEBUG: Print the actual API response to see what's coming from the server
              print('DEBUG - API Response for corn field:');
              print(cornField);

              // Calculate days since planting
              final plantingDate = DateTime.parse(cornField['plantingDate']);
              final daysSincePlanting =
                  DateTime.now().difference(plantingDate).inDays;

              // Get translations for growth stages
              final locale = Localizations.localeOf(context);
              final appLocalizations = AppLocalizations.of(context);

              if (appLocalizations == null) {
                print('Error: AppLocalizations not available');
                return null;
              }

              // Determine growth stage based on API response or days since planting
              String currentStage = '';
              String stageDescription = '';
              List<Map<String, dynamic>> growthStages = [
                {
                  'name': appLocalizations.growth_stage_ve,
                  'complete': false,
                  'current': false
                },
                {
                  'name': appLocalizations.growth_stage_v3,
                  'complete': false,
                  'current': false
                },
                {
                  'name': appLocalizations.growth_stage_v8,
                  'complete': false,
                  'current': false
                },
                {
                  'name': appLocalizations.growth_stage_vt,
                  'complete': false,
                  'current': false
                },
                {
                  'name': appLocalizations.growth_stage_r1,
                  'complete': false,
                  'current': false
                },
                {
                  'name': appLocalizations.growth_stage_r6,
                  'complete': false,
                  'current': false
                },
              ];

              int currentStageIndex = 0;

              // First check if the field has a growth stage value set
              if (cornField.containsKey('growthStage') &&
                  cornField['growthStage'] != null) {
                String registeredStage =
                    cornField['growthStage'].toString().trim().toUpperCase();
                print('Registered growth stage from API: $registeredStage');

                // Map the registered stage to the correct index and description
                if (registeredStage == 'VE') {
                  currentStage = '${appLocalizations.growth_stage_ve} Stage';
                  stageDescription = appLocalizations.growth_stage_ve_desc;
                  currentStageIndex = 0;
                } else if (registeredStage == 'V3') {
                  currentStage = '${appLocalizations.growth_stage_v3} Stage';
                  stageDescription = appLocalizations.growth_stage_v3_desc;
                  currentStageIndex = 1;
                } else if (registeredStage == 'V8') {
                  currentStage = '${appLocalizations.growth_stage_v8} Stage';
                  stageDescription = appLocalizations.growth_stage_v8_desc;
                  currentStageIndex = 2;
                } else if (registeredStage == 'VT') {
                  currentStage = '${appLocalizations.growth_stage_vt} Stage';
                  stageDescription = appLocalizations.growth_stage_vt_desc;
                  currentStageIndex = 3;
                } else if (registeredStage == 'R1') {
                  currentStage = '${appLocalizations.growth_stage_r1} Stage';
                  stageDescription = appLocalizations.growth_stage_r1_desc;
                  currentStageIndex = 4;
                } else if (registeredStage == 'R6') {
                  currentStage = '${appLocalizations.growth_stage_r6} Stage';
                  stageDescription = appLocalizations.growth_stage_r6_desc;
                  currentStageIndex = 5;
                } else {
                  // Fallback to days-based logic if the stage doesn't match any known value
                  print(
                      'Unknown growth stage value: $registeredStage. Falling back to days-based calculation.');
                  // Continue with days-based logic using the helper function
                  _useDefaultDaysBasedCalculation(
                      daysSincePlanting, appLocalizations,
                      (stage, desc, index) {
                    currentStage = stage;
                    stageDescription = desc;
                    currentStageIndex = index;
                  });
                }
              } else {
                // If no growth stage set, fall back to days-based logic
                print(
                    'No growth stage found in API response. Using days-based calculation.');
                _useDefaultDaysBasedCalculation(
                    daysSincePlanting, appLocalizations, (stage, desc, index) {
                  currentStage = stage;
                  stageDescription = desc;
                  currentStageIndex = index;
                });
              }

              // Mark appropriate stages as complete or current
              for (int i = 0; i < growthStages.length; i++) {
                growthStages[i]['complete'] = i < currentStageIndex;
                growthStages[i]['current'] = i == currentStageIndex;
              }

              // Log successful data retrieval
              print('✅ Successfully loaded crop data');

              // Ensure the returned data includes the growthStage field
              return {
                'plantingDate': cornField['plantingDate'],
                'daysSincePlanting': daysSincePlanting,
                'currentStage': currentStage,
                'stageDescription': stageDescription,
                'cornVariety': cornField['cornVariety'],
                'fieldName': cornField['fieldName'],
                'soilType': cornField['soilType'],
                'location': cornField['location'],
                'growthStages': growthStages,
                'growthStage':
                    cornField['growthStage'], // Make sure this is included
              };
            } else {
              print('No corn fields found for this user');
              return null;
            }
          } else {
            print('Failed to load crop data: ${responseData['message']}');
            return null;
          }
        } else {
          print(
              'Failed to load crop data. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
          return null;
        }
      } finally {
        client.close(); // Ensure the client is closed
      }
    } on TimeoutException catch (e) {
      print('Timeout error while fetching crop data: ${e.toString()}');
      return null;
    } on http.ClientException catch (e) {
      print('HTTP client error while fetching crop data: ${e.toString()}');
      return null;
    } on Exception catch (e) {
      print('Get crop data error: ${e.toString()}');
      return null;
    }
  }

  // Refresh token method
  Future<bool> refreshToken() async {
    if (_isRefreshing) {
      // If already refreshing, add to queue
      return Future.delayed(Duration(seconds: 1), () => refreshToken());
    }

    _isRefreshing = true;
    try {
      final refreshToken = await _getRefreshToken();
      if (refreshToken == null) {
        print('No refresh token available');
        return false;
      }
    
      final client = getClient();
      try {
        final response = await client.post(
          Uri.parse('$baseUrl/api/auth/refresh-token'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'refreshToken': refreshToken}),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['success'] == true && data['token'] != null) {
            await _saveToken(data['token']);
            return true;
          }
        }
        return false;
      } finally {
        client.close();
      }
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  // Verify phone number for password reset
  Future<ApiResponse> verifyPhoneNumber(String phoneNumber) async {
    try {
      final client = getClient();
      final response = await client
          .post(
            Uri.parse('$baseUrl/api/auth/verify-phone'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'phoneNumber': phoneNumber,
            }),
          )
          .timeout(Duration(seconds: 20));
    
    client.close();
    
      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return ApiResponse(
          success: true,
          message: responseData['message'] ?? 'Phone number verified',
          data: responseData['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: responseData['message'] ?? 'Phone number not found',
        );
      }
    } catch (e) {
      print('Error verifying phone number: $e');
      return ApiResponse(
        success: false,
        message: 'Connection error during verification',
      );
    }
  }

  // Reset password after OTP verification
  Future<ApiResponse> resetPassword(String username, String newPassword) async {
    try {
      final client = getClient();
      final response = await client
          .post(
            Uri.parse('$baseUrl/api/auth/reset-password'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'username': username,
              'newPassword': newPassword,
            }),
          )
          .timeout(Duration(seconds: 20));

      client.close();

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return ApiResponse(
          success: true,
          message: responseData['message'] ?? 'Password reset successful',
          data: responseData['data'],
        );
      } else {
        return ApiResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to reset password',
        );
      }
    } catch (e) {
      print('Error resetting password: $e');
      return ApiResponse(
        success: false,
        message: 'Connection error during password reset',
      );
    }
  }

  Future<ApiResponse> getUserByUsername(String username) async {
    try {
      print('🔍 Fetching user details for username: $username');
      final client = getClient();
      
      final url = Uri.parse('$baseUrl/api/auth/user/$username');
      print('🌐 User details URL: $url');
      
      final response = await client
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
          )
          .timeout(Duration(seconds: 20));

      print('📡 User details response status: ${response.statusCode}');
      print('📦 User details response body: ${response.body}');

      client.close();

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return ApiResponse(
          success: true,
          data: responseData['data'],
          message: responseData['message'],
        );
      }
      return ApiResponse(
        success: false,
        message: responseData['message'] ?? 'Failed to fetch user details',
      );
    } catch (e) {
      print('❌ Error fetching user details: $e');
      return ApiResponse(
        success: false,
        message: 'Connection error. Please check your internet and try again.',
      );
  }
}

  Future<ApiResponse> updateUserProfile(String username, Map<String, dynamic> userData) async {
    try {
      print('🔄 Updating profile for username: $username');
      final token = await _getToken();
      if (token == null) {
        return ApiResponse(success: false, message: 'No authentication token found');
      }

      final url = Uri.parse('$baseUrl/api/auth/user/$username');
      print('🌐 Update profile URL: $url');

      final client = getClient();
      final response = await client.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(userData),
      );

      print('📡 Update profile response status: ${response.statusCode}');
      print('📦 Update profile response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // Update the current user data in memory
          if (currentUser != null) {
            currentUser!.addAll(userData);
            await _saveUserData(currentUser!);
          }
          return ApiResponse(
            success: true,
            message: data['message'],
            data: data['data'],
          );
        } else {
          return ApiResponse(
            success: false,
            message: data['message'] ?? 'Failed to update profile',
          );
        }
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse(
          success: false,
          message: error['message'] ?? 'Failed to update profile',
        );
      }
    } catch (e) {
      print('❌ Error updating profile: $e');
      return ApiResponse(
        success: false,
        message: 'Error updating profile: $e',
      );
    }
  }

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }
}