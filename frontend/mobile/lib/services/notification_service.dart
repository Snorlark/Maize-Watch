import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:maize_watch/main.dart'; // Use the global instance from main.dart
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  Future<void> initialize() async {
    // Create notification channels for different types of notifications
    await _createNotificationChannels();
  }

  Future<void> _createNotificationChannels() async {
    // Sensor notifications channel
    const AndroidNotificationChannel sensorChannel = AndroidNotificationChannel(
      'sensor_channel',
      'Sensor Notifications',
      description: 'Notifications for sensor status changes and sleep mode',
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
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channelId,
      channelId == 'prescription_channel' ? 'Prescription Notifications' : 'Sensor Notifications',
      channelDescription: channelId == 'prescription_channel' 
          ? 'Notifications for new crop prescriptions and recommendations'
          : 'Notifications for sensor status changes and sleep mode',
      importance: Importance.high,
      priority: Priority.high,
      playSound: playSound,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      color: channelId == 'prescription_channel' ? const Color(0xFF72AB50) : const Color(0xFF2196F3),
    );

    DarwinNotificationDetails iosNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: playSound,
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
    await showNotification(
      title: title,
      body: body,
      playSound: true,
      payload: prescriptionId,
      channelId: 'prescription_channel',
    );
  }

  // Show sensor sleep mode notification
  Future<void> showSleepModeNotification({
    required String sensorName,
    required bool isSleeping,
  }) async {
    final title = isSleeping ? 'Sensor Sleep Mode' : 'Sensor Awake';
    final body = isSleeping 
        ? '$sensorName is now in sleep mode to conserve power'
        : '$sensorName is now active and monitoring';

    await showNotification(
      title: title,
      body: body,
      playSound: true,
      channelId: 'sensor_channel',
    );
  }

  // Show multiple sensors sleep mode notification
  Future<void> showMultipleSensorsSleepModeNotification({
    required List<String> sleepingSensors,
    required List<String> activeSensors,
  }) async {
    String title = 'Sensor Status Update';
    String body = '';

    if (sleepingSensors.isNotEmpty) {
      body += 'Sleeping: ${sleepingSensors.join(', ')}. ';
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
