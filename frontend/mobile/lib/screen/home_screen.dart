import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'package:maize_watch/custom/constants.dart';

import 'crop_condition_screen.dart';
import 'prescription_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1;
  final PageController _pageController = PageController(initialPage: 1);

  Future<bool> _onWillPop() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('Do you really want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Logout'),
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
          backgroundColor: MAIZE_PRIMARY,
          items: <Widget>[
            Icon(
              Icons.checklist,
              color: MAIZE_LOGO_ICON,
              size: ScreenUtil().setSp(35),
            ),
            Icon(
              FlutterIcons.corn_mco,
              color: MAIZE_LOGO_ICON,
              size: ScreenUtil().setSp(35),
            ),
            Image.asset(
              'assets/images/farmers_nav_bar.png',
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
