import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/theme/colors.dart';
import 'package:mobile/core/widgets/custom_button.dart';
import 'package:mobile/core/widgets/error_dialog.dart';
import 'package:mobile/core/services/two_factor_auth_service.dart';
import 'package:mobile/generated/l10n.dart';
import '../../../../core/widgets/language_toggle.dart';
import 'two_factor_verification_screen.dart';

class PhoneVerificationScreen extends StatefulWidget {
  final String contactNumber;

  const PhoneVerificationScreen({
    super.key,
    required this.contactNumber,
  });

  @override
  State<PhoneVerificationScreen> createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final TwoFactorAuthService _twoFactorService = TwoFactorAuthService();
  bool _isLoading = false;
  bool _codeSent = false;

  void _handleSendVerificationCode() {
    _sendVerificationCode().catchError((error) {
      // Handle error silently or show user-friendly message
    });
  }

  Future<void> _sendVerificationCode() async {
    setState(() => _isLoading = true);

    final result = await _twoFactorService.sendVerificationCode(widget.contactNumber);

    if (!mounted) return;
    
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      setState(() {
        _codeSent = true;
      });
      
      // Navigate to verification screen
      final verificationResult = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (context) => TwoFactorVerificationScreen(
            contactNumber: widget.contactNumber,
            purpose: 'registration',
            onVerificationSuccess: () {
              Navigator.of(context).pop(true);
            },
          ),
        ),
      );

      if (!mounted) return;

      if (verificationResult == true) {
        // Verification successful, navigate to registration
        Navigator.of(context).pop(true);
      }
    } else {
      ErrorDialog.show(
        context,
        title: S.of(context).error,
        message: result['message'] ?? 'Failed to send verification code',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: MAIZE_PRIMARY_LIGHT,
      appBar: AppBar(
        backgroundColor: MAIZE_PRIMARY_LIGHT,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: MAIZE_ACCENT),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: const LanguageToggle(color_toggle: MAIZE_ACCENT),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(kAppLargePadding.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: kAppLargePadding.h),            
            // Icon
            Center(
              child: Container(
                padding: EdgeInsets.all(kAppLargePadding.w),
                decoration: BoxDecoration(
                  color: MAIZE_PRIMARY.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.phone_android,
                  size: 80.sp,
                  color: MAIZE_PRIMARY,
                ),
              ),
            ),
            
            SizedBox(height: kAppLargePadding.h * 2),
            
            // Title
            Text(
              S.of(context).verify_phone_number,
              style: textTheme.headlineMedium?.copyWith(
                color: MAIZE_ACCENT,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: kAppMediumPadding.h),
            
            // Description
            Text(
              S.of(context).phone_verification_description,
              style: textTheme.bodyLarge?.copyWith(
                color: MAIZE_ACCENT.withOpacity(0.8),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: kAppLargePadding.h),
            
            // Phone number display
            Container(
              padding: EdgeInsets.all(kAppMediumPadding.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(kAppMediumPadding.r),
                border: Border.all(color: MAIZE_PRIMARY.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone,
                    color: MAIZE_PRIMARY,
                    size: 20.sp,
                  ),
                  SizedBox(width: kAppSmallPadding.w),
                  Text(
                    widget.contactNumber,
                    style: textTheme.headlineSmall?.copyWith(
                      color: MAIZE_ACCENT,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: kAppLargePadding.h * 2),
            
            // Send verification code button or resend button
            _isLoading
                ? Container(
                    height: 56.h,
                    decoration: BoxDecoration(
                      color: MAIZE_PRIMARY.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            S.of(context).sending,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : _codeSent
                    ? Column(
                        children: [
                          CustomButton(
                            text: S.of(context).continue_to_registration,
                            onPressed: () {
                              // Navigate to verification screen
                              Navigator.of(context).push<bool>(
                                MaterialPageRoute(
                                  builder: (context) => TwoFactorVerificationScreen(
                                    contactNumber: widget.contactNumber,
                                    purpose: 'registration',
                                    onVerificationSuccess: () {
                                      Navigator.of(context).pop(true);
                                    },
                                  ),
                                ),
                              ).then((verificationResult) {
                                if (verificationResult == true) {
                                  Navigator.of(context).pop(true);
                                }
                              });
                            },
                          ),
                          SizedBox(height: kAppMediumPadding.h),
                          TextButton(
                            onPressed: () => _handleSendVerificationCode(),
                            child: Text(
                              S.of(context).resend_code,
                              style: TextStyle(
                                color: MAIZE_PRIMARY,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      )
                    : CustomButton(
                        text: S.of(context).continue_to_registration,
                        onPressed: () => _handleSendVerificationCode(),
                      ),
            
            SizedBox(height: kAppMediumPadding.h),
            
            // Help text
            Text(
              S.of(context).verification_help_text,
              style: textTheme.bodySmall?.copyWith(
                color: MAIZE_ACCENT.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
