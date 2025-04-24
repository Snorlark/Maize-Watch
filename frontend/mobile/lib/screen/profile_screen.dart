import 'package:flutter/material.dart';
import 'package:maize_watch/custom/custom_button.dart';
import 'package:maize_watch/custom/custom_font.dart';
import 'package:maize_watch/widget/sensor_status_widget.dart';
import 'package:maize_watch/widget/user_info_widget.dart';
import 'package:maize_watch/services/api_service.dart'; // Make sure this import path is correct

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
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

  @override
  Widget build(BuildContext context) {
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
                      "Account",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green.shade900, fontFamily: 'Montserrat'),
                    ),
                    Image.asset(
                      'assets/images/maize_watch_logo.png',
                      height: 60,
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                CustomFont(
                  text: "About User",
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 20),

                //User Info Widget
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

                CustomButton(context: context, title: "Settings", screen: SettingsScreen()),
                CustomButton(context: context, title: "About", screen: const AboutUsScreen()),
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
                    onPressed: () {
                      _apiService.logout().then((_) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LandingScreen()),
                        );
                      });
                    },
                    child: const Text("Log out",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Montserrat')),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
      ),
    );
  }
}