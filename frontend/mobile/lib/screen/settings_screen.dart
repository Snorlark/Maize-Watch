// settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:maize_watch/custom/custom_font.dart';
import 'package:maize_watch/widget/sensor_status_widget.dart';
import 'package:maize_watch/widget/notification_settings_widget.dart';
import 'package:maize_watch/widget/help_section_widget.dart';
import 'package:maize_watch/widget/faq_section_widget.dart';
import 'package:maize_watch/services/notification_service.dart';

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

    // Run fetch after widget is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchSensorData();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/GRADIENT.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
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
                      const Text(
                        "Settings",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                          fontFamily: 'Montserrat',
                        ),
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

              // Sensor Status Widget
              SensorStatusWidget(
                ldrSensor: ldr,
                phLevelSensor: ph,
                tempAndHumidSensor: dht,
                soilLevelSensor: soil,
              ),

              const SizedBox(height: 20),

              // Notification Settings Widget
              NotificationSettingsWidget(
                isNotificationsEnabled: widget.isNotificationsEnabled,
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

              // Help Section Widget
              HelpSectionWidget(
                isExpanded: widget.isHelpExpanded,
                onToggle: () {
                  setState(() {
                    widget.isHelpExpanded = !widget.isHelpExpanded;
                  });
                },
              ),

              // FAQ Section Widget
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
    );
  }

  Future<void> fetchSensorData() async {
  await Future.delayed(const Duration(seconds: 2));

  setState(() {
    ldr = !ldr; // Toggle for demonstration
    ph = false;
    dht = false;
    soil = false;
  });

  print("Sensor Status Updated: LDR=$ldr");

  if (widget.isNotificationsEnabled) {
    if (previousSensorState['ldr'] != ldr) {
      print("Sending notification...");
      await _notificationService.showNotification(
        title: 'Sensor Status Changed',
        body: 'LDR Sensor is now: ${ldr ? "Active" : "Inactive"}',
        playSound: !widget.isVibrationOnly,
      );
      print("Notification sent.");
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