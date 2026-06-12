import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Simple script to clear all notifications and reset notification tracking
/// Run this if you have too many notifications stacked up
Future<void> clearAllNotifications() async {
  try {
    print('🧹 Clearing all notifications...');
    
    // Initialize notification plugin
    final FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();
    
    // Cancel all notifications
    await notifications.cancelAll();
    print('✅ Cancelled all notifications');
    
    // Clear SharedPreferences notification tracking
    final prefs = await SharedPreferences.getInstance();
    
    // Get all keys that start with 'notified_prescriptions_'
    final keys = prefs.getKeys();
    final notificationKeys = keys.where((key) => key.startsWith('notified_prescriptions_')).toList();
    
    for (final key in notificationKeys) {
      await prefs.remove(key);
      print('✅ Cleared notification tracking: $key');
    }
    
    // Clear other notification-related keys
    final otherKeys = ['notifications_enabled', 'selected_language_code'];
    for (final key in otherKeys) {
      if (keys.contains(key)) {
        print('ℹ️ Found key: $key = ${prefs.get(key)}');
      }
    }
    
    print('🎉 Successfully cleared all notifications and tracking data!');
    
  } catch (e) {
    print('❌ Error clearing notifications: $e');
  }
}

void main() async {
  await clearAllNotifications();
}
