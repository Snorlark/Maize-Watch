import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maize_watch/custom/constants.dart';
import 'package:maize_watch/custom/custom_font.dart';
import 'package:maize_watch/services/api_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class ForgotPasswordOverlay extends StatefulWidget {
  const ForgotPasswordOverlay({Key? key}) : super(key: key);

  @override
  _ForgotPasswordOverlayState createState() => _ForgotPasswordOverlayState();
}

class _ForgotPasswordOverlayState extends State<ForgotPasswordOverlay> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;
  bool _otpSent = false;
  bool _otpVerified = false;
  bool _isPasswordVisible = false;
  String? _phoneNumber;

  // Twilio Configuration from environment variables
  String get _accountSid => dotenv.env['TWILIO_ACCOUNT_SID'] ?? '';
  String get _authToken => dotenv.env['TWILIO_AUTH_TOKEN'] ?? '';
  String get _verifyServiceId => dotenv.env['TWILIO_VERIFY_SERVICE_ID'] ?? '';

  @override
  void initState() {
    super.initState();
    // Validate that environment variables are loaded
    if (_accountSid.isEmpty || _authToken.isEmpty || _verifyServiceId.isEmpty) {
      print('⚠️ Warning: Twilio environment variables not found');
      setState(() {
        _errorMessage = 'Configuration error. Please contact support.';
      });
    }
  }

  Future<void> _fetchUserDetails() async {
    if (_usernameController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your username';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response =
          await _apiService.getUserByUsername(_usernameController.text);

      if (response.success && response.data != null) {
        setState(() {
          _phoneNumber = response.data!['phoneNumber'];
          _errorMessage = null;
        });
        // Automatically proceed to send OTP
        await _sendOTP();
      } else {
        setState(() {
          _errorMessage = response.message ?? 'User not found';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendOTP() async {
    if (_phoneNumber == null) {
      setState(() {
        _errorMessage = 'Phone number not found';
      });
      return;
    }

    // Check if Twilio credentials are available
    if (_accountSid.isEmpty || _authToken.isEmpty || _verifyServiceId.isEmpty) {
      setState(() {
        _errorMessage = 'SMS service not configured. Please contact support.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('📱 Sending OTP to phone number: $_phoneNumber');

      // Format phone number for Twilio (E.164 format)
      String formattedPhone = _phoneNumber!;
      if (!formattedPhone.startsWith('+')) {
        formattedPhone = '+$formattedPhone';
      }
      print('📤 Formatted phone number: $formattedPhone');

      // Send verification code using Twilio Verify API
      final response = await http.post(
        Uri.parse(
            'https://verify.twilio.com/v2/Services/$_verifyServiceId/Verifications'),
        headers: {
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$_accountSid:$_authToken'))}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'To': formattedPhone,
          'Channel': 'sms',
        },
      );

      if (response.statusCode == 201) {
        setState(() {
          _otpSent = true;
          _errorMessage = null;
        });
        print('✅ OTP sent successfully');
      } else {
        throw Exception('Failed to send OTP: ${response.body}');
      }
    } catch (e) {
      print('❌ Error sending OTP: $e');
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter the OTP';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔍 Verifying OTP: ${_otpController.text}');

      // Format phone number for Twilio (E.164 format)
      String formattedPhone = _phoneNumber!;
      if (!formattedPhone.startsWith('+')) {
        formattedPhone = '+$formattedPhone';
      }

      // Verify the OTP with Twilio Verify API
      final response = await http.post(
        Uri.parse(
            'https://verify.twilio.com/v2/Services/$_verifyServiceId/VerificationCheck'),
        headers: {
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$_accountSid:$_authToken'))}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'To': formattedPhone,
          'Code': _otpController.text,
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'approved') {
        setState(() {
          _otpVerified = true;
          _errorMessage = null;
        });
        print('✅ OTP verified successfully');
      } else {
        throw Exception('Invalid OTP');
      }
    } catch (e) {
      print('❌ Error verifying OTP: $e');
      setState(() {
        _errorMessage = 'Invalid OTP. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    if (_newPasswordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter and confirm your new password';
      });
      return;
    }

    if (_newPasswordController.text.length < 6) {
      setState(() {
        _errorMessage = 'Password must be at least 6 characters long';
      });
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.resetPassword(
        _usernameController.text,
        _newPasswordController.text,
      );

      if (response.success) {
        Navigator.pop(context); // Close the overlay
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Password reset successful. Please login with your new password.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Failed to reset password';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resendOTP() async {
    await _sendOTP();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: MAIZE_BOTTOM_OVERLAY,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            CustomFont(
              text: AppLocalizations.of(context)!.forgot_password,
              fontSize: 24.sp,
              color: MAIZE_ACCENT,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 20.h),

            // Form content
            if (!_otpSent) ...[
              CustomFont(
                text: 'Enter your username to reset password',
                fontSize: 16.sp,
                color: Colors.grey[600]!,
              ),
              SizedBox(height: 15.h),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'Enter your username',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: MAIZE_ACCENT, width: 2),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: _isLoading ? null : _fetchUserDetails,
                // ignore: sort_child_properties_last
                child: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text('Processing...'),
                        ],
                      )
                    : CustomFont(
                        text: AppLocalizations.of(context)!.submit,
                        fontSize: 16.sp,
                        color: Colors.white,
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MAIZE_ACCENT,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ]

            // OTP input step
            else if (!_otpVerified) ...[
              CustomFont(
                text: 'Enter the OTP sent to your phone',
                fontSize: 16.sp,
                color: Colors.grey[600]!,
              ),
              SizedBox(height: 15.h),
              TextField(
                controller: _otpController,
                decoration: InputDecoration(
                  labelText: 'Enter OTP',
                  hintText: 'Enter 6-digit OTP',
                  prefixIcon: Icon(Icons.sms),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: MAIZE_ACCENT, width: 2),
                  ),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
              SizedBox(height: 15.h),
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyOTP,
                child: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text('Verifying...'),
                        ],
                      )
                    : Text('Verify OTP', style: TextStyle(fontSize: 16.sp)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MAIZE_ACCENT,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              TextButton(
                onPressed: _isLoading ? null : _resendOTP,
                child: Text(
                  'Resend OTP',
                  style: TextStyle(color: MAIZE_ACCENT),
                ),
              ),
            ]

            // New password input step
            else ...[
              CustomFont(
                text: 'Enter your new password',
                fontSize: 16.sp,
                color: Colors.grey[600]!,
              ),
              SizedBox(height: 15.h),
              TextField(
                controller: _newPasswordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  hintText: 'Enter new password',
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: MAIZE_ACCENT, width: 2),
                  ),
                ),
              ),
              SizedBox(height: 15.h),
              TextField(
                controller: _confirmPasswordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Re-enter new password',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: MAIZE_ACCENT, width: 2),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: _isLoading ? null : _resetPassword,
                child: _isLoading
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text('Resetting...'),
                        ],
                      )
                    : Text('Reset Password', style: TextStyle(fontSize: 16.sp)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MAIZE_ACCENT,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ],

            // Error message display
            if (_errorMessage != null) ...[
              SizedBox(height: 15.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 20.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}