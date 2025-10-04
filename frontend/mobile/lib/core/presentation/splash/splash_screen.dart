import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/presentation/home/home_screen.dart';

import '../../../features/authentication/presentation/screens/landing_screen.dart';
import '../../../features/authentication/presentation/bloc/authentication_bloc.dart';
import '../../../features/farm/presentation/bloc/farm_bloc.dart';
import '../../../features/farm/presentation/screens/field_registration_screen.dart';
import '../../../features/live_monitoring/presentation/bloc/monitoring_bloc.dart';
import '../../../generated/l10n.dart';
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
        _statusMessage = S.of(context).checking_authentication;
      });

      // Initialize session first, then check authentication
      context.read<AuthenticationBloc>().add(InitializeSessionEvent());
      context.read<AuthenticationBloc>().add(CheckAuthStatusEvent());
      
      // Start analytics loading early for better performance
      _startAnalyticsLoading();
    });

    // Add timeout timer to prevent infinite loading (reduced from 15 to 8 seconds)
    _timeoutTimer = Timer(const Duration(seconds: 8), () {
      if (mounted) {
        // Check if user is authenticated but just having network issues
        final authState = context.read<AuthenticationBloc>().state;
        if (authState.status == AuthenticationStatus.authenticated && authState.user != null) {
          print("🌽 Splash: User is authenticated but analytics timeout - going to home screen for offline access");
          _navigateTo(const HomeScreen());
        } else {
          _showErrorAndNavigate(
            S.of(context).connection_timeout,
          );
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set initial translated message when context is available
    _statusMessage = S.of(context).initializing;
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

  // Start analytics loading early for better performance
  void _startAnalyticsLoading() {
    // Pre-load analytics in the background to improve performance
    Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        final authState = context.read<AuthenticationBloc>().state;
        if (authState.status == AuthenticationStatus.authenticated && authState.user != null) {
          print("🌽 Splash: Pre-loading analytics for better performance");
          // Start analytics loading in background
          context.read<FarmBloc>().add(GetUserFarmsEvent(userId: authState.user!.id));
          
          // Listen for farm loading completion and then load analytics
          _listenForFarmLoadingAndLoadAnalytics();
        }
      }
    });
  }
  
  void _listenForFarmLoadingAndLoadAnalytics() {
    // Listen to FarmBloc stream to know when farms are loaded
    context.read<FarmBloc>().stream.listen((farmState) {
      if (mounted && farmState is FarmsLoaded && farmState.farms.isNotEmpty) {
        final firstFarm = farmState.farms.first;
        print("🌽 Splash: Farms loaded, pre-loading monitoring analytics for farm: ${firstFarm.id}");
        
        // Load analytics for the first farm
        context.read<MonitoringBloc>().add(LoadFarmAnalyticsEvent(farmId: firstFarm.id ?? ''));
        
        // Also load latest readings for immediate display
        Timer(const Duration(milliseconds: 500), () {
          if (mounted) {
            print("🌽 Splash: Pre-loading latest readings");
            context.read<MonitoringBloc>().add(LoadLatestReadingsEvent());
          }
        });
        
        // Listen for analytics loading completion
        _listenForAnalyticsLoading();
      }
    });
  }
  
  void _listenForAnalyticsLoading() {
    // Listen to MonitoringBloc stream to know when analytics are loaded
    context.read<MonitoringBloc>().stream.listen((monitoringState) {
      if (mounted && monitoringState.farmAnalytics != null) {
        print("🌽 Splash: Analytics loaded successfully, navigating to home screen");
        // Cancel timeout timer since we have data
        _timeoutTimer?.cancel();
        // Navigate to home screen with loaded data
        _navigateTo(const HomeScreen());
      }
    });
    
    // Fallback: If analytics don't load within 5 seconds, navigate anyway
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        final monitoringState = context.read<MonitoringBloc>().state;
        if (monitoringState.farmAnalytics == null) {
          print("🌽 Splash: Analytics loading timeout, navigating to home screen anyway");
          _timeoutTimer?.cancel();
          _navigateTo(const HomeScreen());
        }
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
                  _statusMessage = S.of(context).loading_your_farm;
                  _isLoadingFarms = true;
                });

                // Restart rotation animation for loading farms
                _rotationController.repeat();

                print(
                  "🌽 Splash: Authenticated. Fetching farms for user $userId",
                );

                // Set a 15-second timeout specifically for farm loading
                _farmLoadingTimer = Timer(const Duration(seconds: 15), () {
                  if (mounted && _isLoadingFarms) {
                    print(
                      "🚨 Splash: Farm loading timeout - network issue, going to home screen for offline access",
                    );
                    _isLoadingFarms = false;
                    // Go to home screen for offline access
                    _navigateTo(const HomeScreen());
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
              _showErrorAndNavigate(S.of(context).authentication_failed);
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
                    hasFarms ? S.of(context).welcome_back : S.of(context).setting_up_your_farm;
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
                _showErrorAndNavigate(S.of(context).session_expired);
              } else if (state.message.contains('Network error') ||
                         state.message.contains('Server error') ||
                         state.message.contains('internet connection')) {
                // Network/server errors should go to home screen for offline access
                print("🚨 Splash: Network/Server error - going to home screen for offline access");
                _navigateTo(const HomeScreen());
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
                _statusMessage = S.of(context).loading_your_farms;
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
                    S.of(context).from,
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
