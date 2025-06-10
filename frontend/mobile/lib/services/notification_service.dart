import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:maize_watch/main.dart'; // Use the global instance from main.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  bool _isNotificationsEnabled = false;
  bool _isVibrationOnly = false;

  Future<void> initialize() async {
    // Load notification settings
    await _loadNotificationSettings();
    
    // Create notification channels for different types of notifications
    await _createNotificationChannels();
  }

  Future<void> _loadNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isNotificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
      _isVibrationOnly = prefs.getBool('vibration_only') ?? false;
    } catch (e) {
      print('Error loading notification settings: $e');
    }
  }

  Future<void> updateNotificationSettings({required bool enabled, required bool vibrationOnly}) async {
    _isNotificationsEnabled = enabled;
    _isVibrationOnly = vibrationOnly;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', enabled);
      await prefs.setBool('vibration_only', vibrationOnly);
    } catch (e) {
      print('Error saving notification settings: $e');
    }
  }

  Future<void> _createNotificationChannels() async {
    // Sensor notifications channel
    const AndroidNotificationChannel sensorChannel = AndroidNotificationChannel(
      'sensor_channel',
      'Sensor Notifications',
      description: 'Notifications for sensor status changes',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // Prescription notifications channel
    const AndroidNotificationChannel prescriptionChannel = AndroidNotificationChannel(
      'prescription_channel',
      'Prescription Notifications',
      description: 'Notifications for new crop prescriptions and recommendations',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // Create channels
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(sensorChannel);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(prescriptionChannel);
  }

  Future<void> showNotification({
    required String title,
    required String body,
    bool playSound = true,
    String? payload,
    String channelId = 'sensor_channel',
  }) async {
    if (!_isNotificationsEnabled) return;

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channelId,
      channelId == 'prescription_channel' ? 'Prescription Notifications' : 'Sensor Notifications',
      channelDescription: channelId == 'prescription_channel' 
          ? 'Notifications for new crop prescriptions and recommendations'
          : 'Notifications for sensor status changes',
      importance: Importance.high,
      priority: Priority.high,
      playSound: playSound && !_isVibrationOnly,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      color: channelId == 'prescription_channel' ? const Color(0xFF72AB50) : const Color(0xFF2196F3),
    );

    DarwinNotificationDetails iosNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: playSound && !_isVibrationOnly,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Show prescription notification
  Future<void> showPrescriptionNotification({
    required String title,
    required String body,
    String? prescriptionId,
  }) async {
    if (!_isNotificationsEnabled) return;
    
    await showNotification(
      title: title,
      body: body,
      playSound: true,
      payload: prescriptionId,
      channelId: 'prescription_channel',
    );
  }

  // Show sensor status notification
  Future<void> showSensorStatusNotification({
    required String sensorName,
    required bool isActive,
  }) async {
    if (!_isNotificationsEnabled) return;

    final title = isActive ? 'Sensor Active' : 'Sensor Inactive';
    final body = isActive 
        ? '$sensorName is now active and monitoring'
        : '$sensorName is now inactive';

    await showNotification(
      title: title,
      body: body,
      playSound: true,
      channelId: 'sensor_channel',
    );
  }

  // Show multiple sensors status notification
  Future<void> showMultipleSensorsStatusNotification({
    required List<String> inactiveSensors,
    required List<String> activeSensors,
  }) async {
    if (!_isNotificationsEnabled) return;

    String title = 'Sensor Status Update';
    String body = '';

    if (inactiveSensors.isNotEmpty) {
      body += 'Inactive: ${inactiveSensors.join(', ')}. ';
    }
    if (activeSensors.isNotEmpty) {
      body += 'Active: ${activeSensors.join(', ')}.';
    }

    if (body.isEmpty) {
      body = 'All sensors are in normal operation mode';
    }

    await showNotification(
      title: title,
      body: body,
      playSound: true,
      channelId: 'sensor_channel',
    );
  }
}
