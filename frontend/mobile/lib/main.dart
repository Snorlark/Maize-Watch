import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maize_watch/screen/landing_screen.dart';

import 'screen/home_screen.dart';
import 'screen/splash_screen.dart';

void main() {
  runApp(const MaizeWatch());
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
          },
        );
      }
    );
  }
}
