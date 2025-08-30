import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage service for handling sensitive data like tokens
/// Following clean architecture principles as an infrastructure service
abstract class SecureStorageService {
  Future<void> storeAccessToken(String token);
  Future<void> storeRefreshToken(String token);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearTokens();
  Future<void> storeUserData(String key, String value);
  Future<String?> getUserData(String key);
  Future<void> clearUserData(String key);
  Future<void> storeTokens(String accessToken, String? refreshToken);
  Future<bool> hasValidTokens();
}

class SecureStorageServiceImpl implements SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Token storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  @override
  Future<void> storeAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  @override
  Future<void> storeRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  @override
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  @override
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  @override
  Future<void> storeUserData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<String?> getUserData(String key) async {
    return await _storage.read(key: key);
  }

  @override
  Future<void> clearUserData(String key) async {
    await _storage.delete(key: key);
  }

  /// Store both tokens at once for convenience
  Future<void> storeTokens(String accessToken, String? refreshToken) async {
    await storeAccessToken(accessToken);
    if (refreshToken != null) {
      await storeRefreshToken(refreshToken);
    }
  }

  /// Check if user has valid tokens
  Future<bool> hasValidTokens() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
