import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';

import 'landing_screen.dart'; // For timer


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Wait for 3.5 seconds (assuming GIF is 3.5 sec long) before navigating
    Timer(const Duration(seconds: 4, milliseconds: 500), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LandingScreen()), // Replace with actual landing screen
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/GRADIENT.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: Image.asset(
              'assets/gif/maize_watch_splash.gif',
              fit: BoxFit.cover,
              width: 400.w,
              height: 400.h,
            ),
          )
        ],
      ),
    );
  }
}
