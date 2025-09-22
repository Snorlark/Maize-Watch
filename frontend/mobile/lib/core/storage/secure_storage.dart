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
    final token = await _storage.read(key: _refreshTokenKey);
    print("🔐 SecureStorage: Retrieved refresh token: ${token != null ? "exists" : "null"}");
    return token;
  }
  
  // Get user token
  static Future<String?> getToken() async {
    final token = await _storage.read(key: _userTokenKey);
    print("🔐 SecureStorage: Retrieved access token: ${token != null ? "exists" : "null"}");
    return token;
  }
  
  // Store user data
  static Future<void> storeUserData(String userData) async {
    print("🔐 SecureStorage: Storing user data...");
    await _storage.write(key: _userDataKey, value: userData);
    print("🔐 SecureStorage: User data stored");
    
    print("🔐 SecureStorage: Setting logged in status...");
    await _storage.write(key: _isLoggedInKey, value: 'true');
    print("🔐 SecureStorage: Logged in status set");
  }
  
  // Get user data
  static Future<String?> getUserData() async {
    final userData = await _storage.read(key: _userDataKey);
    print("🔐 SecureStorage: Retrieved user data: ${userData != null ? "exists" : "null"}");
    return userData;
  }
  
  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final isLoggedIn = await _storage.read(key: _isLoggedInKey);
    print("🔐 SecureStorage: Retrieved login status: $isLoggedIn");
    return isLoggedIn == 'true';
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
}
