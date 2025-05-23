import 'package:flutter/material.dart';
import 'package:maize_watch/custom/constants.dart';
import 'package:maize_watch/custom/custom_font.dart';
import 'package:maize_watch/widget/language_toggle.dart';
import 'package:maize_watch/widget/sensor_status_widget.dart';
import 'package:maize_watch/widget/notification_settings_widget.dart';
import 'package:maize_watch/widget/help_section_widget.dart';
import 'package:maize_watch/widget/faq_section_widget.dart';
import 'package:maize_watch/services/notification_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ignore: must_be_immutable
class SettingsScreen extends StatefulWidget {
  bool isNotificationsEnabled;
  bool isHelpExpanded;
  bool isFAQsExpanded;
  bool isVibrationOnly;

  SettingsScreen({
    super.key,
    this.isNotificationsEnabled = false,
    this.isHelpExpanded = false,
    this.isFAQsExpanded = false,
    this.isVibrationOnly = false,
  });

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool ldr = false;
  bool ph = false;
  bool dht = false;
  bool soil = false;

  final NotificationService _notificationService = NotificationService();

  Map<String, bool> previousSensorState = {
    'ldr': false,
    'ph': false,
    'dht': false,
    'soil': false,
  };

  @override
  void initState() {
    super.initState();
    _notificationService.initialize();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchSensorData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: MAIZE_BOTTOM_OVERLAY,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Icon(
                              Icons.arrow_back,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                          const SizedBox(width: 8),
                          CustomFont(
                            text: local.settings,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: MAIZE_ACCENT,
                          ),
                        ],
                      ),
                      Image.asset(
                        'assets/images/maize_watch_logo.png',
                        height: 50,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SensorStatusWidget(
                            ldrSensor: ldr,
                            phLevelSensor: ph,
                            tempAndHumidSensor: dht,
                            soilLevelSensor: soil,
                            localization: local,
                          ),
                          const SizedBox(height: 20),
                          NotificationSettingsWidget(
                            isNotificationsEnabled:
                                widget.isNotificationsEnabled,
                            isVibrationOnly: widget.isVibrationOnly,
                            onNotificationToggled: (value) {
                              setState(() {
                                widget.isNotificationsEnabled = value;
                              });
                            },
                            onVibrationOnlyToggled: (value) {
                              setState(() {
                                widget.isVibrationOnly = value;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          Container(
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
                                    text: local.language,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      LanguageToggleLocale(
                                        color_toggle: MAIZE_ACCENT,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          HelpSectionWidget(
                            isExpanded: widget.isHelpExpanded,
                            onToggle: () {
                              setState(() {
                                widget.isHelpExpanded = !widget.isHelpExpanded;
                              });
                            },
                          ),
                          FAQSectionWidget(
                            isExpanded: widget.isFAQsExpanded,
                            onToggle: () {
                              setState(() {
                                widget.isFAQsExpanded = !widget.isFAQsExpanded;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> fetchSensorData() async {
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        ldr = !ldr; // Toggle for demo
        ph = false;
        dht = false;
        soil = false;
      });

      if (widget.isNotificationsEnabled) {
        if (previousSensorState['ldr'] != ldr) {
          await _notificationService.showNotification(
            title: 'Sensor Status Changed',
            body: 'LDR Sensor is now: ${ldr ? "Active" : "Inactive"}',
            playSound: !widget.isVibrationOnly,
          );
        }
      }

      previousSensorState = {
        'ldr': ldr,
        'ph': ph,
        'dht': dht,
        'soil': soil,
      };

      Future.delayed(const Duration(seconds: 5), fetchSensorData);
    }
  }
}
