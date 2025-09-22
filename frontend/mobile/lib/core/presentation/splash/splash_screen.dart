import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/presentation/home/home_screen.dart';

import '../../../features/authentication/presentation/screens/landing_screen.dart';
import '../../../features/authentication/presentation/bloc/authentication_bloc.dart';
import '../../../features/farm/presentation/bloc/farm_bloc.dart';
import '../../../features/farm/presentation/screens/field_registration_screen.dart';
import '../../theme/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  bool _requestedFarms = false;
  String _statusMessage = 'Initializing...';
  Timer? _timeoutTimer;
  Timer? _farmLoadingTimer;
  bool _isLoadingFarms = false;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    Timer(const Duration(milliseconds: 4500), () async {
      _rotationController.stop();
      setState(() {
        _statusMessage = 'Checking authentication...';
      });

      // Initialize session first, then check authentication
      context.read<AuthenticationBloc>().add(InitializeSessionEvent());
      context.read<AuthenticationBloc>().add(CheckAuthStatusEvent());
    });

    // Add timeout timer to prevent infinite loading
    _timeoutTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        _showErrorAndNavigate(
          'Connection timeout. Please check your internet connection.',
        );
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _timeoutTimer?.cancel();
    _farmLoadingTimer?.cancel();
    super.dispose();
  }

  void _showErrorAndNavigate(String message) {
    _timeoutTimer?.cancel();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );

    // Navigate to landing screen after showing error
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _navigateTo(const LandingScreen());
      }
    });
  }

  void _navigateTo(Widget page) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Map<String, dynamic>? _buildUserData() {
    final user = context.read<AuthenticationBloc>().state.user;
    if (user == null) return null;
    return {
      'id': user.id,
      'username': user.username,
      'fullName': user.fullName,
      'contactNumber': user.contactNumber,
      'address': user.address,
      'role': user.role,
    };
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenSize = MediaQuery.of(context).size;

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state.status == AuthenticationStatus.authenticated) {
              // After authentication, request user's farms before deciding where to go
              if (!_requestedFarms && state.user != null) {
                _requestedFarms = true;
                final userId = state.user!.id;
                setState(() {
                  _statusMessage = 'Loading your farm...';
                  _isLoadingFarms = true;
                });

                // Restart rotation animation for loading farms
                _rotationController.repeat();

                print(
                  "🌽 Splash: Authenticated. Fetching farms for user $userId",
                );

                // Set a 10-second timeout specifically for farm loading
                _farmLoadingTimer = Timer(const Duration(seconds: 10), () {
                  if (mounted && _isLoadingFarms) {
                    print(
                      "🚨 Splash: Farm loading timeout - network issue",
                    );
                    _isLoadingFarms = false;
                    _showErrorAndNavigate('Connection timeout. Please check your internet connection and try again.');
                  }
                });

                try {
                  context.read<FarmBloc>().add(
                    GetUserFarmsEvent(userId: userId),
                  );
                } catch (e) {
                  print("🚨 Splash: Error accessing FarmBloc: $e");
                  _isLoadingFarms = false;
                  _farmLoadingTimer?.cancel();
                  final userData = _buildUserData();
                  _navigateTo(
                    FarmRegistrationScreen(
                      userData: userData ?? {},
                      fromRegistration: false,
                    ),
                  );
                }
              }
        } else if (state.status == AuthenticationStatus.unauthenticated) {
          // Navigate to landing screen if not authenticated
          print("🔍 Splash: User not authenticated, navigating to landing");
              _timeoutTimer?.cancel();
              _navigateTo(const LandingScreen());
            } else if (state.status == AuthenticationStatus.failure) {
              _showErrorAndNavigate('Authentication failed. Please try again.');
            }
          },
        ),
        BlocListener<FarmBloc, FarmState>(
          listener: (context, state) {
            print("🌽 Splash: FarmBloc state changed to: ${state.runtimeType}");

            if (state is FarmsLoaded) {
              _timeoutTimer?.cancel(); // Cancel timeout when we get a response
              _farmLoadingTimer?.cancel(); // Cancel farm loading timeout
              _isLoadingFarms = false;
              final hasFarms = state.farms.isNotEmpty;
              print("🌽 Splash: FarmsLoaded. hasFarms=$hasFarms");
              setState(() {
                _statusMessage =
                    hasFarms ? 'Welcome back!' : 'Setting up your farm...';
              });

              // Stop rotation animation
              _rotationController.stop();

              // Immediate navigation - no delay needed
              if (hasFarms) {
                _navigateTo(const HomeScreen());
              } else {
                final userData = _buildUserData();
                _navigateTo(
                  FarmRegistrationScreen(
                    userData: userData ?? {},
                    fromRegistration: false,
                  ),
                );
              }
            } else if (state is FarmError) {
              _timeoutTimer?.cancel(); // Cancel timeout when we get a response
              _farmLoadingTimer?.cancel(); // Cancel farm loading timeout
              _isLoadingFarms = false;
              
              // Check if it's an authentication error
              if (state.message.contains('Authentication expired') ||
                  state.message.contains('Please log in again') ||
                  state.message.contains('401') ||
                  state.message.contains('Unauthorized')) {
                print("🚨 Splash: Authentication expired - redirecting to landing");
                _showErrorAndNavigate('Your session has expired. Please log in again.');
              } else if (state.message.contains('Network error') ||
                         state.message.contains('Server error') ||
                         state.message.contains('internet connection')) {
                // Network/server errors should go back to landing with error message
                print("🚨 Splash: Network/Server error - redirecting to landing");
                _showErrorAndNavigate(state.message);
              } else {
                // Only redirect to farm registration for legitimate "no farms found" scenarios
                print(
                  "🚨 Splash: No farms found: ${state.message}. Proceeding to registration.",
                );
                final userData = _buildUserData();
                _navigateTo(
                  FarmRegistrationScreen(
                    userData: userData ?? {},
                    fromRegistration: false,
                  ),
                );
              }
            } else if (state is FarmLoading) {
              print("🌽 Splash: FarmLoading state - keeping timer active");
              setState(() {
                _statusMessage = 'Loading your farms...';
                _isLoadingFarms = true;
              });
              // Ensure rotation continues during loading
              _rotationController.repeat();
              // DO NOT cancel the farm loading timer here - let it run
            }
          },
        ),
      ],
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

            // Status message display
            Positioned(
              bottom: screenSize.height * 0.30,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _statusMessage,
                      style: textTheme.bodyMedium?.copyWith(
                        color: MAIZE_ACCENT,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
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
