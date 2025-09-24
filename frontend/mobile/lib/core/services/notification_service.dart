import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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

    _isInitialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    debugPrint('Notification tapped: ${response.payload}');
  }

  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
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

    const vibrationOnly = false; // We want sound for sleep mode alerts
    await _showNotification(
      id: SENSOR_SLEEP_MODE_ID,
      title: '🌙 Sensors in Sleep Mode',
      body: 'Your sensors are now sleeping from 8pm to 3am PH time. They will wake up at 3am.',
      payload: 'sensor_sleep_mode',
      vibrationOnly: vibrationOnly,
    );
  }

  Future<void> showPrescriptionAlertNotification({
    required String title,
    required String message,
    String? priority,
  }) async {
    if (!await areNotificationsEnabled()) return;

    final vibrationOnly = await isVibrationOnly();
    final emoji = _getPriorityEmoji(priority);
    
    await _showNotification(
      id: PRESCRIPTION_ALERT_ID,
      title: '$emoji $title',
      body: message,
      payload: 'prescription_alert',
      vibrationOnly: vibrationOnly,
    );
  }

  Future<void> showSensorOfflineNotification(String sensorName) async {
    if (!await areNotificationsEnabled()) return;

    final vibrationOnly = await isVibrationOnly();
    
    await _showNotification(
      id: SENSOR_OFFLINE_ID,
      title: '⚠️ Sensor Offline',
      body: '$sensorName sensor has been offline for more than 30 minutes.',
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
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'maize_watch_channel',
      'Maize Watch Notifications',
      channelDescription: 'Notifications for farm monitoring and alerts',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
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

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
