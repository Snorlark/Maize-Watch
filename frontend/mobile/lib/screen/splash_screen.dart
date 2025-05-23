import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maize_watch/custom/constants.dart';
import 'package:maize_watch/custom/custom_font.dart';
import 'dart:async';
import 'landing_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();

    // Clockwise animation
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Timer to navigate to LandingScreen
    Timer(const Duration(milliseconds: 4500), () {
      _rotationController.stop();
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LandingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MAIZE_BOTTOM_OVERLAY,
      body: Stack(
        children: [
          // Centered rotating logo stack
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/images/Frame-Logo.png',
                      width: 200.w,
                      height: 200.h,
                    ),
                    RotationTransition(
                      turns: _rotationController,
                      child: Image.asset(
                        'assets/images/Corn-Logo.png',
                        width: 80.w,
                        height: 80.h,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bottom "from" and NOVU logo
          Positioned(
            bottom: 40.h, // Adjust bottom padding if needed
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomFont(
                  text: 'from',
                  fontSize: 14.sp,
                  color: MAIZE_ACCENT,
                  fontWeight: FontWeight.w500,
                ),
                Image.asset(
                  'assets/images/NOVU-LOGO.png',
                  width: 80.w,
                  height: 30.h,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
