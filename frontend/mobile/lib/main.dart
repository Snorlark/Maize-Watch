import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maize_watch/screen/landing_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;
import 'package:maize_watch/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

import 'screen/home_screen.dart';
import 'screen/splash_screen.dart';
import 'screen/test_notification_screen.dart';

// Initialize the plugin at the global level
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = 
    FlutterLocalNotificationsPlugin();

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
      
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse details) {
      // Handle notification taps here
      print('Notification clicked: ${details.payload}');
    },
  );
  
  // Request permissions
  await _requestPermissions();
  
  // Create and initialize the notification service
  NotificationService().initialize();
  
  FlutterLocalNotificationsPlugin().resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
  alert: true,
  badge: true,
  sound: true,
);

  runApp(const MaizeWatch());
}

Future<void> _requestPermissions() async {
  if (Platform.isIOS || Platform.isMacOS) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  } else if (Platform.isAndroid) {
    // For Android, request the notification permission if running on API level 33 or higher
    if (await Permission.notification.isGranted) {
      return; // Permissions already granted
    }

    if (await Permission.notification.request().isGranted) {
      // Permissions granted
      print("Notification permission granted");
    } else {
      // Handle the case when permission is denied
      print("Notification permission denied");
    }
  }
}

class MaizeWatch extends StatelessWidget {
  const MaizeWatch({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(412, 715),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(textTheme: GoogleFonts.montserratTextTheme()),
          title: 'Maize Watch',
          initialRoute: '/splash',
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/landing': (context) => const LandingScreen(),
            '/home': (context) => const HomeScreen(),
            '/test': (context) => const TestNotificationScreen(),
          },
        );
      }
    );
  }
}
