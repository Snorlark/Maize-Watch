import 'package:flutter/material.dart';
import 'package:maize_watch/custom/custom_font.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NotificationSettingsWidget extends StatelessWidget {
  final bool isNotificationsEnabled;
  final bool isVibrationOnly;
  final Function(bool) onNotificationToggled;
  final Function(bool) onVibrationOnlyToggled;

  const NotificationSettingsWidget({
    Key? key,
    required this.isNotificationsEnabled,
    required this.isVibrationOnly,
    required this.onNotificationToggled,
    required this.onVibrationOnlyToggled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: CustomFont(
              text: local.notifications,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Switch(
                    value: isNotificationsEnabled,
                    onChanged: onNotificationToggled,
                    activeColor: Colors.white,
                    activeTrackColor: const Color(0xFF418036),
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: const Color(0xFFC9C9C9),
                  ),
                  const SizedBox(width: 10),
                  CustomFont(
                    text: local.enableNotifications,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    color: Colors.black,
                  ),
                ],
              ),
            ],
          ),
          if (isNotificationsEnabled)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Switch(
                        value: isVibrationOnly,
                        onChanged: onVibrationOnlyToggled,
                        activeColor: Colors.white,
                        activeTrackColor: const Color(0xFF418036),
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: const Color(0xFFC9C9C9),
                      ),
                      const SizedBox(width: 10),
                      CustomFont(
                        text: local.vibrationOnly,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        isVibrationOnly ? Icons.vibration : Icons.volume_up,
                        color: Colors.black,
                        size: 20,
                      ),
                      const SizedBox(width: 5),
                      CustomFont(
                        text: isVibrationOnly
                            ? local.vibrate
                            : local.soundAndVibrate,
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
