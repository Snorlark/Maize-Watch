import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/features/live_monitoring/domain/entities/analytics_entities.dart';

class CacheService {
  static const String _prescriptionsKey = 'cached_prescriptions';
  static const String _analyticsKey = 'cached_analytics';
  static const String _cropConditionKey = 'cached_crop_condition';
  static const String _lastUpdateKey = 'last_cache_update';
  static const String _growthStageKey = 'cached_growth_stage';
  static const String _userKey = 'current_user_id';

  static Future<void> cachePrescriptions(List<PrescriptionModel> prescriptions, {String? userId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prescriptionsJson = prescriptions.map((p) => p.toJson()).toList();
      final key = userId != null ? '${_prescriptionsKey}_$userId' : _prescriptionsKey;
      await prefs.setString(key, jsonEncode(prescriptionsJson));
      await prefs.setString('${_lastUpdateKey}_${userId ?? 'default'}', DateTime.now().toIso8601String());
    } catch (e) {
      print('Error caching prescriptions: $e');
    }
  }

  static Future<List<PrescriptionModel>> getCachedPrescriptions({String? userId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = userId != null ? '${_prescriptionsKey}_$userId' : _prescriptionsKey;
      final prescriptionsJson = prefs.getString(key);
      
      if (prescriptionsJson == null) return [];
      
      final List<dynamic> prescriptionsList = jsonDecode(prescriptionsJson);
      return prescriptionsList.map((json) => PrescriptionModel.fromJson(json)).toList();
    } catch (e) {
      print('Error getting cached prescriptions: $e');
      return [];
    }
  }

  static Future<void> cacheAnalytics(AnalyticsData analytics, {String? userId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = userId != null ? '${_analyticsKey}_$userId' : _analyticsKey;
      await prefs.setString(key, jsonEncode(analytics.toJson()));
      await prefs.setString('${_lastUpdateKey}_${userId ?? 'default'}', DateTime.now().toIso8601String());
    } catch (e) {
      print('Error caching analytics: $e');
    }
  }

  static Future<AnalyticsData?> getCachedAnalytics({String? userId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = userId != null ? '${_analyticsKey}_$userId' : _analyticsKey;
      final analyticsJson = prefs.getString(key);
      
      if (analyticsJson == null) return null;
      
      return AnalyticsData.fromJson(jsonDecode(analyticsJson));
    } catch (e) {
      print('Error getting cached analytics: $e');
      return null;
    }
  }

  static Future<void> cacheCropCondition(CropConditionModel condition) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cropConditionKey, jsonEncode(condition.toJson()));
      await prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('Error caching crop condition: $e');
    }
  }

  static Future<CropConditionModel?> getCachedCropCondition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final conditionJson = prefs.getString(_cropConditionKey);
      
      if (conditionJson == null) return null;
      
      return CropConditionModel.fromJson(jsonDecode(conditionJson));
    } catch (e) {
      print('Error getting cached crop condition: $e');
      return null;
    }
  }

  static Future<void> cacheGrowthStage(String farmId, String fieldId, String growthStage) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${_growthStageKey}_${farmId}_$fieldId';
      await prefs.setString(key, growthStage);
    } catch (e) {
      print('Error caching growth stage: $e');
    }
  }

  static Future<String?> getCachedGrowthStage(String farmId, String fieldId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${_growthStageKey}_${farmId}_$fieldId';
      return prefs.getString(key);
    } catch (e) {
      print('Error getting cached growth stage: $e');
      return null;
    }
  }

  static Future<bool> isCacheValid({Duration maxAge = const Duration(hours: 1)}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdateStr = prefs.getString(_lastUpdateKey);
      
      if (lastUpdateStr == null) return false;
      
      final lastUpdate = DateTime.parse(lastUpdateStr);
      final now = DateTime.now();
      
      return now.difference(lastUpdate) < maxAge;
    } catch (e) {
      print('Error checking cache validity: $e');
      return false;
    }
  }

  static Future<void> clearCache({String? userId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (userId != null) {
        // Clear user-specific cache
        await prefs.remove('${_prescriptionsKey}_$userId');
        await prefs.remove('${_analyticsKey}_$userId');
        await prefs.remove('${_cropConditionKey}_$userId');
        await prefs.remove('${_lastUpdateKey}_$userId');
        
        // Clear user-specific growth stage caches
        final keys = prefs.getKeys();
        for (final key in keys) {
          if (key.startsWith('${_growthStageKey}_') && key.contains('_$userId')) {
            await prefs.remove(key);
          }
        }
      } else {
        // Clear all cache
        await prefs.remove(_prescriptionsKey);
        await prefs.remove(_analyticsKey);
        await prefs.remove(_cropConditionKey);
        await prefs.remove(_lastUpdateKey);
        
        // Clear all growth stage caches
        final keys = prefs.getKeys();
        for (final key in keys) {
          if (key.startsWith(_growthStageKey)) {
            await prefs.remove(key);
          }
        }
      }
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  static Future<void> setCurrentUserId(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, userId);
    } catch (e) {
      print('Error setting current user ID: $e');
    }
  }

  static Future<String?> getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userKey);
    } catch (e) {
      print('Error getting current user ID: $e');
      return null;
    }
  }

  static Future<void> updatePrescription(PrescriptionModel updatedPrescription) async {
    try {
      final prescriptions = await getCachedPrescriptions();
      final index = prescriptions.indexWhere((p) => p.id == updatedPrescription.id);
      
      if (index != -1) {
        prescriptions[index] = updatedPrescription;
      } else {
        prescriptions.add(updatedPrescription);
      }
      
      await cachePrescriptions(prescriptions);
    } catch (e) {
      print('Error updating prescription: $e');
    }
  }

  static Future<void> addPrescription(PrescriptionModel newPrescription) async {
    try {
      final prescriptions = await getCachedPrescriptions();
      prescriptions.add(newPrescription);
      await cachePrescriptions(prescriptions);
    } catch (e) {
      print('Error adding prescription: $e');
    }
  }

  static Future<void> removePrescription(String prescriptionId) async {
    try {
      final prescriptions = await getCachedPrescriptions();
      prescriptions.removeWhere((p) => p.id == prescriptionId);
      await cachePrescriptions(prescriptions);
    } catch (e) {
      print('Error removing prescription: $e');
    }
  }
}
