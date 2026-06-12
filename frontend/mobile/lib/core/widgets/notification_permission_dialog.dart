import 'package:flutter/material.dart';
import '../../generated/l10n.dart';
import '../services/notification_service.dart';

class NotificationPermissionDialog extends StatelessWidget {
  const NotificationPermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.notifications, color: Colors.orange),
          SizedBox(width: 8),
          Text(S.of(context).enable_notifications),
        ],
      ),
      content: Text(S.of(context).notification_permission_message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(S.of(context).not_now),
        ),
        ElevatedButton(
          onPressed: () async {
            final notificationService = NotificationService();
            final granted = await notificationService.requestPermissions();
            if (context.mounted) {
              Navigator.of(context).pop(granted);
              if (granted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(S.of(context).notifications_enabled_message),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(S.of(context).notifications_disabled_message),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            }
          },
          child: Text(S.of(context).enable),
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
