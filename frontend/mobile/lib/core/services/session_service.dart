import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/environment.dart';
import '../storage/secure_storage.dart';
import '../../features/authentication/domain/entities/user.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  Timer? _refreshTimer;
  Timer? _sessionTimeoutTimer;
  bool _isRefreshing = false;
  final Dio _dio = Dio();

  // Session configuration
  static const int _refreshThresholdMinutes = 5; // Refresh token 5 minutes before expiry
  static const int _sessionTimeoutMinutes = 60; // Auto-logout after 30 minutes of inactivity
  static const int _maxRefreshAttempts = 3;

  // Session state
  bool _isSessionActive = false;
  DateTime? _lastActivity;
  int _refreshAttempts = 0;

  // Getters
  bool get isSessionActive => _isSessionActive;
  DateTime? get lastActivity => _lastActivity;

  /// Initialize session management
  Future<void> initialize() async {
    try {
      debugPrint('🔐 SessionService: Starting session initialization...');
      
      // Debug: Check what's actually stored
      final allKeys = await _debugGetAllKeys();
      debugPrint('🔐 SessionService: All stored keys: $allKeys');
      
      final hasToken = await SecureStorage.getToken();
      final hasRefreshToken = await SecureStorage.getRefreshToken();
      final isLoggedIn = await SecureStorage.isLoggedIn();
      
      debugPrint('🔐 SessionService: Token check - hasToken: ${hasToken != null}, hasRefreshToken: ${hasRefreshToken != null}, isLoggedIn: $isLoggedIn');
      
      if (hasToken != null) {
        debugPrint('🔐 SessionService: Token preview: ${hasToken.substring(0, 20)}...');
      }
      if (hasRefreshToken != null) {
        debugPrint('🔐 SessionService: Refresh token preview: ${hasRefreshToken.substring(0, 20)}...');
      }
      
      if (hasToken != null && isLoggedIn) {
        // Check if token is still valid
        final isTokenValid = !await _isTokenExpired(hasToken);
        debugPrint('🔐 SessionService: Token validity check - isTokenValid: $isTokenValid');
        
        if (isTokenValid) {
          _isSessionActive = true;
          _lastActivity = DateTime.now();
          _startSessionTimers();
          debugPrint('🔐 SessionService: Session initialized successfully');
        } else {
          debugPrint('🔐 SessionService: Token expired, attempting refresh...');
          final refreshSuccess = await refreshAccessToken();
          if (refreshSuccess) {
            _isSessionActive = true;
            _lastActivity = DateTime.now();
            _startSessionTimers();
            debugPrint('🔐 SessionService: Session initialized after token refresh');
          } else {
            debugPrint('🔐 SessionService: Token refresh failed, but keeping session data for authentication bloc to handle');
            // Don't clear session here - let the authentication bloc decide what to do
            _isSessionActive = false;
          }
        }
      } else {
        debugPrint('🔐 SessionService: No valid session found - missing tokens or login status');
        // Don't clear session here - let the authentication bloc handle it
        _isSessionActive = false;
      }
    } catch (e) {
      debugPrint('🔐 SessionService: Error initializing session: $e');
      // Don't clear session on error - let the authentication bloc handle it
      _isSessionActive = false;
    }
  }

  /// Debug function to get all stored keys
  Future<List<String>> _debugGetAllKeys() async {
    try {
      // This is a debug function - in production, we wouldn't expose all keys
      final allData = await SecureStorage.getAllStoredData();
      
      return [
        'token: ${allData['accessToken'] != null ? "exists" : "null"}',
        'refreshToken: ${allData['refreshToken'] != null ? "exists" : "null"}',
        'userData: ${allData['userData'] != null ? "exists" : "null"}',
        'isLoggedIn: ${allData['isLoggedIn']}',
      ];
    } catch (e) {
      return ['Error reading keys: $e'];
    }
  }

  /// Start session after successful login
  Future<void> startSession(String accessToken, String refreshToken, User user) async {
    try {
      // Store tokens and user data
      await SecureStorage.storeTokens(accessToken, refreshToken);
      await SecureStorage.storeUserData(jsonEncode({
        'id': user.id,
        'username': user.username,
        'fullName': user.fullName,
        'contactNumber': user.contactNumber,
        'address': user.address,
        'role': user.role,
      }));

      _isSessionActive = true;
      _lastActivity = DateTime.now();
      _refreshAttempts = 0;
      
      _startSessionTimers();
      debugPrint('🔐 SessionService: Session started for user ${user.username}');
    } catch (e) {
      debugPrint('🔐 SessionService: Error starting session: $e');
      throw SessionException('Failed to start session: $e');
    }
  }

  /// Update last activity timestamp
  void updateActivity() {
    if (_isSessionActive) {
      _lastActivity = DateTime.now();
      debugPrint('🔐 SessionService: Activity updated at ${_lastActivity}');
    }
  }

  /// Check if session is valid
  Future<bool> isSessionValid() async {
    if (!_isSessionActive) return false;

    try {
      final token = await SecureStorage.getToken();
      if (token == null) return false;

      // Check if token is expired
      final isExpired = await _isTokenExpired(token);
      if (isExpired) {
        debugPrint('🔐 SessionService: Access token expired, attempting refresh');
        // Try to refresh, but don't fail if network is unavailable
        final refreshSuccess = await refreshAccessToken();
        if (!refreshSuccess) {
          debugPrint('🔐 SessionService: Token refresh failed, but allowing offline access');
          // Allow offline access even if refresh failed
          return true;
        }
        return refreshSuccess;
      }

      return true;
    } catch (e) {
      debugPrint('🔐 SessionService: Error checking session validity: $e');
      // Allow offline access even if there's an error
      return true;
    }
  }

  /// Refresh access token using refresh token
  Future<bool> refreshAccessToken() async {
    if (_isRefreshing) {
      debugPrint('🔐 SessionService: Token refresh already in progress');
      return false;
    }

    if (_refreshAttempts >= _maxRefreshAttempts) {
      debugPrint('🔐 SessionService: Max refresh attempts reached, clearing session');
      await clearSession();
      return false;
    }

    _isRefreshing = true;
    _refreshAttempts++;

    try {
      final refreshToken = await SecureStorage.getRefreshToken();
      if (refreshToken == null) {
        throw SessionException('No refresh token available');
      }

      debugPrint('🔐 SessionService: Refreshing access token (attempt $_refreshAttempts)');

      final response = await _dio.post(
        '${AppConfig.baseUrl}/api/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final newAccessToken = data['accessToken'];
        
        // Store new access token
        await SecureStorage.storeTokens(newAccessToken, refreshToken);
        
        _refreshAttempts = 0;
        _lastActivity = DateTime.now();
        
        debugPrint('🔐 SessionService: Access token refreshed successfully');
        return true;
      } else {
        throw SessionException('Token refresh failed: ${response.data['message']}');
      }
    } catch (e) {
      debugPrint('🔐 SessionService: Token refresh failed: $e');
      
      // Only clear session for authentication errors, not network errors
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          debugPrint('🔐 SessionService: Unauthorized, clearing session');
          await clearSession();
        } else if (e.type == DioExceptionType.connectionTimeout || 
                   e.type == DioExceptionType.receiveTimeout ||
                   e.type == DioExceptionType.sendTimeout) {
          debugPrint('🔐 SessionService: Network timeout, allowing offline access');
          // Don't clear session for network timeouts
        }
      }
      
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Check if token is expired
  Future<bool> _isTokenExpired(String token) async {
    try {
      // Decode JWT token to check expiration
      final parts = token.split('.');
      if (parts.length != 3) {
        debugPrint('🔐 SessionService: Invalid JWT token format');
        return true;
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      final payloadMap = jsonDecode(resp);

      final exp = payloadMap['exp'] as int?;
      if (exp == null) {
        debugPrint('🔐 SessionService: No expiration time in token');
        return true;
      }

      final expirationTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();
      final timeUntilExpiry = expirationTime.difference(now);

      debugPrint('🔐 SessionService: Token expires in ${timeUntilExpiry.inMinutes} minutes');
      
      // Consider token expired if it expires within the refresh threshold
      final isExpired = timeUntilExpiry.inMinutes <= _refreshThresholdMinutes;
      debugPrint('🔐 SessionService: Token is expired: $isExpired');
      
      return isExpired;
    } catch (e) {
      debugPrint('🔐 SessionService: Error checking token expiration: $e');
      return true; // Assume expired if we can't parse
    }
  }

  /// Start session timers
  void _startSessionTimers() {
    _stopSessionTimers();
    
    // Start refresh timer (check every minute)
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      if (_isSessionActive) {
        final isValid = await isSessionValid();
        if (!isValid) {
          debugPrint('🔐 SessionService: Session invalid, stopping timers');
          _stopSessionTimers();
        }
      }
    });

    // Start session timeout timer
    _sessionTimeoutTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_isSessionActive && _lastActivity != null) {
        final timeSinceActivity = DateTime.now().difference(_lastActivity!);
        if (timeSinceActivity.inMinutes >= _sessionTimeoutMinutes) {
          debugPrint('🔐 SessionService: Session timeout reached, clearing session');
          clearSession();
        }
      }
    });
  }

  /// Stop session timers
  void _stopSessionTimers() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _sessionTimeoutTimer?.cancel();
    _sessionTimeoutTimer = null;
  }

  /// Clear session and logout
  Future<void> clearSession() async {
    debugPrint('🔐 SessionService: Clearing session');
    
    _stopSessionTimers();
    _isSessionActive = false;
    _lastActivity = null;
    _refreshAttempts = 0;
    _isRefreshing = false;
    
    await SecureStorage.clearUserSession();
  }

  /// Get current access token (with automatic refresh if needed)
  Future<String?> getValidAccessToken() async {
    if (!_isSessionActive) return null;

    try {
      final isValid = await isSessionValid();
      if (isValid) {
        updateActivity();
        return await SecureStorage.getToken();
      }
      return null;
    } catch (e) {
      debugPrint('🔐 SessionService: Error getting valid access token: $e');
      return null;
    }
  }

  /// Force logout (for manual logout)
  Future<void> logout() async {
    debugPrint('🔐 SessionService: Manual logout initiated');
    await clearSession();
  }

  /// Dispose resources
  void dispose() {
    _stopSessionTimers();
  }
}

class SessionException implements Exception {
  final String message;
  SessionException(this.message);
  
  @override
  String toString() => 'SessionException: $message';
}
