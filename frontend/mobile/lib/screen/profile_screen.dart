import 'package:flutter/material.dart';
import 'package:maize_watch/custom/custom_button.dart';
import 'package:maize_watch/widget/user_info_widget.dart';

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
        child: Padding(
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
              const Text("About User",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold)),
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
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LandingScreen()), // Assuming LandingScreen is your landing screen
                    );
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
