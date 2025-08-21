import 'package:flutter/material.dart';
import 'dart:async';

import '../../../features/authentication/presentation/screens/landing_screen.dart';
import '../../theme/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    Timer(const Duration(milliseconds: 4500), () {
      _rotationController.stop();
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder:
              (context, animation, secondaryAnimation) => const LandingScreen(),
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
    final textTheme = Theme.of(context).textTheme;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: MAIZE_PRIMARY_LIGHT,
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
                    // Outer logo (Frame-Logo)
                    FractionallySizedBox(
                      widthFactor: 0.5, // 50% of screen width
                      child: Image.asset(
                        'assets/images/frame-logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    // Inner rotating logo (Corn-Logo)
                    RotationTransition(
                      turns: _rotationController,
                      child: FractionallySizedBox(
                        widthFactor: 0.2, // 20% of screen width
                        child: Image.asset(
                          'assets/images/corn-logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Positioned(
            bottom: screenSize.height * 0.05,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'from',
                  style: textTheme.bodyMedium?.copyWith(
                    color: MAIZE_ACCENT,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                FractionallySizedBox(
                  widthFactor: 0.2,
                  child: Image.asset(
                    'assets/images/novu-logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
