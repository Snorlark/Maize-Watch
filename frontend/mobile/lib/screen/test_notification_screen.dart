// lib/screen/test_notification_screen.dart
import 'package:flutter/material.dart';
import 'package:maize_watch/services/notification_service.dart';

class TestNotificationScreen extends StatelessWidget {
  const TestNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationService _notificationService = NotificationService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Notification'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await _notificationService.showNotification(
              title: 'Test Notification',
              body: 'This is a test notification sent manually!',
              playSound: true,
            );
            print("Test notification triggered.");
          },
          child: const Text('Send Test Notification'),
        ),
      ),
    );
  }
}
