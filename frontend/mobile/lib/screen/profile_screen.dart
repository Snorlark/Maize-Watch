import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maize_watch/custom/custom_button.dart';
import 'package:maize_watch/custom/custom_font.dart';
import 'package:maize_watch/custom/custom_dialog.dart';
import 'package:maize_watch/widget/user_info_widget.dart';
import 'package:maize_watch/services/api_service.dart';
import 'package:maize_watch/services/translation_service.dart';

import 'about_us_screen.dart';
import 'landing_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = 'farmer1';
  String name = 'Juan Dela Cruz';
  String contactNumber = '+639 023 2311 321';
  String address = '0717 Tolentino St., Sampaloc, Philippines';
  final ApiService _apiService = ApiService();
  final TranslationService _translationService = TranslationService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    
    // Initialize translation service
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _translationService.init();
    });
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _apiService.getUserData();
      if (userData != null) {
        setState(() {
          userName = userData['username'] ?? 'farmer1';
          name = userData['fullName'] ?? userData['name'] ?? 'Juan Dela Cruz';
          contactNumber = userData['contactNumber'] ?? userData['phoneNumber'] ?? '+639 023 2311 321';
          address = userData['address'] ?? '0717 Tolentino St., Sampaloc, Philippines';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() => _isLoading = false);
    }
  }
  
  // Handle the back button press
  Future<bool> _onWillPop() async {
    bool shouldPop = false;
    
    await customOptionDialog(
      context,
      title: _translationService.translate("exit_app_title"), 
      content: _translationService.translate("exit_app_message"),
      onYes: () {
        shouldPop = true;
        SystemNavigator.pop(); // Exit the app
      }
    );
    
    return shouldPop;
  }
  
  // Handle logout with confirmation
  void _handleLogout() async {
    customOptionDialog(
      context,
      title: _translationService.translate("logout_title"),
      content: _translationService.translate("logout_message"),
      onYes: () async {
        setState(() => _isLoading = true);
        
        try {
          // Clear any stored user data
          await _apiService.logout();
          
          // Navigate to landing screen
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LandingScreen()),
            );
          }
        } catch (e) {
          print('Error during logout: $e');
          if (mounted) {
            setState(() => _isLoading = false);
            CustomDialog(
              context,
              title: _translationService.translate("error"),
              content: _translationService.translate("logout_error"),
            );
          }
        }
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: ValueListenableBuilder<Map<String, dynamic>>(
        valueListenable: _translationService.translationNotifier,
        builder: (context, translationData, _) {
          final currentLanguage = translationData['currentLanguage'] ?? 'en';
          
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/GRADIENT.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Colors.green))
                : Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _translationService.translate("account"),
                            style: TextStyle(
                              fontSize: 24, 
                              fontWeight: FontWeight.bold, 
                              color: Colors.green.shade900, 
                              fontFamily: 'Montserrat'
                            ),
                            key: ValueKey('account_title_$currentLanguage'), // Force rebuild with language change
                          ),
                          Image.asset(
                            'assets/images/maize_watch_logo.png',
                            height: 60,
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      CustomFont(
                        text: _translationService.translate("about_user"),
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        key: ValueKey('about_user_$currentLanguage'), // Force rebuild with language change
                      ),
                      const SizedBox(height: 20),

                      UserInfoWidget(
                        userName: userName,
                        name: name,
                        contactNumber: contactNumber,
                        address: address,
                        onUpdate: (updatedData) {
                          setState(() {
                            userName = updatedData['userName']!;
                            name = updatedData['name']!;
                            contactNumber = updatedData['contactNumber']!;
                            address = updatedData['address']!;
                          });
                        },
                      ),             
                      const SizedBox(height: 20),

                      CustomButton(
                        context: context,
                        title: _translationService.translate("settings"),
                        screen: SettingsScreen(),
                        key: ValueKey('settings_button_$currentLanguage'), // Force rebuild with language change
                      ),
                      CustomButton(
                        context: context,
                        title: _translationService.translate("about"),
                        screen: AboutUsScreen(),
                        key: ValueKey('about_button_$currentLanguage'), // Force rebuild with language change
                      ),
                      const Spacer(),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade500,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          ),
                          onPressed: _handleLogout,
                          child: Text(
                            _translationService.translate("logout"),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
            ),
          );
        }
      ),
    );
  }
}