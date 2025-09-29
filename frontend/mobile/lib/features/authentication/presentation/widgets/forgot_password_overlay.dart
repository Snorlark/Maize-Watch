import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/theme/colors.dart';
import 'package:mobile/generated/l10n.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile/core/config/environment.dart';

class ForgotPasswordOverlay extends StatefulWidget {
  const ForgotPasswordOverlay({super.key});

  @override
  State<ForgotPasswordOverlay> createState() => _ForgotPasswordOverlayState();
}

class _ForgotPasswordOverlayState extends State<ForgotPasswordOverlay> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _codeSent = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendResetCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/auth/send-reset-code'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': _usernameController.text,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          _codeSent = true;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification code sent to your phone number'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        setState(() {
          _errorMessage = data['message'] ?? 'Failed to send verification code';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = S.of(context).network_error;
        _isLoading = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = S.of(context).passwords_do_not_match;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.133.241.206:8080/api/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': _usernameController.text,
          'code': _codeController.text,
          'newPassword': _newPasswordController.text,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).password_reset_successful),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        setState(() {
          _errorMessage = data['message'] ?? 'Failed to reset password';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = S.of(context).network_error;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final textTranslation = S.of(context);

    return Container(
      decoration: BoxDecoration(
        color: MAIZE_BOTTOM_OVERLAY,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: kAppLargePadding.w,
          right: kAppLargePadding.w,
          top: kAppLargePadding.h,
          bottom: MediaQuery.of(context).viewInsets.bottom + kAppLargePadding.h,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.arrow_back, color: MAIZE_ACCENT),
                    ),
                    Expanded(
                    child: Text(
                      textTranslation.reset_password,
                      style: textTheme.headlineMedium?.copyWith(
                        color: MAIZE_ACCENT,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    ),
                    SizedBox(width: 48.w), // Balance the back button
                  ],
                ),
                SizedBox(height: kAppLargePadding.h),

                if (!_codeSent) ...[
                  // Username Input
                  Text(
                    'Username',
                    style: textTheme.bodyMedium?.copyWith(
                      color: MAIZE_ACCENT,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: kAppSmallPadding.h),
                  TextFormField(
                    controller: _usernameController,
                    keyboardType: TextInputType.text,
                    style: textTheme.bodyMedium?.copyWith(color: MAIZE_ACCENT),
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
                      hintText: 'Enter your username',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Username is required';
                      }
                      if (value.length < 3) {
                        return 'Username must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: kAppLargePadding.h),

                  // Send Code Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MAIZE_PRIMARY,
                      padding: EdgeInsets.symmetric(vertical: kAppMediumPadding.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(kAppMediumPadding.r),
                      ),
                    ),
                    onPressed: _isLoading ? null : _sendResetCode,
                    child: _isLoading
                        ? SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(MAIZE_PRIMARY_LIGHT),
                            ),
                          )
                        : Text(
                            textTranslation.send_verification_code,
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: MAIZE_PRIMARY_LIGHT,
                            ),
                          ),
                  ),
                ] else ...[
                  // Verification Code Input
                  Text(
                    textTranslation.verification_code,
                    style: textTheme.bodyMedium?.copyWith(
                      color: MAIZE_ACCENT,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: kAppSmallPadding.h),
                  TextFormField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    style: textTheme.bodyMedium?.copyWith(color: MAIZE_ACCENT),
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
                      hintText: 'Enter 6-digit code',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return textTranslation.verification_code_required;
                      }
                      if (value.length != 6) {
                        return textTranslation.verification_code_invalid;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: kAppLargePadding.h),

                  // New Password Input
                  Text(
                    textTranslation.new_password,
                    style: textTheme.bodyMedium?.copyWith(
                      color: MAIZE_ACCENT,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: kAppSmallPadding.h),
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: !_isPasswordVisible,
                    style: textTheme.bodyMedium?.copyWith(color: MAIZE_ACCENT),
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
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: MAIZE_ACCENT,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return textTranslation.new_password_required;
                      }
                      if (value.length < 6) {
                        return textTranslation.password_min_length;
                      }
                      if (value.length > 50) {
                        return 'Password must be less than 50 characters';
                      }
                      // Check for at least one letter and one number
                      if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(value)) {
                        return 'Password must contain at least one letter and one number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: kAppLargePadding.h),

                  // Confirm Password Input
                  Text(
                    textTranslation.confirm_password,
                    style: textTheme.bodyMedium?.copyWith(
                      color: MAIZE_ACCENT,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: kAppSmallPadding.h),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    style: textTheme.bodyMedium?.copyWith(color: MAIZE_ACCENT),
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
                          _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: MAIZE_ACCENT,
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return textTranslation.confirm_password_required;
                      }
                      if (value != _newPasswordController.text) {
                        return textTranslation.passwords_do_not_match;
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: kAppLargePadding.h),

                  // Reset Password Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MAIZE_PRIMARY,
                      padding: EdgeInsets.symmetric(vertical: kAppMediumPadding.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(kAppMediumPadding.r),
                      ),
                    ),
                    onPressed: _isLoading ? null : _resetPassword,
                    child: _isLoading
                        ? SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(MAIZE_PRIMARY_LIGHT),
                            ),
                          )
                        : Text(
                            textTranslation.reset_password,
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: MAIZE_PRIMARY_LIGHT,
                            ),
                          ),
                  ),
                ],

                // Error Message
                if (_errorMessage != null) ...[
                  SizedBox(height: kAppMediumPadding.h),
                  Container(
                    padding: EdgeInsets.all(kAppSmallPadding.w),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(kAppSmallPadding.r),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: textTheme.bodySmall?.copyWith(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],

                SizedBox(height: kAppLargePadding.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
