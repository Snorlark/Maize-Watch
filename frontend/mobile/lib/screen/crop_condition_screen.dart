import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maize_watch/custom/custom_font.dart';
import 'package:maize_watch/services/api_service.dart';
import 'package:maize_watch/services/translation_service.dart';
import 'package:maize_watch/widget/dashboard_widget.dart'; // Make sure this import path is correct

class CropConditionScreen extends StatefulWidget {
  const CropConditionScreen({super.key});

  @override
  State<CropConditionScreen> createState() => _CropConditionScreenState();
}

class _CropConditionScreenState extends State<CropConditionScreen> {
  String _greeting = 'Good Morning';
  String _userName = 'farmer';

  final ApiService _apiService = ApiService();
  final TranslationService _translationService = TranslationService();
  
  @override
  void initState() {
    super.initState();
    _loadUserGreeting();
  }
  
  Future<void> _loadUserGreeting() async {
    final userData = await _apiService.getUserData();
    if (userData != null) {
      // Get the user's name - adjust field name as needed
      final name = userData['fullName'] ?? userData['name'] ?? userData['username'] ?? 'farmer';
      // Extract first name if possible
      final firstName = name.contains(' ') ? name.split(' ')[0] : name;
      
      setState(() {
        _greeting = _translationService.translate('key');
        _greeting = _apiService.getGreeting(firstName).split(',')[0]; // Just the greeting part
        _userName = firstName;
      });
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold( // <- Add this
    body: Stack(
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(),
        ),
        SafeArea( // <- Add SafeArea to prevent UI overflow at the top/bottom
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              ScreenUtil().setSp(30),
              ScreenUtil().setSp(50),
              ScreenUtil().setSp(30),
              ScreenUtil().setSp(50),
            ),
               child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomFont(
                        text: '$_greeting, ',
                        color: Colors.white,
                        fontSize: ScreenUtil().setSp(23),
                        fontWeight: FontWeight.bold,
                      ),
                      CustomFont(
                        text: _userName,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                        fontSize: ScreenUtil().setSp(23),
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(child: const DashboardWidget())         
                ],
            ),
          ),
        ),
      ],
    ),
  );
}
}