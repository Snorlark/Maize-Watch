import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maize_watch/custom/constants.dart';
import 'package:maize_watch/main.dart';
import 'package:maize_watch/model/user.dart';
import 'package:maize_watch/services/api_service.dart';
import '../screen/home_screen.dart';
import 'custom_font.dart';
import 'package:url_launcher/url_launcher.dart'; // for hyperlinks
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void showLoginOverlay(BuildContext context) {
  // Ensure we dispose any active overlays when the function exits
  OverlayEntry? activeOverlay;
  final originalContext = context;
  bool isPasswordVisible = false;
  User user = User('', '');

  final TextEditingController usernameController =
      TextEditingController(text: user.email);
  final TextEditingController passwordController =
      TextEditingController(text: user.password);
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  // Overlay entry for custom error message that will appear above everything
  void showErrorOverlay(String message) {
    // Remove any existing overlay first
    if (activeOverlay != null) {
      activeOverlay!.remove();
      activeOverlay = null;
    }

    // Create a new overlay entry
    activeOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: 20,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                )
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: CustomFont(
                    text: message,
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  onPressed: () {
                    if (activeOverlay != null) {
                      activeOverlay!.remove();
                      activeOverlay = null;
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );

    // Insert the overlay
    Overlay.of(originalContext).insert(activeOverlay!);

    // Auto-dismiss after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      if (activeOverlay != null) {
        activeOverlay!.remove();
        activeOverlay = null;
      }
    });
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: MAIZE_BOTTOM_OVERLAY,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
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
                        text: AppLocalizations.of(context)!.login,
                        fontWeight: FontWeight.bold,
                        color: MAIZE_ACCENT,
                        fontSize: 25,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    CustomFont(
                      text: AppLocalizations.of(context)!.username,
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
                        filled: true,
                        fillColor: MAIZE_PRIMARY_LIGHT,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .username_required;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.h),
                    CustomFont(
                      text: AppLocalizations.of(context)!.password,
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
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
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
                          return AppLocalizations.of(context)!
                              .password_required;
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
                          style:
                              TextStyle(color: MAIZE_ACCENT, fontSize: 14.sp),
                          children: [
                            TextSpan(
                                text: AppLocalizations.of(context)!
                                    .agreement_prefix),
                            TextSpan(
                              text:
                                  AppLocalizations.of(context)!.privacy_policy,
                              style: TextStyle(
                                color: Colors.blueAccent,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  final url = Uri.parse(
                                      'https://maize-watch-0l7s.onrender.com/');
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  }
                                },
                            ),
                            TextSpan(text: AppLocalizations.of(context)!.and),
                            TextSpan(
                              text: AppLocalizations.of(context)!
                                  .terms_of_service,
                              style: TextStyle(
                                color: Colors.blueAccent,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  final url = Uri.parse(
                                      'https://maize-watch-0l7s.onrender.com/');
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  }
                                },
                            ),
                            TextSpan(
                                text: AppLocalizations.of(context)!
                                    .agreement_suffix),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF72AB50),
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        textStyle: TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          user = User(
                              usernameController.text, passwordController.text);

                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return Center(
                                  child: CircularProgressIndicator(
                                      color: MAIZE_ACCENT));
                            },
                          );

                          try {
                            final loginResponse = await apiService.login(
                                user.email, user.password);
                            Navigator.pop(context); // Dismiss loading dialog

                            if (loginResponse.success) {
                              Navigator.pop(context); // Dismiss the modal
                              Navigator.push(
                                originalContext,
                                NoSwipePageRoute(
                                    builder: (context) => const HomeScreen()),
                              );
                            } else {
                              // Show error at the top with custom overlay
                              showErrorOverlay(loginResponse.message ??
                                  AppLocalizations.of(context)!.invalid_credentials);
                            }
                          } catch (e) {
                            Navigator.pop(context); // Dismiss loading dialog
                            // Show connection error at the top with custom overlay
                            showErrorOverlay(
                                AppLocalizations.of(context)!.connection_error);
                          }
                        }
                      },
                      child: CustomFont(
                        text: AppLocalizations.of(context)!.login,
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
