import 'package:flutter/material.dart';
import 'package:maize_watch/custom/constants.dart';
import 'package:maize_watch/custom/custom_button.dart';
import 'package:maize_watch/custom/custom_font.dart';
import 'package:maize_watch/custom/custom_dialog.dart';
import 'package:maize_watch/widget/user_info_widget.dart';
import 'package:maize_watch/services/api_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'about_us_screen.dart';
import 'landing_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = '';
  String name = '';
  String contactNumber = '';
  String address = '';
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  bool _isUpdating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final userData = await _apiService.getUserData();
      if (userData != null) {
        setState(() {
          userName = userData['username'] ?? '';
          name = userData['fullName'] ?? userData['name'] ?? '';
          contactNumber = userData['contactNumber'] ?? userData['phoneNumber'] ?? '';
          address = userData['address'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load user data';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _errorMessage = 'Error loading user data';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleProfileUpdate(Map<String, String> updatedData) async {
    try {
      setState(() {
        _isUpdating = true;
        _errorMessage = null;
      });

      final response = await _apiService.updateUserProfile(userName, updatedData);

      if (response.success) {
        setState(() {
          userName = updatedData['userName']!;
          name = updatedData['name']!;
          contactNumber = updatedData['contactNumber']!;
          address = updatedData['address']!;
          _isUpdating = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = response.message;
          _isUpdating = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Failed to update profile'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error updating profile: $e');
      setState(() {
        _errorMessage = 'Error updating profile';
        _isUpdating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _onWillPop() async {
    bool shouldLogout = false;

    await customOptionDialog(
      context,
      title: AppLocalizations.of(context)!.logout_title,
      content: AppLocalizations.of(context)!.logout_message,
      onYes: () async {
        shouldLogout = true;

        try {
          await _apiService.logout();
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LandingScreen()),
              (route) => false,
            );
          }
        } catch (e) {
          print('Logout error: $e');
          if (mounted) {
            CustomDialog(
              context,
              title: AppLocalizations.of(context)!.error,
              content: AppLocalizations.of(context)!.logout_error,
            );
          }
        }
      },
    );

    return false;
  }

  void _handleLogout() async {
    customOptionDialog(
      context,
      title: AppLocalizations.of(context)!.logout_title,
      content: AppLocalizations.of(context)!.logout_message,
      onYes: () async {
        setState(() => _isLoading = true);

        try {
          await _apiService.logout();

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LandingScreen()),
            );
          }
        } catch (e) {
          print('Error during logout: $e');
          if (mounted) {
            setState(() => _isLoading = false);
            CustomDialog(
              context,
              title: AppLocalizations.of(context)!.error,
              content: AppLocalizations.of(context)!.logout_error,
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            color: MAIZE_BOTTOM_OVERLAY,
          ),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.green))
              : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _loadUserData,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
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
                                localizations.account,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade900,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              Image.asset(
                                'assets/images/maize_watch_logo.png',
                                height: 60,
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          CustomFont(
                            text: localizations.about_user,
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          const SizedBox(height: 20),

                          UserInfoWidget(
                            userName: userName,
                            name: name,
                            contactNumber: contactNumber,
                            address: address,
                            onUpdate: _handleProfileUpdate,
                            isUpdating: _isUpdating,
                          ),
                          const SizedBox(height: 20),

                          CustomButton(
                            context: context,
                            title: localizations.settings,
                            screen: SettingsScreen(),
                          ),
                          CustomButton(
                            context: context,
                            title: localizations.about,
                            screen: AboutUsScreen(),
                          ),
                          const Spacer(),
                          Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: MAIZE_LOGO_ICON,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                              ),
                              onPressed: _handleLogout,
                              child: Text(
                                localizations.logout,
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
      ),
    );
  }
}
