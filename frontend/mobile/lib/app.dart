import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/services/background_notification_service.dart';

import 'core/di/injection_container.dart' as di;
import 'core/presentation/splash/splash_screen.dart';
import 'features/authentication/presentation/screens/landing_screen.dart';
import 'features/farm/presentation/bloc/farm_bloc.dart';
import 'features/farm/presentation/screens/field_registration_screen.dart';
import 'core/presentation/home/home_screen.dart';
import 'features/prescriptions/presentation/screens/detailed_prescription_screen.dart';

import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/bloc/settings_event.dart';
import 'features/settings/presentation/bloc/settings_state.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
import 'generated/l10n.dart';
import 'core/theme/app_theme.dart';
import 'debug_session.dart';
import 'test_secure_storage.dart';

class MaizeWatchApp extends StatefulWidget {
  const MaizeWatchApp({super.key});

  @override
  State<MaizeWatchApp> createState() => _MaizeWatchAppState();
}

class _MaizeWatchAppState extends State<MaizeWatchApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        print("🔄 App: Resumed - restarting background notifications");
        BackgroundNotificationService.initialize();
        break;
      case AppLifecycleState.paused:
        print("🔄 App: Paused - background notifications will continue");
        break;
      case AppLifecycleState.detached:
        print("🔄 App: Detached - stopping background notifications");
        BackgroundNotificationService.stopAllTimers();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
        print("🔧 App: Settings state changed: ${settingsState.runtimeType}");
        if (settingsState is SettingsLoaded) {
          print("🔧 App: Current language: ${settingsState.settings.language}");
        } else if (settingsState is SettingsUpdated) {
          print("🔧 App: Settings updated, current language: ${settingsState.settings.language}");
        } else if (settingsState is SettingsInitial) {
          print("🔧 App: Settings not loaded yet, loading...");
          // Load settings when state is initial
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<SettingsBloc>().add(LoadSettings());
          });
        }
        
        return ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, child) {
            return MaterialApp(
              title: "Maize Watch",
              theme: AppTheme.lightTheme,
              debugShowCheckedModeBanner: false,
              // Internationalization
              locale: () {
                Locale appLocale;
                if (settingsState is SettingsLoaded) {
                  appLocale = settingsState.settings.language == 'tl' ? const Locale('tl', 'PH') : const Locale('en', 'US');
                } else if (settingsState is SettingsUpdated) {
                  appLocale = settingsState.settings.language == 'tl' ? const Locale('tl', 'PH') : const Locale('en', 'US');
                } else {
                  appLocale = const Locale('en', 'US');
                }
                print("🔧 App: Setting locale to: ${appLocale.languageCode}");
                return appLocale;
              }(),
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: S.delegate.supportedLocales,

              initialRoute: '/splash',
              routes: {
                '/splash': (context) => const SplashScreen(),
                '/landing': (context) => const LandingScreen(),
                '/home': (context) => const HomeScreen(),
                '/settings': (context) => const SettingsScreen(),
                '/field-registration':
                    (context) => FarmRegistrationScreen(userData: {}),
                '/detailed-prescription':
                    (context) => const DetailedPrescriptionScreen(),
                '/debug-session': (context) => const DebugSessionScreen(),
                '/test-storage': (context) => const TestSecureStorageScreen(),
              },
              onGenerateRoute: (settings) {
                if (settings.name == '/farm-registration') {
                  final userData = settings.arguments as Map<String, dynamic>;
                  return MaterialPageRoute(
                    builder:
                        (context) => BlocProvider(
                          create: (context) => di.sl<FarmBloc>(),
                          child: FarmRegistrationScreen(
                            userData: userData,
                            fromRegistration: true,
                          ),
                        ),
                  );
                }
                return null;
              },
            );
          },
        );
      },
    );
  }
}