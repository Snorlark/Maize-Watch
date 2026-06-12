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
                    getErrorMessage(context, message),
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
    final normalized = error.trim();

    // If backend provided a clear message, surface it directly
    final knownServerHints = [
      'invalid credentials',
      'invalid username or password',
      'user not found',
      'username is required',
      'password is required',
      'validation failed',
      'account locked',
      'too many attempts',
      'unauthorized',
      'forbidden',
      'authentication failed',
      'login failed',
      'server error',
      'network error',
      'connection timed out',
      'access forbidden',
      'service not found',
    ];
    final lower = normalized.toLowerCase();
    if (normalized.isNotEmpty &&
        !lower.contains('socketexception') &&
        !lower.contains('timeoutexception') &&
        !lower.contains('unexpected error') &&
        !lower.contains('exception') &&
        knownServerHints.any((h) => lower.contains(h))) {
      return normalized;
    }

    // Network/timeout mapping
    if (lower.contains('socketexception') ||
        lower.contains('connection refused') ||
        lower.contains('no route to host') ||
        lower.contains('failed host lookup') ||
        lower.contains('network is unreachable')) {
      return l10n.error_no_internet;
    }
    if (lower.contains('timeoutexception') || lower.contains('connection timeout')) {
      return l10n.error_timeout;
    }

    // HTTP semantics embedded in message
    if (lower.contains('401') || lower.contains('unauthorized')) {
      return l10n.error_invalid_credentials;
    }
    if (lower.contains('404')) {
      return l10n.error_unknown; // fallback: not found not localized
    }
    if (lower.contains('500') || lower.contains('server error')) {
      return l10n.error_server;
    }

    // Fallback to provided message if it's not a generic placeholder
    if (normalized.isNotEmpty && !lower.contains('unexpected error')) {
      return normalized;
    }

    return l10n.error_unknown;
  }
}
