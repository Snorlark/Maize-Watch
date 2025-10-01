import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/generated/l10n.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // Notification IDs
  static const int SENSOR_SLEEP_MODE_ID = 1001;
  static const int PRESCRIPTION_ALERT_ID = 1002;
  static const int SENSOR_OFFLINE_ID = 1003;

  Future<void> initialize() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request notification permissions
    await requestPermissions();

    _isInitialized = true;
  }

  Future<bool> requestPermissions() async {
    try {
      // Request permissions for Android
      if (defaultTargetPlatform == TargetPlatform.android) {
        final bool? granted = await _notifications
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
        
        print("🔔 Android notification permission granted: $granted");
        return granted ?? false;
      }
      
      // Request permissions for iOS
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final bool? granted = await _notifications
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
        
        print("🔔 iOS notification permission granted: $granted");
        return granted ?? false;
      }
      
      return false;
    } catch (e) {
      print("🚨 Error requesting notification permissions: $e");
      return false;
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    debugPrint('Notification tapped: ${response.payload}');
  }

  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notifications_enabled') ?? true;
    final allKeys = prefs.getKeys();
    print('🔔 NotificationService: areNotificationsEnabled() = $enabled');
    print('🔔 NotificationService: All SharedPreferences keys: $allKeys');
    print('🔔 NotificationService: notifications_enabled value: ${prefs.getBool('notifications_enabled')}');
    return enabled;
  }

  Future<bool> arePermissionsGranted() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final bool? granted = await _notifications
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
            ?.areNotificationsEnabled();
        return granted ?? false;
      }
      
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final NotificationsEnabledOptions? granted = await _notifications
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.checkPermissions();
        return granted?.isEnabled ?? false;
      }
      
      return false;
    } catch (e) {
      print("🚨 Error checking notification permissions: $e");
      return false;
    }
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
  }

  Future<bool> isVibrationOnly() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('vibration_only') ?? false;
  }

  Future<void> setVibrationOnly(bool vibrationOnly) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibration_only', vibrationOnly);
  }

  Future<void> showSensorSleepModeNotification() async {
    if (!await areNotificationsEnabled()) return;

    // Check if permissions are granted
    final hasPermissions = await arePermissionsGranted();
    if (!hasPermissions) {
      print('🔔 Notification permissions not granted, requesting permissions...');
      final granted = await requestPermissions();
      if (!granted) {
        print('🔔 Notification permissions denied, cannot show notification');
        return;
      }
    }

    const vibrationOnly = false; // We want sound for sleep mode alerts
    await _showNotification(
      id: SENSOR_SLEEP_MODE_ID,
      title: '🌙 ${S.current.sensors_in_sleep_mode}',
      body: S.current.sensors_sleep_mode_message,
      payload: 'sensor_sleep_mode',
      vibrationOnly: vibrationOnly,
    );
  }

  Future<void> showPrescriptionAlertNotification({
    required String title,
    required String message,
    String? priority,
    int? notificationId,
  }) async {
    print('🔔 NotificationService: Attempting to show prescription notification');
    print('🔔 Title: $title, Message: $message, Priority: $priority');
    
    if (!await areNotificationsEnabled()) {
      print('🔔 Notifications are disabled');
      return;
    }

    // Check if permissions are granted
    final hasPermissions = await arePermissionsGranted();
    if (!hasPermissions) {
      print('🔔 Notification permissions not granted, requesting permissions...');
      final granted = await requestPermissions();
      if (!granted) {
        print('🔔 Notification permissions denied, cannot show notification');
        return;
      }
    }

    final vibrationOnly = await isVibrationOnly();
    final emoji = _getPriorityEmoji(priority);
    
    // Translate the notification content
    final translatedTitle = await _translatePrescriptionTitle(title);
    final translatedMessage = await _translatePrescriptionMessage(message);
    
    print('🔔 Showing notification with emoji: $emoji, vibrationOnly: $vibrationOnly');
    print('🔔 Translated - Title: $translatedTitle, Message: $translatedMessage');
    
    await _showNotification(
      id: notificationId ?? PRESCRIPTION_ALERT_ID,
      title: '$emoji $translatedTitle',
      body: translatedMessage,
      payload: 'prescription_alert',
      vibrationOnly: vibrationOnly,
    );
    
    print('🔔 Notification shown successfully');
  }

  Future<void> showSensorOfflineNotification(String sensorName) async {
    if (!await areNotificationsEnabled()) return;

    // Check if permissions are granted
    final hasPermissions = await arePermissionsGranted();
    if (!hasPermissions) {
      print('🔔 Notification permissions not granted, requesting permissions...');
      final granted = await requestPermissions();
      if (!granted) {
        print('🔔 Notification permissions denied, cannot show notification');
        return;
      }
    }

    final vibrationOnly = await isVibrationOnly();
    
    // Translate the notification content
    final translatedTitle = await _translateSensorOfflineTitle();
    final translatedMessage = await _translateSensorOfflineMessage(sensorName);
    
    await _showNotification(
      id: SENSOR_OFFLINE_ID,
      title: translatedTitle,
      body: translatedMessage,
      payload: 'sensor_offline',
      vibrationOnly: vibrationOnly,
    );
  }

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
    required bool vibrationOnly,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'maize_watch_channel',
      S.current.maize_watch_notifications,
      channelDescription: S.current.notifications_channel_description,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/launcher_icon',      
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  String _getPriorityEmoji(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'immediate':
      case 'high':
        return '🚨';
      case 'medium':
        return '⚠️';
      case 'low':
        return 'ℹ️';
      default:
        return '📋';
    }
  }

  /// Translate prescription notification title
  Future<String> _translatePrescriptionTitle(String title) async {
    try {
      // Get current locale from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final locale = prefs.getString('language') ?? 'en';
      
      switch (title.toLowerCase()) {
        case 'new farm prescriptions':
          return locale == 'tl' ? 'Mga Bagong Reseta sa Bukid' : 'New Farm Prescriptions';
        case 'farm task':
          return locale == 'tl' ? 'Gawain sa Bukid' : 'Farm Task';
        case 'urgent farm task':
          return locale == 'tl' ? 'Mahalagang Gawain sa Bukid' : 'Urgent Farm Task';
        case 'high priority task':
          return locale == 'tl' ? 'Mataas na Priyoridad na Gawain' : 'High Priority Task';
        default:
          return title; // Return original if no translation found
      }
    } catch (e) {
      print('🔔 Error translating title: $e');
      return title; // Fallback to original title
    }
  }

  /// Translate prescription notification message
  Future<String> _translatePrescriptionMessage(String message) async {
    try {
      // Get current locale from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final locale = prefs.getString('language') ?? 'en';
      
      // Check for common message patterns
      if (message.contains('You have') && message.contains('new farm tasks')) {
        final countMatch = RegExp(r'(\d+)').firstMatch(message);
        final count = countMatch?.group(1) ?? '0';
        
        if (locale == 'tl') {
          return 'Mayroon kang $count na bagong gawain sa bukid na kailangang tapusin';
        } else {
          return 'You have $count new farm tasks to complete';
        }
      }
      
      if (message.contains('farm task requires attention')) {
        return locale == 'tl' 
          ? 'Ang gawain sa bukid ay nangangailangan ng atensyon'
          : 'Farm task requires attention';
      }
      
      if (message.contains('requires immediate attention')) {
        return locale == 'tl'
          ? 'Nangangailangan ng agarang atensyon'
          : 'Requires immediate attention';
      }
      
      return message; // Return original if no translation found
    } catch (e) {
      print('🔔 Error translating message: $e');
      return message; // Fallback to original message
    }
  }

  /// Translate sensor offline notification title
  Future<String> _translateSensorOfflineTitle() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locale = prefs.getString('language') ?? 'en';
      
      return locale == 'tl' ? '⚠️ Sensor na Offline' : '⚠️ Sensor Offline';
    } catch (e) {
      print('🔔 Error translating sensor offline title: $e');
      return '⚠️ Sensor Offline';
    }
  }

  /// Translate sensor offline notification message
  Future<String> _translateSensorOfflineMessage(String sensorName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locale = prefs.getString('language') ?? 'en';
      
      if (locale == 'tl') {
        return 'Ang $sensorName sensor ay offline na ng mahigit sa 30 minuto.';
      } else {
        return '$sensorName sensor has been offline for more than 30 minutes.';
      }
    } catch (e) {
      print('🔔 Error translating sensor offline message: $e');
      return '$sensorName sensor has been offline for more than 30 minutes.';
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
