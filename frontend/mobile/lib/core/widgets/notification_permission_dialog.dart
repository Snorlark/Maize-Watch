import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationPermissionDialog extends StatelessWidget {
  const NotificationPermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.notifications, color: Colors.orange),
          SizedBox(width: 8),
          Text('Enable Notifications'),
        ],
      ),
      content: const Text(
        'Maize Watch would like to send you notifications about:\n\n'
        '• New farm prescriptions\n'
        '• Sensor alerts\n'
        '• Important updates\n\n'
        'This helps you stay informed about your farm\'s health.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Not Now'),
        ),
        ElevatedButton(
          onPressed: () async {
            final notificationService = NotificationService();
            final granted = await notificationService.requestPermissions();
            if (context.mounted) {
              Navigator.of(context).pop(granted);
              if (granted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notifications enabled! You\'ll receive farm updates.'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notifications disabled. You can enable them in settings.'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            }
          },
          child: const Text('Enable'),
        ),
      ],
    );
  }

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const NotificationPermissionDialog(),
    );
  }
}
