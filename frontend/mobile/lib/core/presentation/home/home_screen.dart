import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/features/live_monitoring/presentation/screens/live_monitoring_screen.dart';
import 'package:mobile/features/settings/presentation/screens/account_screen.dart';
import 'package:mobile/generated/l10n.dart';

import '../../../features/authentication/presentation/bloc/authentication_bloc.dart';
import '../../../features/authentication/presentation/screens/landing_screen.dart';
import '../../../features/prescriptions/presentation/screens/prescription_screen.dart';
import '../../theme/colors.dart';
import '../../services/notification_service.dart';
import '../../widgets/notification_permission_dialog.dart';
import '../../widgets/offline_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static final ValueNotifier<bool> farmDetailOpen = ValueNotifier(false);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 1;
  final PageController _pageController = PageController(initialPage: 1);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Only check auth status if we don't already have a user
    final currentState = context.read<AuthenticationBloc>().state;
    if (currentState.user == null) {
      context.read<AuthenticationBloc>().add(CheckAuthStatusEvent());
    }
    
    // Check notification permissions after a short delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkNotificationPermissions();
    });
  }

  Future<void> _checkNotificationPermissions() async {
    final notificationService = NotificationService();
    await notificationService.initialize();
    
    final hasPermissions = await notificationService.arePermissionsGranted();
    if (!hasPermissions && mounted) {
      // Show permission dialog after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          NotificationPermissionDialog.show(context);
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      // Only check session when app resumes if we don't have a user
      final currentState = context.read<AuthenticationBloc>().state;
      if (currentState.user == null) {
        context.read<AuthenticationBloc>().add(CheckAuthStatusEvent());
      }
    }
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text(S.of(context).logout_title),
                content: Text(S.of(context).logout_message),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(S.of(context).cancel),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<AuthenticationBloc>().add(LogoutEvent());
                      Navigator.of(context).pop(true);
                    },
                    child: Text(S.of(context).logout),
                  ),
                ],
              ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state.status == AuthenticationStatus.unauthenticated) {
          // Session expired or logged out
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).session_expired),
              duration: const Duration(seconds: 3),
            ),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const LandingScreen(showLoginOnLoad: true),
            ),
            (route) => false,
          );
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (!didPop) {
            final shouldPop = await _onWillPop();
            if (shouldPop && context.mounted) {
              Navigator.pushReplacementNamed(context, '/landing');
            }
          }
        },
        child: OfflineIndicator(
          showPersistentIndicator: false,
          child: Scaffold(
            body: SafeArea(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: <Widget>[
                  PrescriptionScreen(),
                  const LiveMonitoringScreen(),
                  const AccountScreen(),
                ],
                onPageChanged: (page) {
                  setState(() {
                    _currentIndex = page;
                  });
                },
              ),
            ),
          bottomNavigationBar: ValueListenableBuilder<bool>(
            valueListenable: HomeScreen.farmDetailOpen,
            builder: (ctx, isOpen, child) => isOpen ? const SizedBox() : child!,
            child: Container(
              decoration: const BoxDecoration(color: MAIZE_BOTTOM_OVERLAY),
              child: SafeArea(
                child: CurvedNavigationBar(
                  index: _currentIndex,
                  backgroundColor: MAIZE_PRIMARY_LIGHT,
                  color: MAIZE_PRIMARY,
                  height: 60.h > 75.0 ? 75.0 : 60.h,
                  items: <Widget>[
                    Icon(
                      Icons.checklist,
                      color: _currentIndex == 0 ? Colors.white : MAIZE_PRIMARY_LIGHT,
                      size: ScreenUtil().setSp(32),
                    ),
                    Icon(
                      Icons.agriculture,
                      color: _currentIndex == 1 ? Colors.white : MAIZE_PRIMARY_LIGHT,
                      size: ScreenUtil().setSp(32),
                    ),
                    Icon(
                      Icons.person,
                      color: _currentIndex == 2 ? Colors.white : MAIZE_PRIMARY_LIGHT,
                      size: ScreenUtil().setSp(32),
                    ),
                  ],
                  onTap: _onTappedBar,
                ),
              ),
            ),
          ),
        ),
        ),      ),
    );
  }

  void _onTappedBar(int value) {
    setState(() {
      _currentIndex = value;
    });
    _pageController.animateToPage(
      value,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
