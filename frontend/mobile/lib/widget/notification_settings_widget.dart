import 'package:flutter/material.dart';
import 'package:maize_watch/custom/custom_font.dart';

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
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: Text(
              "Notifications",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
              ),
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
                    text: "Enable Notifications",
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
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
                        text: "Vibration Only",
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
                        color: const Color(0xFF418036),
                        size: 20,
                      ),
                      const SizedBox(width: 5),
                      CustomFont(
                        text: isVibrationOnly ? "Vibrate" : "Sound & Vibrate",
                        fontSize: 12,
                        color: const Color(0xFF418036),
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