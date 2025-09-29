import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();
  
  // Keys for storing data
  static const String _userTokenKey = 'user_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';
  
  // Store user token
  static Future<void> storeToken(String token) async {
    await _storage.write(key: _userTokenKey, value: token);
  }
  
  // Store both access and refresh tokens
  static Future<void> storeTokens(String accessToken, String? refreshToken) async {
    print("🔐 SecureStorage: Storing access token...");
    await _storage.write(key: _userTokenKey, value: accessToken);
    print("🔐 SecureStorage: Access token stored");
    
    if (refreshToken != null) {
      print("🔐 SecureStorage: Storing refresh token...");
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
      print("🔐 SecureStorage: Refresh token stored");
    }
  }
  
  // Get refresh token
  static Future<String?> getRefreshToken() async {
    try {
      final token = await _storage.read(key: _refreshTokenKey);
      print("🔐 SecureStorage: Retrieved refresh token: ${token != null ? "exists" : "null"}");
      if (token != null) {
        print("🔐 SecureStorage: Refresh token preview: ${token.substring(0, 20)}...");
      }
      return token;
    } catch (e) {
      print("🚨 SecureStorage: Error reading refresh token: $e");
      return null;
    }
  }
  
  // Get user token
  static Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: _userTokenKey);
      print("🔐 SecureStorage: Retrieved access token: ${token != null ? "exists" : "null"}");
      if (token != null) {
        print("🔐 SecureStorage: Token preview: ${token.substring(0, 20)}...");
      }
      return token;
    } catch (e) {
      print("🚨 SecureStorage: Error reading access token: $e");
      return null;
    }
  }
  
  // Store user data
  static Future<void> storeUserData(String userData) async {
    print("🔐 SecureStorage: Storing user data...");
    await _storage.write(key: _userDataKey, value: userData);
    print("🔐 SecureStorage: User data stored");
    
    print("🔐 SecureStorage: Setting logged in status...");
    await _storage.write(key: _isLoggedInKey, value: 'true');
    print("🔐 SecureStorage: Logged in status set");
    
    // Verify the data was stored correctly
    final storedUserData = await _storage.read(key: _userDataKey);
    final storedLoginStatus = await _storage.read(key: _isLoggedInKey);
    print("🔐 SecureStorage: Verification - userData stored: ${storedUserData != null ? "Yes" : "No"}");
    print("🔐 SecureStorage: Verification - loginStatus stored: $storedLoginStatus");
  }
  
  // Get user data
  static Future<String?> getUserData() async {
    try {
      final userData = await _storage.read(key: _userDataKey);
      print("🔐 SecureStorage: Retrieved user data: ${userData != null ? "exists" : "null"}");
      if (userData != null) {
        print("🔐 SecureStorage: User data preview: ${userData.substring(0, 50)}...");
      }
      return userData;
    } catch (e) {
      print("🚨 SecureStorage: Error reading user data: $e");
      return null;
    }
  }
  
  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final isLoggedIn = await _storage.read(key: _isLoggedInKey);
    print("🔐 SecureStorage: Retrieved login status: $isLoggedIn");
    final result = isLoggedIn == 'true';
    print("🔐 SecureStorage: Login status result: $result");
    return result;
  }
  
  // Clear all stored data (logout)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
  
  // Clear specific keys
  static Future<void> clearUserSession() async {
    print("🔐 SecureStorage: Clearing user session...");
    await _storage.delete(key: _userTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userDataKey);
    await _storage.delete(key: _isLoggedInKey);
    print("🔐 SecureStorage: User session cleared");
  }

  static write({required String key, required String value}) {
    return _storage.write(key: key, value: value);
  }

  static read({required String key}) {
    return _storage.read(key: key);
  }

  // Debug method to check all stored keys
  static Future<Map<String, String?>> getAllStoredData() async {
    try {
      final token = await _storage.read(key: _userTokenKey);
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      final userData = await _storage.read(key: _userDataKey);
      final isLoggedIn = await _storage.read(key: _isLoggedInKey);
      
      return {
        'accessToken': token,
        'refreshToken': refreshToken,
        'userData': userData,
        'isLoggedIn': isLoggedIn,
      };
    } catch (e) {
      print("🚨 SecureStorage: Error reading all stored data: $e");
      return {};
    }
  }
}
