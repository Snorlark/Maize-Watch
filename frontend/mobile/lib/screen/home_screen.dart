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

  // ignore: unused_field
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
       controller: _pageController,
       physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
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
            size: ScreenUtil().setSp(35)
          ),
          Image.asset(
            'assets/images/farmers_nav_bar.png',
            width: ScreenUtil().setSp(30),
            height: ScreenUtil().setSp(30),
          ),
        ],
        
        onTap: _onTappedBar,
      ),

    );
  }
void _onTappedBar(int value) {
  setState(() {
    _currentIndex = value;
  });
  _pageController.animateToPage(
    value,
    duration: Duration(milliseconds: 300), // You can adjust the speed
    curve: Curves.easeInOut, // Smooth easing
  );
}
}