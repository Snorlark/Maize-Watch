import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/authentication/presentation/screens/landing_screen.dart';
import '../../../features/live_monitoring/presentation/screen/home_screen.dart';
import '../../../features/authentication/presentation/bloc/authentication_bloc.dart';
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

    Timer(const Duration(milliseconds: 4500), () async {
      _rotationController.stop();

      // Trigger authentication check through BLoC
      context.read<AuthenticationBloc>().add(CheckAuthStatusEvent());
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

    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state.status == AuthenticationStatus.authenticated) {
          // Navigate to home screen if authenticated
          print("🔍 Splash: User authenticated, navigating to home");
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 800),
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      const HomeScreen(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        } else if (state.status == AuthenticationStatus.unauthenticated) {
          // Navigate to landing screen if not authenticated
          print("🔍 Splash: User not authenticated, navigating to landing");
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 800),
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      const LandingScreen(),
              transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
              ) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        }
      },
      child: Scaffold(
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
      ),
    );
  }
}
