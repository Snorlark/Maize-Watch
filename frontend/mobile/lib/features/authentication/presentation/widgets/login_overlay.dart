import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/theme/colors.dart';
import 'package:mobile/core/widgets/policy_dialogs.dart';
import 'package:mobile/features/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:mobile/features/farm/presentation/bloc/farm_bloc.dart';

import 'package:mobile/generated/l10n.dart';
import 'forgot_password_overlay.dart';
import '../../../../core/widgets/error_dialog.dart';

class LoginOverlay extends StatefulWidget {
  const LoginOverlay({super.key});

  @override
  State<LoginOverlay> createState() => _LoginOverlayState();
}

class _LoginOverlayState extends State<LoginOverlay> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  void _checkFarmDataAndNavigate(BuildContext context, user) async {
    print("🔐 LoginOverlay: Starting farm data check for user ${user.id}");
    
    // Check if user has farms and navigate directly
    try {
      context.read<FarmBloc>().add(GetUserFarmsEvent(userId: user.id));
    } catch (e) {
      print("🚨 LoginOverlay: Error checking farms, navigating to registration: $e");
      // If error, navigate to farm registration as fallback
      final userData = {
        'id': user.id,
        'username': user.username,
        'fullName': user.fullName,
        'contactNumber': user.contactNumber,
        'address': user.address,
        'role': user.role,
      };
      
      // Close overlay and navigate
      Navigator.of(context).pop();
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/farm-registration',
        (route) => false,
        arguments: userData,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final textTranslation = S.of(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {
            print("🔐 LoginOverlay: State changed to ${state.status}");
            
            if (state.status == AuthenticationStatus.loading) {
              print("🔐 LoginOverlay: Showing loading dialog");
              // Show loading indicator
              showDialog(
                context: context,
                barrierDismissible: false,
                builder:
                    (context) => const Center(child: CircularProgressIndicator()),
              );
            } else if (state.status == AuthenticationStatus.authenticated) {
              print("🔐 LoginOverlay: Authentication successful, checking farms...");
              // Dismiss loading indicator if shown
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              }
              // Check for farm data before navigating
              _checkFarmDataAndNavigate(context, state.user!);
            } else if (state.status == AuthenticationStatus.failure) {
              print("🚨 LoginOverlay: Authentication failed: ${state.message}");
              // Dismiss loading indicator if shown
              if (Navigator.canPop(context)) {
                Navigator.of(context).pop();
              }

              ErrorDialog.show(
                context,
                title: S.of(context).login_error,
                message: ErrorDialog.getErrorMessage(context, state.message!),
              );
            }
          },
        ),
        BlocListener<FarmBloc, FarmState>(
          listener: (context, state) {
            if (state is FarmsLoaded) {
              final hasFarms = state.farms.isNotEmpty;
              print("🌽 LoginOverlay: FarmsLoaded. hasFarms=$hasFarms");
              
              if (hasFarms) {
                // Close overlay and navigate to home
                Navigator.of(context).pop();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/home',
                  (route) => false,
                );
              } else {
                // Close overlay and navigate to farm registration
                final authState = context.read<AuthenticationBloc>().state;
                final user = authState.user;
                final userData = {
                  if (user != null) ...{
                    'id': user.id,
                    'username': user.username,
                    'fullName': user.fullName,
                    'contactNumber': user.contactNumber,
                    'address': user.address,
                    'role': user.role,
                  }
                };
                Navigator.of(context).pop();
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/farm-registration',
                  (route) => false,
                  arguments: userData,
                );
              }
            } else if (state is FarmError) {
              print("🚨 LoginOverlay: Error loading farms: ${state.message}. Navigating to registration.");
              
              final authState = context.read<AuthenticationBloc>().state;
              final user = authState.user;
              final userData = {
                if (user != null) ...{
                  'id': user.id,
                  'username': user.username,
                  'fullName': user.fullName,
                  'contactNumber': user.contactNumber,
                  'address': user.address,
                  'role': user.role,
                }
              };
              // Close overlay and navigate to farm registration
              Navigator.of(context).pop();
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/farm-registration',
                (route) => false,
                arguments: userData,
              );
            }
          },
        ),
      ],
      child: Padding(
        padding: EdgeInsets.only(
          left: kAppLargePadding.w,
          right: kAppLargePadding.w,
          top: kAppLargePadding.h,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    textTranslation.login,
                    style: textTheme.headlineMedium?.copyWith(
                      color: MAIZE_ACCENT,
                    ),
                  ),
                ),
                SizedBox(height: kAppLargePadding.h),
                Text(
                  textTranslation.username,
                  style: textTheme.bodyMedium?.copyWith(
                    color: MAIZE_ACCENT,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: kAppSmallPadding.h),
                TextFormField(
                  controller: _usernameController,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: MAIZE_ACCENT),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(kAppMediumPadding.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: kAppMediumPadding.w,
                      vertical: kAppSmallPadding.h,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return textTranslation.username_required;
                    }
                    return null;
                  },
                ),
                SizedBox(height: kAppLargePadding.h),
                Text(
                  textTranslation.password,
                  style: textTheme.bodyMedium?.copyWith(
                    color: MAIZE_ACCENT,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: kAppSmallPadding.h),
                TextFormField(
                  controller: _passwordController,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: MAIZE_ACCENT),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(kAppMediumPadding.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: kAppMediumPadding.w,
                      vertical: kAppSmallPadding.h,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: MAIZE_ACCENT,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_isPasswordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return textTranslation.password_required;
                    }
                    return null;
                  },
                ),
                SizedBox(height: kAppSmallPadding.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => const ForgotPasswordOverlay(),
                      );
                    },
                    child: Text(
                      textTranslation.forgot_password,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: MAIZE_ACCENT,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: kAppLargePadding.h),
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: MAIZE_ACCENT,
                        fontSize: 14.sp,
                      ),
                      children: [
                        TextSpan(text: textTranslation.agreement_prefix),
                        TextSpan(
                          text: textTranslation.privacy_policy,
                          style: TextStyle(
                            color: Colors.blueAccent,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap =
                                    () => PolicyDialogs.showPrivacyPolicy(
                                      context,
                                    ),
                        ),
                        TextSpan(text: textTranslation.and),
                        TextSpan(
                          text: textTranslation.terms_of_service,
                          style: TextStyle(
                            color: Colors.blueAccent,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer:
                              TapGestureRecognizer()
                                ..onTap =
                                    () => PolicyDialogs.showTermsOfService(
                                      context,
                                    ),
                        ),
                        TextSpan(text: textTranslation.agreement_suffix),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: kAppLargePadding.h),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MAIZE_PRIMARY,
                    padding: EdgeInsets.symmetric(
                      horizontal: kAppLargePadding.w,
                      vertical: kAppMediumPadding.h,
                    ),
                    textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kAppMediumPadding.r),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.read<AuthenticationBloc>().add(
                        LoginEvent(
                          username: _usernameController.text,
                          password: _passwordController.text,
                        ),
                      );
                    }
                  },
                  child: Text(
                    textTranslation.login,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: MAIZE_PRIMARY_LIGHT,
                    ),
                  ),
                ),
                SizedBox(height: kAppLargePadding.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showLoginOverlay(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: MAIZE_BOTTOM_OVERLAY,
    builder: (context) => const LoginOverlay(),
  );
}
