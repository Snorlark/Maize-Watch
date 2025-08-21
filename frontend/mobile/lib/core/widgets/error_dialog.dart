import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../constants/app_spacing.dart';
import '../../generated/l10n.dart';

class ErrorDialog {
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
  }) {
    final l10n = S.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 28),
              SizedBox(width: kAppSmallPadding),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: kAppSmallPadding),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: MAIZE_ACCENT,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: MAIZE_PRIMARY,
                padding: EdgeInsets.symmetric(
                  horizontal: kAppMediumPadding,
                  vertical: kAppSmallPadding,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                buttonText ?? l10n.ok,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          actionsPadding: EdgeInsets.all(kAppMediumPadding),
        );
      },
    );
  }

  static String getErrorMessage(BuildContext context, String error) {
    final l10n = S.of(context);

    if (error.contains('SocketException') ||
        error.contains('Connection refused')) {
      return l10n.error_no_internet;
    } else if (error.contains('TimeoutException')) {
      return l10n.error_timeout;
    } else if (error.contains('Invalid credentials')) {
      return l10n.error_invalid_credentials;
    } else if (error.contains('Server error')) {
      return l10n.error_server;
    }
    return l10n.error_unknown;
  }
}
