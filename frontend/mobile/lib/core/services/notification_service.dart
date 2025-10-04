import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:mobile/generated/l10n.dart';
import '../storage/secure_storage.dart';

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
  static const int BACKGROUND_PRESCRIPTION_ID = 2000;
  
  // Cache keys (will be made user-specific)
  static const String _CACHED_NOTIFICATIONS_KEY = 'cached_notifications';
  static const String _NOTIFICATION_COUNTER_KEY = 'notification_counter';
  
  // Get user-specific cache keys
  Future<String> _getCachedNotificationsKey() async {
    final userId = await _getCurrentUserId();
    return userId != null ? '${_CACHED_NOTIFICATIONS_KEY}_$userId' : _CACHED_NOTIFICATIONS_KEY;
  }
  
  Future<String> _getNotificationCounterKey() async {
    final userId = await _getCurrentUserId();
    return userId != null ? '${_NOTIFICATION_COUNTER_KEY}_$userId' : _NOTIFICATION_COUNTER_KEY;
  }
  
  // Get current user ID from secure storage
  Future<String?> _getCurrentUserId() async {
    try {
      final userData = await SecureStorage.getUserData();
      if (userData != null) {
        final user = jsonDecode(userData);
        return user['id']?.toString();
      }
      return null;
    } catch (e) {
      print('🔔 Error getting current user ID: $e');
      return null;
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    print('🔔 Initializing notification service...');

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

    try {
      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      print('🔔 Notification service initialized successfully');

      // Create notification channel for Android
      if (defaultTargetPlatform == TargetPlatform.android) {
        await _createNotificationChannel();
      }

      // Request notification permissions
      final permissionsGranted = await requestPermissions();
      print('🔔 Notification permissions granted: $permissionsGranted');

      _isInitialized = true;
    } catch (e) {
      print('🚨 Error initializing notification service: $e');
    }
  }

  Future<void> _createNotificationChannel() async {
    try {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            'maize_watch_channel',
            'Maize Watch Notifications',
            description: 'Notifications for farm monitoring and prescriptions',
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
          ),
        );
        print('🔔 Notification channel created successfully');
      }
    } catch (e) {
      print('🚨 Error creating notification channel: $e');
    }
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
    print('🔔 Attempting to show notification: $title');
    
    if (!_isInitialized) {
      print('🚨 Notification service not initialized, initializing now...');
      await initialize();
      if (!_isInitialized) {
        print('🚨 Failed to initialize notification service');
        return;
      }
    }

    // Check if notification permissions are granted
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final permissionsGranted = await androidPlugin?.areNotificationsEnabled() ?? false;
    print('🔔 Notification permissions status: $permissionsGranted');
    
    if (!permissionsGranted) {
      print('🚨 Notification permissions not granted, requesting permissions...');
      final requested = await requestPermissions();
      if (!requested) {
        print('🚨 Failed to get notification permissions');
        return;
      }
    }

    try {
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'maize_watch_channel',
        'Maize Watch Notifications',
        channelDescription: 'Notifications for farm monitoring and prescriptions',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: !vibrationOnly,
        playSound: !vibrationOnly,
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

      print('✅ Notification sent successfully: $title');
    } catch (e) {
      print('🚨 Error showing notification: $e');
    }
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
      // Get current locale from SharedPreferences - use the same key as settings
      final prefs = await SharedPreferences.getInstance();
      final locale = prefs.getString('selected_language_code') ?? 'en';
      
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
      // Get current locale from SharedPreferences - use the same key as settings
      final prefs = await SharedPreferences.getInstance();
      final locale = prefs.getString('selected_language_code') ?? 'en';
      
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
      
      // Don't translate the actual prescription details - they should be specific to each prescription
      // Just return the original message as it should already be translated by PrescriptionTranslationService
      return message;
    } catch (e) {
      print('🔔 Error translating message: $e');
      return message; // Fallback to original message
    }
  }

  /// Translate sensor offline notification title
  Future<String> _translateSensorOfflineTitle() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locale = prefs.getString('selected_language_code') ?? 'en';
      
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
      final locale = prefs.getString('selected_language_code') ?? 'en';
      
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

  /// Cache notification for background delivery
  Future<void> cacheNotification({
    required String title,
    required String message,
    String? priority,
    String? prescriptionId,
    String? fieldName,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedNotifications = await getCachedNotifications();
      
      // Get user-specific cache keys
      final notificationsKey = await _getCachedNotificationsKey();
      final counterKey = await _getNotificationCounterKey();
      
      // Get next notification ID
      final counter = prefs.getInt(counterKey) ?? 0;
      final notificationId = BACKGROUND_PRESCRIPTION_ID + counter;
      
      final notification = {
        'id': notificationId,
        'title': title,
        'message': message,
        'priority': priority ?? 'medium',
        'prescriptionId': prescriptionId,
        'fieldName': fieldName,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'delivered': false,
      };
      
      cachedNotifications.add(notification);
      
      // Store updated cache with user-specific keys
      await prefs.setString(notificationsKey, jsonEncode(cachedNotifications));
      await prefs.setInt(counterKey, counter + 1);
      
      print('🔔 Cached notification for user: $title');
    } catch (e) {
      print('🚨 Error caching notification: $e');
    }
  }

  /// Get cached notifications
  Future<List<Map<String, dynamic>>> getCachedNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsKey = await _getCachedNotificationsKey();
      final cachedData = prefs.getString(notificationsKey);
      
      if (cachedData == null) return [];
      
      final List<dynamic> decoded = jsonDecode(cachedData);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      print('🚨 Error getting cached notifications: $e');
      return [];
    }
  }

  /// Deliver cached notifications
  Future<void> deliverCachedNotifications() async {
    try {
      final cachedNotifications = await getCachedNotifications();
      final undeliveredNotifications = cachedNotifications.where((n) => n['delivered'] == false).toList();
      
      if (undeliveredNotifications.isEmpty) return;
      
      print('🔔 Delivering ${undeliveredNotifications.length} cached notifications');
      
      for (final notification in undeliveredNotifications) {
        await showPrescriptionAlertNotification(
          title: notification['title'],
          message: notification['message'],
          priority: notification['priority'],
          notificationId: notification['id'],
        );
        
        // Mark as delivered
        notification['delivered'] = true;
      }
      
      // Update cache with user-specific key
      final prefs = await SharedPreferences.getInstance();
      final notificationsKey = await _getCachedNotificationsKey();
      await prefs.setString(notificationsKey, jsonEncode(cachedNotifications));
      
    } catch (e) {
      print('🚨 Error delivering cached notifications: $e');
    }
  }

  /// Clear delivered notifications from cache
  Future<void> clearDeliveredNotifications() async {
    try {
      final cachedNotifications = await getCachedNotifications();
      final activeNotifications = cachedNotifications.where((n) => n['delivered'] == false).toList();
      
      final prefs = await SharedPreferences.getInstance();
      final notificationsKey = await _getCachedNotificationsKey();
      await prefs.setString(notificationsKey, jsonEncode(activeNotifications));
      
    } catch (e) {
      print('🚨 Error clearing delivered notifications: $e');
    }
  }

  /// Clear all notifications for current user (used during logout)
  Future<void> clearAllUserNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsKey = await _getCachedNotificationsKey();
      final counterKey = await _getNotificationCounterKey();
      
      // Clear all notifications and reset counter for this user
      await prefs.remove(notificationsKey);
      await prefs.remove(counterKey);
      
      print('🔔 Cleared all notifications for current user');
    } catch (e) {
      print('🚨 Error clearing user notifications: $e');
    }
  }

  /// Schedule background notification check
  Future<void> scheduleBackgroundCheck() async {
    try {
      // Schedule a notification to check for new prescriptions
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'maize_watch_background',
        'Background Check',
        channelDescription: 'Background prescription check',
        importance: Importance.low,
        priority: Priority.low,
        showWhen: false,
        enableVibration: false,
        playSound: false,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: false,
        presentBadge: false,
        presentSound: false,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Schedule notification for 5 minutes from now
      final scheduledDate = DateTime.now().add(const Duration(minutes: 5));
      
      await _notifications.zonedSchedule(
        9999, // Background check ID
        'Background Check',
        'Checking for new prescriptions...',
        tz.TZDateTime.from(scheduledDate, tz.getLocation('UTC')),
        details,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      
    } catch (e) {
      print('🚨 Error scheduling background check: $e');
    }
  }

  /// Enhanced prescription notification with caching
  Future<void> showPrescriptionAlertNotificationWithCaching({
    required String title,
    required String message,
    String? priority,
    String? prescriptionId,
    String? fieldName,
    bool cacheForBackground = true,
  }) async {
    print('🔔 showPrescriptionAlertNotificationWithCaching called');
    print('🔔 Title: $title, Message: $message, Priority: $priority');
    
    // Show immediate notification
    print('🔔 Calling showPrescriptionAlertNotification...');
    final notificationId = prescriptionId != null ? int.tryParse(prescriptionId) : null;
    print('🔔 Parsed notification ID: $notificationId (from prescriptionId: $prescriptionId)');
    
    await showPrescriptionAlertNotification(
      title: title,
      message: message,
      priority: priority,
      notificationId: notificationId,
    );
    print('🔔 showPrescriptionAlertNotification completed');
    
    // Cache for background delivery if enabled
    if (cacheForBackground) {
      print('🔔 Caching notification for background delivery...');
      await cacheNotification(
        title: title,
        message: message,
        priority: priority,
        prescriptionId: prescriptionId,
        fieldName: fieldName,
      );
      print('🔔 Notification cached successfully');
    }
    
    print('🔔 showPrescriptionAlertNotificationWithCaching completed');
  }
}
