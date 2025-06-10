import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maize_watch/screen/corn_registration_screen.dart';
import 'package:maize_watch/screen/landing_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;
import 'package:maize_watch/services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:maize_watch/l10n/l10n.dart';

import 'screen/home_screen.dart';
import 'screen/splash_screen.dart';

// Allow disabling swipe-back gesture for specific routes
class NoSwipePageRoute<T> extends MaterialPageRoute<T> {
  NoSwipePageRoute({required WidgetBuilder builder}) : super(builder: builder);

  @override
  bool get popGestureEnabled => false;
}

// Notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Dynamic locale support
final ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('en'));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure system UI to handle safe areas properly
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );

  // Set system UI overlay style for better appearance
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  try {
    // Load .env file from project root (two levels up from lib folder)
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Warning: Could not load .env file: $e');
    // Continue without .env file - you can set default values or handle this case
  }

  // Optional: Force English on first run
  final prefs = await SharedPreferences.getInstance();
  bool isFirstRun = prefs.getBool('first_run') ?? true;

  if (isFirstRun) {
    localeNotifier.value = const Locale('en');
    await prefs.setBool('first_run', false);
  }

  // Notifications setup
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
      print('Notification clicked: ${details.payload}');
    },
  );

  await _requestPermissions();
  NotificationService().initialize();

  FlutterLocalNotificationsPlugin()
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(alert: true, badge: true, sound: true);

  runApp(const MaizeWatch());
}

Future<void> _requestPermissions() async {
  if (Platform.isIOS || Platform.isMacOS) {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  } else if (Platform.isAndroid) {
    if (await Permission.notification.isGranted) return;

    if (await Permission.notification.request().isGranted) {
      print("Notification permission granted");
    } else {
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
        return ValueListenableBuilder<Locale>(
          valueListenable: localeNotifier,
          builder: (context, locale, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                textTheme: GoogleFonts.montserratTextTheme(),
                appBarTheme: const AppBarTheme(
                  systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    systemNavigationBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.dark,
                    systemNavigationBarIconBrightness: Brightness.dark,
                  ),
                ),
              ),
              supportedLocales: L10n.all,
              locale: locale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate
              ],
              title: 'Maize Watch',
              initialRoute: '/splash',
              routes: {
                '/splash': (context) => const SplashScreen(),
                '/landing': (context) => const LandingScreen(),
                '/home': (context) => const HomeScreen()
              },
            );
          },
        );
      },
    );
  }
}
