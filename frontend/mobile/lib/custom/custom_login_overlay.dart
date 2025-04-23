import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maize_watch/custom/constants.dart';
import 'package:maize_watch/model/user.dart';
import 'package:maize_watch/services/api_service.dart'; // Import for API service
import '../screen/home_screen.dart';
import 'custom_font.dart';

void showLoginOverlay(BuildContext context) {
  final originalContext = context; // Capture the original context
  bool isPasswordVisible = false;
  bool isChecked = false;
  
  User user = User('', '');

  final TextEditingController usernameController = TextEditingController(text: user.email);
  final TextEditingController passwordController = TextEditingController(text: user.password);
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService(); // Create instance of API service

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: MAIZE_BOTTOM_OVERLAY,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 30.w,
              right: 30.w,
              top: 30.h,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: CustomFont(
                        text: 'Log In',
                        fontWeight: FontWeight.bold,
                        color: MAIZE_ACCENT,
                        fontSize: 25,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    CustomFont(
                      text: 'Username',
                      color: MAIZE_ACCENT,
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                    ),
                    SizedBox(height: 5.h),
                    TextFormField(
                      controller: usernameController,
                      onChanged: (value){
                        user.email = value;
                      },
                      decoration: InputDecoration(
                        hintText: '@',
                        filled: true,
                        fillColor: MAIZE_PRIMARY_LIGHT,
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.h),
                    CustomFont(
                      text: 'Password',
                      color: MAIZE_ACCENT,
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                    ),
                    SizedBox(height: 5.h),
                    TextFormField(
                      controller: passwordController,
                      onChanged: (value){
                        user.password = value;
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: MAIZE_PRIMARY_LIGHT,                   
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: MAIZE_ACCENT,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      obscureText: !isPasswordVisible,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        Checkbox(
                          value: isChecked,
                          activeColor: MAIZE_ACCENT,
                          onChanged: (value) {
                            setState(() {
                              isChecked = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: CustomFont(
                            text: 'I accept the terms and privacy policy',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: MAIZE_ACCENT,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF72AB50),
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        textStyle: TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        if (formKey.currentState!.validate() && isChecked) {
                          user = User(usernameController.text, passwordController.text);

                          // Show loading indicator
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return Center(child: CircularProgressIndicator(color: MAIZE_ACCENT));
                            },
                          );

                          try {
                            // Call login API
                            final loginResponse = await apiService.login(user.email, user.password);
                            
                            // Close loading indicator
                            Navigator.pop(context);
                            
                            if (loginResponse.success) {
                              // Close the overlay
                              Navigator.pop(context);
                              
                              // Navigate to HomeScreen using original context
                              Navigator.push(
                                originalContext,
                                MaterialPageRoute(builder: (context) => HomeScreen()),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: CustomFont(
                                    text: loginResponse.message ?? 'Invalid username or password',
                                    color: Colors.white,
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } catch (e) {
                            // Close loading indicator
                            Navigator.pop(context);
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: CustomFont(
                                  text: 'Connection error. Please try again.',
                                  color: Colors.white,
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } else if (!isChecked) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: CustomFont(
                                text: 'You must accept the terms and privacy policy',
                                color: Colors.white,
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: CustomFont(
                        text: 'Log In',
                        fontWeight: FontWeight.w500,
                        color: MAIZE_PRIMARY_LIGHT,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}