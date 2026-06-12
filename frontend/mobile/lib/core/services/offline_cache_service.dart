import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/core/storage/secure_storage.dart';

class OfflineCacheService {
  static const String _prescriptionsKey = 'cached_prescriptions';
  static const String _notificationsKey = 'cached_notifications';
  static const String _liveDataKey = 'cached_live_data';
  static const String _settingsKey = 'cached_settings';
  static const String _analyticsKey = 'cached_analytics';
  static const String _lastSyncKey = 'last_sync_timestamp';

  // Cache prescriptions
  static Future<void> cachePrescriptions(List<Map<String, dynamic>> prescriptions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authState = await _getCurrentUser();
      if (authState == null) return;

      final cacheKey = '${_prescriptionsKey}_${authState['id']}';
      final jsonString = json.encode(prescriptions);
      await prefs.setString(cacheKey, jsonString);
      await prefs.setString('${_lastSyncKey}_prescriptions', DateTime.now().toIso8601String());
      
      print('💾 OFFLINE CACHE: Cached ${prescriptions.length} prescriptions for user ${authState['id']}');
    } catch (e) {
      print('💾 OFFLINE CACHE: Error caching prescriptions: $e');
    }
  }

  // Get cached prescriptions
  static Future<List<Map<String, dynamic>>> getCachedPrescriptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authState = await _getCurrentUser();
      if (authState == null) return [];

      final cacheKey = '${_prescriptionsKey}_${authState['id']}';
      final jsonString = prefs.getString(cacheKey);
      
      if (jsonString != null) {
        final List<dynamic> decoded = json.decode(jsonString);
        final prescriptions = decoded.cast<Map<String, dynamic>>();
        print('💾 OFFLINE CACHE: Retrieved ${prescriptions.length} cached prescriptions');
        return prescriptions;
      }
      
      return [];
    } catch (e) {
      print('💾 OFFLINE CACHE: Error getting cached prescriptions: $e');
      return [];
    }
  }

  // Cache notifications
  static Future<void> cacheNotifications(List<Map<String, dynamic>> notifications) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authState = await _getCurrentUser();
      if (authState == null) return;

      final cacheKey = '${_notificationsKey}_${authState['id']}';
      final jsonString = json.encode(notifications);
      await prefs.setString(cacheKey, jsonString);
      await prefs.setString('${_lastSyncKey}_notifications', DateTime.now().toIso8601String());
      
      print('💾 OFFLINE CACHE: Cached ${notifications.length} notifications for user ${authState['id']}');
    } catch (e) {
      print('💾 OFFLINE CACHE: Error caching notifications: $e');
    }
  }

  // Get cached notifications
  static Future<List<Map<String, dynamic>>> getCachedNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authState = await _getCurrentUser();
      if (authState == null) return [];

      final cacheKey = '${_notificationsKey}_${authState['id']}';
      final jsonString = prefs.getString(cacheKey);
      
      if (jsonString != null) {
        final List<dynamic> decoded = json.decode(jsonString);
        final notifications = decoded.cast<Map<String, dynamic>>();
        print('💾 OFFLINE CACHE: Retrieved ${notifications.length} cached notifications');
        return notifications;
      }
      
      return [];
    } catch (e) {
      print('💾 OFFLINE CACHE: Error getting cached notifications: $e');
      return [];
    }
  }

  // Cache live data
  static Future<void> cacheLiveData(Map<String, dynamic> liveData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authState = await _getCurrentUser();
      if (authState == null) return;

      final cacheKey = '${_liveDataKey}_${authState['id']}';
      final jsonString = json.encode(liveData);
      await prefs.setString(cacheKey, jsonString);
      await prefs.setString('${_lastSyncKey}_live_data', DateTime.now().toIso8601String());
      
      print('💾 OFFLINE CACHE: Cached live data for user ${authState['id']}');
    } catch (e) {
      print('💾 OFFLINE CACHE: Error caching live data: $e');
    }
  }

  // Get cached live data
  static Future<Map<String, dynamic>?> getCachedLiveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authState = await _getCurrentUser();
      if (authState == null) return null;

      final cacheKey = '${_liveDataKey}_${authState['id']}';
      final jsonString = prefs.getString(cacheKey);
      
      if (jsonString != null) {
        final liveData = json.decode(jsonString) as Map<String, dynamic>;
        print('💾 OFFLINE CACHE: Retrieved cached live data');
        return liveData;
      }
      
      return null;
    } catch (e) {
      print('💾 OFFLINE CACHE: Error getting cached live data: $e');
      return null;
    }
  }

  // Cache settings
  static Future<void> cacheSettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authState = await _getCurrentUser();
      if (authState == null) return;

      final cacheKey = '${_settingsKey}_${authState['id']}';
      final jsonString = json.encode(settings);
      await prefs.setString(cacheKey, jsonString);
      await prefs.setString('${_lastSyncKey}_settings', DateTime.now().toIso8601String());
      
      print('💾 OFFLINE CACHE: Cached settings for user ${authState['id']}');
    } catch (e) {
      print('💾 OFFLINE CACHE: Error caching settings: $e');
    }
  }

  // Get cached settings
  static Future<Map<String, dynamic>?> getCachedSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authState = await _getCurrentUser();
      if (authState == null) return null;

      final cacheKey = '${_settingsKey}_${authState['id']}';
      final jsonString = prefs.getString(cacheKey);
      
      if (jsonString != null) {
        final settings = json.decode(jsonString) as Map<String, dynamic>;
        print('💾 OFFLINE CACHE: Retrieved cached settings');
        return settings;
      }
      
      return null;
    } catch (e) {
      print('💾 OFFLINE CACHE: Error getting cached settings: $e');
      return null;
    }
  }

  // Cache analytics data with user-specific key
  static Future<void> cacheAnalytics(Map<String, dynamic> analytics, {String? farmId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authState = await _getCurrentUser();
      if (authState == null) return;

      final cacheKey = '${_analyticsKey}_${authState['id']}${farmId != null ? '_$farmId' : ''}';
      final cacheData = {
        'data': analytics,
        'timestamp': DateTime.now().toIso8601String(),
        'farmId': farmId,
        'userId': authState['id']
      };
      
      final jsonString = json.encode(cacheData);
      await prefs.setString(cacheKey, jsonString);
      await prefs.setString('${_lastSyncKey}_analytics', DateTime.now().toIso8601String());
      
      print('💾 OFFLINE CACHE: Cached analytics for user ${authState['id']}${farmId != null ? ' farm $farmId' : ''}');
    } catch (e) {
      print('💾 OFFLINE CACHE: Error caching analytics: $e');
    }
  }

  // Get cached analytics with freshness check
  static Future<Map<String, dynamic>?> getCachedAnalytics({String? farmId, int maxAgeMinutes = 30}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authState = await _getCurrentUser();
      if (authState == null) return null;

      final cacheKey = '${_analyticsKey}_${authState['id']}${farmId != null ? '_$farmId' : ''}';
      final jsonString = prefs.getString(cacheKey);
      
      if (jsonString != null) {
        final cacheData = json.decode(jsonString) as Map<String, dynamic>;
        final timestamp = DateTime.parse(cacheData['timestamp']);
        final age = DateTime.now().difference(timestamp);
        
        if (age.inMinutes <= maxAgeMinutes) {
          print('💾 OFFLINE CACHE: Retrieved fresh cached analytics (age: ${age.inMinutes}m)');
          return Map<String, dynamic>.from(cacheData['data']);
        } else {
          print('💾 OFFLINE CACHE: Cached analytics expired (age: ${age.inMinutes}m)');
          return null;
        }
      }
      
      return null;
    } catch (e) {
      print('💾 OFFLINE CACHE: Error getting cached analytics: $e');
      return null;
    }
  }

  // Get all cached data for current user (for offline mode)
  static Future<Map<String, dynamic>> getAllCachedData() async {
    try {
      final authState = await _getCurrentUser();
      if (authState == null) return {};

      final prescriptions = await getCachedPrescriptions();
      final notifications = await getCachedNotifications();
      final liveData = await getCachedLiveData();
      final settings = await getCachedSettings();
      final analytics = await getCachedAnalytics();

      return {
        'prescriptions': prescriptions,
        'notifications': notifications,
        'liveData': liveData,
        'settings': settings,
        'analytics': analytics,
        'cachedAt': DateTime.now().toIso8601String(),
        'userId': authState['id']
      };
    } catch (e) {
      print('💾 OFFLINE CACHE: Error getting all cached data: $e');
      return {};
    }
  }

  // Check if cache is fresh (less than 1 hour old)
  static Future<bool> isCacheFresh(String dataType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncString = prefs.getString('${_lastSyncKey}_$dataType');
      
      if (lastSyncString == null) return false;
      
      final lastSync = DateTime.parse(lastSyncString);
      final now = DateTime.now();
      final difference = now.difference(lastSync);
      
      return difference.inHours < 1; // Cache is fresh if less than 1 hour old
    } catch (e) {
      print('💾 OFFLINE CACHE: Error checking cache freshness: $e');
      return false;
    }
  }

  // Clear all cache for current user
  static Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authState = await _getCurrentUser();
      if (authState == null) return;

      final userId = authState['id'];
      final keysToRemove = [
        '${_prescriptionsKey}_$userId',
        '${_notificationsKey}_$userId',
        '${_liveDataKey}_$userId',
        '${_settingsKey}_$userId',
        '${_analyticsKey}_$userId',
        '${_lastSyncKey}_prescriptions',
        '${_lastSyncKey}_notifications',
        '${_lastSyncKey}_live_data',
        '${_lastSyncKey}_settings',
        '${_lastSyncKey}_analytics',
      ];

      for (final key in keysToRemove) {
        await prefs.remove(key);
      }
      
      print('💾 OFFLINE CACHE: Cleared all cache for user $userId');
    } catch (e) {
      print('💾 OFFLINE CACHE: Error clearing cache: $e');
    }
  }

  // Get current user data
  static Future<Map<String, dynamic>?> _getCurrentUser() async {
    try {
      final userDataString = await SecureStorage.getUserData();
      if (userDataString == null) return null;
      
      return json.decode(userDataString) as Map<String, dynamic>;
    } catch (e) {
      print('💾 OFFLINE CACHE: Error getting current user: $e');
      return null;
    }
  }

  // Cache completion status for prescriptions
  static Future<void> cachePrescriptionCompletion(String prescriptionId, bool isCompleted) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authState = await _getCurrentUser();
      if (authState == null) return;

      final completionKey = 'completion_${authState['id']}_$prescriptionId';
      await prefs.setBool(completionKey, isCompleted);
      
      print('💾 OFFLINE CACHE: Cached completion status for prescription $prescriptionId: $isCompleted');
    } catch (e) {
      print('💾 OFFLINE CACHE: Error caching prescription completion: $e');
    }
  }

  // Get completion status for prescription
  static Future<bool> getPrescriptionCompletion(String prescriptionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authState = await _getCurrentUser();
      if (authState == null) return false;

      final completionKey = 'completion_${authState['id']}_$prescriptionId';
      return prefs.getBool(completionKey) ?? false;
    } catch (e) {
      print('💾 OFFLINE CACHE: Error getting prescription completion: $e');
      return false;
    }
  }

  // Clear analytics cache for a specific farm
  static Future<void> clearAnalyticsCache({String? farmId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authState = await _getCurrentUser();
      if (authState == null) return;

      final cacheKey = '${_analyticsKey}_${authState['id']}${farmId != null ? '_$farmId' : ''}';
      await prefs.remove(cacheKey);
      
      // Also clear the timestamp
      await prefs.remove('${_lastSyncKey}_analytics${farmId != null ? '_$farmId' : ''}');
      
      print('💾 OFFLINE CACHE: Cleared analytics cache${farmId != null ? ' for farm $farmId' : ''}');
    } catch (e) {
      print('💾 OFFLINE CACHE: Error clearing analytics cache: $e');
    }
  }

}
