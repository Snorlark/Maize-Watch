import 'package:shared_preferences/shared_preferences.dart';

class PrescriptionIdMapper {
  static const String _keyPrefix = 'prescription_id_mapping_';
  
  /// Map analytics prescription ID to MongoDB prescription ID
  static Future<void> mapPrescriptionId(String analyticsId, String mongoId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_keyPrefix$analyticsId', mongoId);
      print('🔧 Mapped analytics ID $analyticsId to MongoDB ID $mongoId');
    } catch (e) {
      print('🔧 Error mapping prescription ID: $e');
    }
  }
  
  /// Get MongoDB prescription ID from analytics ID
  static Future<String?> getMongoId(String analyticsId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('$_keyPrefix$analyticsId');
    } catch (e) {
      print('🔧 Error getting MongoDB ID: $e');
      return null;
    }
  }
  
  /// Clear all mappings
  static Future<void> clearMappings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_keyPrefix)) {
          await prefs.remove(key);
        }
      }
      print('🔧 Cleared all prescription ID mappings');
    } catch (e) {
      print('🔧 Error clearing mappings: $e');
    }
  }
}
