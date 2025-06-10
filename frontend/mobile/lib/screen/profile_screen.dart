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

      print('Calling getUserData()...');
      final userData = await _apiService.getUserData();
      print('getUserData returned: $userData');
      
      if (userData != null) {
        print('=== FULL API RESPONSE DEBUG ===');
        print('Raw userData: $userData');
        print('userData type: ${userData.runtimeType}');
        print('userData keys: ${userData.keys}');
        
        // Check each field individually
        userData.forEach((key, value) {
          print('Field "$key": $value (${value.runtimeType})');
        });
        
        // Check if data is nested
        if (userData.containsKey('user')) {
          print('Found nested user object: ${userData['user']}');
        }
        if (userData.containsKey('data')) {
          print('Found nested data object: ${userData['data']}');
        }
        print('================================');
        
        setState(() {
          // Handle potential nested structure
          Map<String, dynamic> userInfo = userData;
          
          // Check if user data is nested under 'user' or 'data' key
          if (userData.containsKey('user') && userData['user'] is Map) {
            userInfo = userData['user'] as Map<String, dynamic>;
            print('Using nested user data: $userInfo');
          } else if (userData.containsKey('data') && userData['data'] is Map) {
            userInfo = userData['data'] as Map<String, dynamic>;
            print('Using nested data: $userInfo');
          }
          
          // Map exact field names from MongoDB document with null safety
          userName = userInfo['username']?.toString() ?? '';
          name = userInfo['fullName']?.toString() ?? '';
          contactNumber = userInfo['contactNumber']?.toString() ?? '';
          address = userInfo['address']?.toString() ?? '';
          
          _isLoading = false;
        });

        print('Final parsed data - Username: $userName, Name: $name, Contact: $contactNumber, Address: $address');
        
        // Check if essential fields are missing from API response
        if (contactNumber.isEmpty || address.isEmpty) {
          print('WARNING: Missing fields in API response!');
          print('contactNumber missing: ${contactNumber.isEmpty}');
          print('address missing: ${address.isEmpty}');
          print('Expected fields: [username, fullName, contactNumber, address, role]');
          
          // Try to fetch complete user data if fields are missing
          final completeUserData = await _apiService.getUserByUsername(userName);
          if (completeUserData != null && completeUserData.data != null) {
            final userDetails = completeUserData.data as Map<String, dynamic>;
            setState(() {
              contactNumber = userDetails['contactNumber']?.toString() ?? '';
              address = userDetails['address']?.toString() ?? '';
            });
            print('Updated from getUserByUsername - Contact: $contactNumber, Address: $address');
          }
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load user data - No data received';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _errorMessage = 'Error loading user data: ${e.toString()}';
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

      print('Updating profile with data: $updatedData');

      // Prepare the update payload with correct field names
      final updatePayload = {
        'fullName': updatedData['name'] ?? name,
        'contactNumber': updatedData['contactNumber'] ?? contactNumber,
        'address': updatedData['address'] ?? address,
      };

      final response = await _apiService.updateUserProfile(userName, updatePayload);

      if (response.success) {
        setState(() {
          name = updatedData['name'] ?? name;
          contactNumber = updatedData['contactNumber'] ?? contactNumber;
          address = updatedData['address'] ?? address;
          _isUpdating = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }

        // Reload data to ensure consistency with backend
        await _loadUserData();
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Failed to update profile';
          _isUpdating = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Failed to update profile'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('Error updating profile: $e');
      setState(() {
        _errorMessage = 'Error updating profile: ${e.toString()}';
        _isUpdating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
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
        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              color: MAIZE_BOTTOM_OVERLAY,
            ),
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.green),
                        SizedBox(height: 16),
                        Text(
                          'Loading profile...',
                          style: TextStyle(
                            color: Colors.black54,
                            fontFamily: 'Montserrat',
                          ),
                        ),
                      ],
                    ),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error Loading Profile',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontFamily: 'Montserrat',
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: _loadUserData,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: MAIZE_ACCENT,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20), // Reduced top spacing
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
                              screen: const AboutUsScreen(),
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
      ),
    );
  }
}