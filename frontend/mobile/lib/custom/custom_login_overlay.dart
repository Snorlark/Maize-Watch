import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maize_watch/custom/constants.dart';
import 'package:maize_watch/model/user.dart';
import 'package:maize_watch/services/api_service.dart';
import '../screen/home_screen.dart';
import 'custom_font.dart';
import 'package:url_launcher/url_launcher.dart'; // for hyperlinks

void showLoginOverlay(BuildContext context) {
  final originalContext = context;
  bool isPasswordVisible = false;
  User user = User('', '');

  final TextEditingController usernameController = TextEditingController(text: user.email);
  final TextEditingController passwordController = TextEditingController(text: user.password);
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

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
                      onChanged: (value) {
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
                      onChanged: (value) {
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

                    // AGREEMENT TEXT
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(color: MAIZE_ACCENT, fontSize: 14.sp),
                          children: [
                            TextSpan(text: 'By logging in, you agree to our '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: Colors.blueAccent,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  final url = Uri.parse('https://maize-watch-0l7s.onrender.com/');
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  }
                                },
                            ),
                            TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                color: Colors.blueAccent,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  final url = Uri.parse('https://maize-watch-0l7s.onrender.com/');
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  }
                                },
                            ),
                            TextSpan(text: '.'),
                          ],
                        ),
                      ),
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
                        if (formKey.currentState!.validate()) {
                          user = User(usernameController.text, passwordController.text);

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return Center(child: CircularProgressIndicator(color: MAIZE_ACCENT));
                            },
                          );

                          try {
                            final loginResponse = await apiService.login(user.email, user.password);
                            Navigator.pop(context);

                            if (loginResponse.success) {
                              Navigator.pop(context);
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
