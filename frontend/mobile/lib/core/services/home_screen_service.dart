import 'dart:async';
import 'dart:convert';
import 'package:mobile/core/services/offline_cache_service.dart';
import 'package:mobile/core/network/api_client.dart';
import 'package:mobile/core/storage/secure_storage.dart';

class HomeScreenService {
  static const int _cacheValidityMinutes = 30;
  static Timer? _refreshTimer;

  /// Get all home screen data with smart caching
  /// Returns cached data immediately if fresh, then updates in background
  static Future<Map<String, dynamic>> getHomeScreenData({
    bool forceRefresh = false,
    String? farmId,
  }) async {
    try {
      // 1. Try to get cached data first (instant load)
      if (!forceRefresh) {
        final cachedData = await _getCachedHomeData(farmId);
        if (cachedData.isNotEmpty) {
          print('🏠 HOME: Using cached data for instant load');
          
          // Start background refresh if data is getting stale
          _startBackgroundRefresh(farmId);
          
          return cachedData;
        }
      }

      // 2. If no cache or force refresh, load fresh data
      print('🏠 HOME: Loading fresh data from server');
      return await _loadFreshHomeData(farmId);
      
    } catch (e) {
      print('🏠 HOME: Error loading home data: $e');
      
      // Fallback to cached data even if stale
      final fallbackData = await _getCachedHomeData(farmId, allowStale: true);
      return fallbackData;
    }
  }

  /// Get cached home data with freshness check
  static Future<Map<String, dynamic>> _getCachedHomeData(String? farmId, {bool allowStale = false}) async {
    try {
      final analytics = await OfflineCacheService.getCachedAnalytics(
        farmId: farmId,
        maxAgeMinutes: allowStale ? 999999 : _cacheValidityMinutes,
      );
      
      final prescriptions = await OfflineCacheService.getCachedPrescriptions();
      final notifications = await OfflineCacheService.getCachedNotifications();
      final liveData = await OfflineCacheService.getCachedLiveData();
      final settings = await OfflineCacheService.getCachedSettings();

      return {
        'analytics': analytics,
        'prescriptions': prescriptions,
        'notifications': notifications,
        'liveData': liveData,
        'settings': settings,
        'cached': true,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('🏠 HOME: Error getting cached data: $e');
      return {};
    }
  }

  /// Load fresh data from server
  static Future<Map<String, dynamic>> _loadFreshHomeData(String? farmId) async {
    try {
      final authState = await _getCurrentUser();
      if (authState == null) throw Exception('User not authenticated');

      // Load all data in parallel for faster response
      final futures = await Future.wait([
        _loadAnalytics(farmId),
        _loadPrescriptions(),
        _loadNotifications(),
        _loadLiveData(),
        _loadSettings(),
      ]);

      final result = {
        'analytics': futures[0],
        'prescriptions': futures[1],
        'notifications': futures[2],
        'liveData': futures[3],
        'settings': futures[4],
        'cached': false,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Cache all the data for next time
      await _cacheAllData(result, farmId);

      return result;
    } catch (e) {
      print('🏠 HOME: Error loading fresh data: $e');
      rethrow;
    }
  }

  /// Load analytics data
  static Future<Map<String, dynamic>?> _loadAnalytics(String? farmId) async {
    try {
      if (farmId == null) return null;
      
      final response = await ApiClient.get('/analytics/farms/$farmId/complete');
      final analytics = response.data['data'];
      
      // Cache analytics with farm ID
      await OfflineCacheService.cacheAnalytics(analytics, farmId: farmId);
      
      return analytics;
    } catch (e) {
      print('🏠 HOME: Error loading analytics: $e');
      return null;
    }
  }

  /// Load prescriptions data
  static Future<List<Map<String, dynamic>>> _loadPrescriptions() async {
    try {
      final response = await ApiClient.get('/prescriptions');
      final prescriptions = List<Map<String, dynamic>>.from(response.data['data']);
      
      // Cache prescriptions
      await OfflineCacheService.cachePrescriptions(prescriptions);
      
      return prescriptions;
    } catch (e) {
      print('🏠 HOME: Error loading prescriptions: $e');
      return [];
    }
  }

  /// Load notifications data
  static Future<List<Map<String, dynamic>>> _loadNotifications() async {
    try {
      final response = await ApiClient.get('/notifications');
      final notifications = List<Map<String, dynamic>>.from(response.data['data']);
      
      // Cache notifications
      await OfflineCacheService.cacheNotifications(notifications);
      
      return notifications;
    } catch (e) {
      print('🏠 HOME: Error loading notifications: $e');
      return [];
    }
  }

  /// Load live data
  static Future<Map<String, dynamic>?> _loadLiveData() async {
    try {
      final response = await ApiClient.get('/monitoring/live');
      final liveData = response.data['data'];
      
      // Cache live data
      await OfflineCacheService.cacheLiveData(liveData);
      
      return liveData;
    } catch (e) {
      print('🏠 HOME: Error loading live data: $e');
      return null;
    }
  }

  /// Load settings data
  static Future<Map<String, dynamic>?> _loadSettings() async {
    try {
      final response = await ApiClient.get('/settings');
      final settings = response.data['data'];
      
      // Cache settings
      await OfflineCacheService.cacheSettings(settings);
      
      return settings;
    } catch (e) {
      print('🏠 HOME: Error loading settings: $e');
      return null;
    }
  }

  /// Cache all data for offline access
  static Future<void> _cacheAllData(Map<String, dynamic> data, String? farmId) async {
    try {
      if (data['analytics'] != null) {
        await OfflineCacheService.cacheAnalytics(data['analytics'], farmId: farmId);
      }
      if (data['prescriptions'] != null) {
        await OfflineCacheService.cachePrescriptions(data['prescriptions']);
      }
      if (data['notifications'] != null) {
        await OfflineCacheService.cacheNotifications(data['notifications']);
      }
      if (data['liveData'] != null) {
        await OfflineCacheService.cacheLiveData(data['liveData']);
      }
      if (data['settings'] != null) {
        await OfflineCacheService.cacheSettings(data['settings']);
      }
      
      print('🏠 HOME: All data cached successfully');
    } catch (e) {
      print('🏠 HOME: Error caching data: $e');
    }
  }

  /// Start background refresh timer
  static void _startBackgroundRefresh(String? farmId) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(Duration(minutes: 5), (timer) async {
      try {
        print('🏠 HOME: Background refresh triggered');
        await _loadFreshHomeData(farmId);
      } catch (e) {
        print('🏠 HOME: Background refresh failed: $e');
      }
    });
  }

  /// Stop background refresh
  static void stopBackgroundRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// Get current user from secure storage
  static Future<Map<String, dynamic>?> _getCurrentUser() async {
    try {
      final authState = await SecureStorage.getAuthState();
      if (authState != null) {
        return json.decode(authState);
      }
      return null;
    } catch (e) {
      print('🏠 HOME: Error getting current user: $e');
      return null;
    }
  }

  /// Clear all cached data for current user
  static Future<void> clearUserCache() async {
    try {
      await OfflineCacheService.clearAllCache();
      print('🏠 HOME: User cache cleared');
    } catch (e) {
      print('🏠 HOME: Error clearing cache: $e');
    }
  }
}
