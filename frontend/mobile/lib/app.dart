import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/di/injection_container.dart' as di;
import 'core/presentation/splash/splash_screen.dart';
import 'features/authentication/presentation/screens/landing_screen.dart';
import 'features/farm/presentation/bloc/farm_bloc.dart';
import 'features/farm/presentation/screens/corn_registration_screen.dart';
import 'features/live_monitoring/presentation/screen/home_screen.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
import 'generated/l10n.dart';
import 'core/theme/app_theme.dart';

class MaizeWatchApp extends StatelessWidget {
  const MaizeWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settingsState) {
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
              locale: settingsState.locale,
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
              },
              onGenerateRoute: (settings) {
                if (settings.name == '/farm-registration') {
                  final userData = settings.arguments as Map<String, dynamic>;
                  return MaterialPageRoute(
                    builder:
                        (context) => BlocProvider(
                          create: (context) => di.sl<FarmBloc>(),
                          child: FarmRegistrationScreen(userData: userData),
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
