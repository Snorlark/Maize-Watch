import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:maize_watch/custom/constants.dart';
import 'package:maize_watch/custom/custom_font.dart';
import 'package:maize_watch/widget/language_toggle.dart';
import 'package:maize_watch/widget/sensor_status_widget.dart';
import 'package:maize_watch/widget/notification_settings_widget.dart';
import 'package:maize_watch/widget/help_section_widget.dart';
import 'package:maize_watch/widget/faq_section_widget.dart';
import 'package:maize_watch/services/notification_service.dart';
import 'package:maize_watch/services/sensor_sleep_service.dart';
import 'package:maize_watch/services/prescription_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  final SensorSleepService _sensorService = SensorSleepService();
  final PrescriptionService _prescriptionService = PrescriptionService();
  
  bool _notificationsEnabled = false;
  bool _vibrationOnly = false;
  bool _isLoading = true;
  Map<String, bool> _sensorStatus = {};
  List<Map<String, dynamic>> _prescriptions = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _fetchSensorData();
    _checkNewPrescriptions();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
        _vibrationOnly = prefs.getBool('vibration_only') ?? false;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading settings: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateNotificationSettings(bool enabled, bool vibrationOnly) async {
    setState(() {
      _notificationsEnabled = enabled;
      _vibrationOnly = vibrationOnly;
    });

    await _notificationService.updateNotificationSettings(
      enabled: enabled,
      vibrationOnly: vibrationOnly,
    );
  }

  Future<void> _fetchSensorData() async {
    try {
      final sensorData = await _sensorService.checkSensorStatus();
      setState(() {
        _sensorStatus = sensorData;
      });
    } catch (e) {
      print('Error fetching sensor data: $e');
    }
  }

  Future<void> _checkNewPrescriptions() async {
    try {
      final prescriptions = await _prescriptionService.getPrescriptions();
      setState(() {
        _prescriptions = prescriptions;
      });
    } catch (e) {
      print('Error fetching prescriptions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
                            text: AppLocalizations.of(context)!.settings,
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
                            ldrSensor: _sensorStatus['ldr'] ?? false,
                            phLevelSensor: _sensorStatus['ph'] ?? false,
                            tempAndHumidSensor: _sensorStatus['dht'] ?? false,
                            soilLevelSensor: _sensorStatus['soil'] ?? false,
                            localization: AppLocalizations.of(context)!,
                          ),
                          const SizedBox(height: 20),
                          NotificationSettingsWidget(
                            isNotificationsEnabled: _notificationsEnabled,
                            isVibrationOnly: _vibrationOnly,
                            onNotificationToggled: (value) {
                              _updateNotificationSettings(value, _vibrationOnly);
                            },
                            onVibrationOnlyToggled: (value) {
                              _updateNotificationSettings(_notificationsEnabled, value);
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
                                    text: AppLocalizations.of(context)!.language,
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
                            isExpanded: false,
                            onToggle: () {
                              // Implementation needed
                            },
                          ),
                          FAQSectionWidget(
                            isExpanded: false,
                            onToggle: () {
                              // Implementation needed
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
}
