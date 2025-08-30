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
    await _storage.write(key: _userTokenKey, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }
  
  // Get refresh token
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }
  
  // Get user token
  static Future<String?> getToken() async {
    return await _storage.read(key: _userTokenKey);
  }
  
  // Store user data
  static Future<void> storeUserData(String userData) async {
    await _storage.write(key: _userDataKey, value: userData);
    await _storage.write(key: _isLoggedInKey, value: 'true');
  }
  
  // Get user data
  static Future<String?> getUserData() async {
    return await _storage.read(key: _userDataKey);
  }
  
  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final isLoggedIn = await _storage.read(key: _isLoggedInKey);
    return isLoggedIn == 'true';
  }
  
  // Clear all stored data (logout)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
  
  // Clear specific keys
  static Future<void> clearUserSession() async {
    await _storage.delete(key: _userTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userDataKey);
    await _storage.delete(key: _isLoggedInKey);
  }
}
