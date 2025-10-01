import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/theme/colors.dart';
import 'package:mobile/core/widgets/custom_button.dart';
import 'package:mobile/core/widgets/error_dialog.dart';
import 'package:mobile/core/services/two_factor_auth_service.dart';
import 'package:mobile/generated/l10n.dart';
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

  Future<void> _sendVerificationCode() async {
    setState(() => _isLoading = true);

    final result = await _twoFactorService.sendVerificationCode(widget.contactNumber);

    if (mounted) {
      setState(() => _isLoading = false);

      if (result['success'] == true) {
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
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: MAIZE_BACKGROUND,
      appBar: AppBar(
        backgroundColor: MAIZE_BACKGROUND,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: MAIZE_ACCENT),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Phone Verification Required',
          style: textTheme.headlineSmall?.copyWith(
            color: MAIZE_ACCENT,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(kAppLargePadding.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: kAppLargePadding.h * 2),
            
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
              'Phone Verification Required',
              style: textTheme.headlineMedium?.copyWith(
                color: MAIZE_ACCENT,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: kAppMediumPadding.h),
            
            // Description
            Text(
              'Please verify your phone number to complete your registration.',
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
            
            // Send verification code button
            CustomButton(
                  text: _isLoading ? 'Sending...' : 'Continue to Registration',
              onPressed: _isLoading ? null : _sendVerificationCode,
              isLoading: _isLoading,
            ),
            
            SizedBox(height: kAppMediumPadding.h),
            
            // Help text
            Text(
              l10n.verification_help_text,
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
