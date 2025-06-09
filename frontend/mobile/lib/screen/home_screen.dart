import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'package:maize_watch/custom/constants.dart';
import 'package:maize_watch/services/api_service.dart';
import 'package:maize_watch/screen/landing_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'crop_condition_screen.dart';
import 'prescription_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 1;
  final PageController _pageController = PageController(initialPage: 1);
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
      // Check session when app resumes
      final isExpired = await _apiService.isSessionExpired();
      if (isExpired && mounted) {
        // Show session expired message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.session_expired),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {
                // Navigate to landing screen
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LandingScreen(showLoginOnLoad: true)),
                  (route) => false,
                );
              },
            ),
          ),
        );
      }
    }
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.logout_title),
        content: Text(AppLocalizations.of(context)!.logout_message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              await _apiService.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LandingScreen()),
                  (route) => false,
                );
              }
            },
            child: Text(AppLocalizations.of(context)!.logout),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        bool logoutConfirmed = await _onWillPop();
        if (logoutConfirmed) {
          // ignore: use_build_context_synchronously
          Navigator.pushReplacementNamed(context, '/landing'); // Or your login route
        }
        return false; // Prevent default pop
      },
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: const <Widget>[
            PrescriptionScreen(),
            CropConditionScreen(),
            ProfileScreen()
          ],
          onPageChanged: (page) {
            setState(() {
              _currentIndex = page;
            });
          },
        ),
        bottomNavigationBar: CurvedNavigationBar(
          index: _currentIndex,
          backgroundColor: MAIZE_BOTTOM_OVERLAY,
          color: MAIZE_PRIMARY,
          items: <Widget>[
            Icon(
              Icons.checklist,
              color: MAIZE_PRIMARY_LIGHT,
              size: ScreenUtil().setSp(35),
            ),
            Icon(
              FlutterIcons.corn_mco,
              color: MAIZE_PRIMARY_LIGHT,
              size: ScreenUtil().setSp(35),
            ),
            Image.asset(
              'assets/images/farmers_nav_bar_white.png',
              width: ScreenUtil().setSp(30),
              height: ScreenUtil().setSp(30),
            ),
          ],
          onTap: _onTappedBar,
        ),
      ),
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
