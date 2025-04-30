import 'package:flutter/material.dart';
import 'package:maize_watch/custom/custom_font.dart';
import 'package:maize_watch/services/translation_service.dart';

class NotificationSettingsWidget extends StatelessWidget {
  final bool isNotificationsEnabled;
  final bool isVibrationOnly;
  final Function(bool) onNotificationToggled;
  final Function(bool) onVibrationOnlyToggled;

  final TranslationService translationService;

  const NotificationSettingsWidget({
    Key? key,
    required this.isNotificationsEnabled,
    required this.isVibrationOnly,
    required this.onNotificationToggled,
    required this.onVibrationOnlyToggled, 
    required this.translationService,
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
          Padding(
            padding: EdgeInsets.only(left: 10.0),
            child: Text(
              translationService.translate('notifications'),
              style: const TextStyle(
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
                    text: translationService.translate('enable notifications'),
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
                        text:  translationService.translate('vibration only'),
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
                        text: isVibrationOnly ?  translationService.translate('vibrate') :  translationService.translate('sound & vibrate'),
                        fontSize: 12,
                        color: Colors.black
                      )
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