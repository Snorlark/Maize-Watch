import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/theme/colors.dart';
import 'package:mobile/core/widgets/custom_button.dart';
import 'package:mobile/core/widgets/error_dialog.dart';
import 'package:mobile/core/services/two_factor_auth_service.dart';
import 'package:mobile/generated/l10n.dart';

class TwoFactorVerificationScreen extends StatefulWidget {
  final String contactNumber;
  final String purpose; // 'registration' or 'password_reset'
  final VoidCallback? onVerificationSuccess;

  const TwoFactorVerificationScreen({
    super.key,
    required this.contactNumber,
    required this.purpose,
    this.onVerificationSuccess,
  });

  @override
  State<TwoFactorVerificationScreen> createState() => _TwoFactorVerificationScreenState();
}

class _TwoFactorVerificationScreenState extends State<TwoFactorVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final TwoFactorAuthService _twoFactorService = TwoFactorAuthService();
  
  bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = 0;
  String? _sessionId;

  @override
  void initState() {
    super.initState();
    _sendInitialCode();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendInitialCode() async {
    setState(() => _isLoading = true);
    
    final result = await _twoFactorService.sendVerificationCode(widget.contactNumber);
    
    if (mounted) {
      setState(() => _isLoading = false);
      
      if (result['success'] == true) {
        _sessionId = result['sid'];
        await _twoFactorService.storeVerificationSession(
          contactNumber: widget.contactNumber,
          sessionId: _sessionId ?? '',
        );
        _startResendCountdown();
      } else {
        ErrorDialog.show(
          context,
          title: S.of(context).error,
          message: result['message'] ?? 'Failed to send verification code',
        );
      }
    }
  }

  void _startResendCountdown() {
    setState(() => _resendCountdown = 60);
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_resendCountdown > 0) {
            _resendCountdown--;
          } else {
            timer.cancel();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _handleVerifyCode() {
    _verifyCode().catchError((error) {
      print('Error in _verifyCode: $error');
    });
  }

  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _twoFactorService.verifyCode(
      widget.contactNumber,
      _codeController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);

      if (result['success'] == true && result['verified'] == true) {
        // Verification successful
        await _twoFactorService.clearVerificationSession();
        
        if (widget.onVerificationSuccess != null) {
          widget.onVerificationSuccess!();
        } else {
          Navigator.of(context).pop(true);
        }
      } else {
        ErrorDialog.show(
          context,
            title: 'Verification Failed',
          message: result['message'] ?? 'Invalid verification code',
        );
      }
    }
  }

  Future<void> _resendCode() async {
    if (_resendCountdown > 0) return;

    setState(() => _isResending = true);

    final result = await _twoFactorService.sendVerificationCode(widget.contactNumber);

    if (mounted) {
      setState(() => _isResending = false);

      if (result['success'] == true) {
        _sessionId = result['sid'];
        await _twoFactorService.storeVerificationSession(
          contactNumber: widget.contactNumber,
          sessionId: _sessionId ?? '',
        );
        _startResendCountdown();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
                content: Text(S.of(context).verification_code_resent),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ErrorDialog.show(
          context,
          title: S.of(context).error,
          message: result['message'] ?? 'Failed to resend verification code',
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
              'Verify Phone Number',
          style: textTheme.headlineSmall?.copyWith(
            color: MAIZE_ACCENT,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(kAppLargePadding.w),
        child: Form(
          key: _formKey,
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
                    Icons.sms,
                    size: 64.sp,
                    color: MAIZE_PRIMARY,
                  ),
                ),
              ),
              
              SizedBox(height: kAppLargePadding.h),
              
              // Title
              Text(
                l10n.verification_code_sent,
                style: textTheme.headlineMedium?.copyWith(
                  color: MAIZE_ACCENT,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: kAppSmallPadding.h),
              
              // Description
              Text(
                'We sent a 6-digit verification code to ${widget.contactNumber}. Please enter it below to continue.',
                style: textTheme.bodyMedium?.copyWith(
                  color: MAIZE_ACCENT.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: kAppLargePadding.h * 2),
              
              // Code input field
              Text(
                l10n.verification_code,
                style: textTheme.bodyLarge?.copyWith(
                  color: MAIZE_ACCENT,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              SizedBox(height: kAppSmallPadding.h),
              
              TextFormField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium?.copyWith(
                  color: MAIZE_ACCENT,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8.0,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(kAppMediumPadding.r),
                    borderSide: const BorderSide(color: MAIZE_PRIMARY),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(kAppMediumPadding.r),
                    borderSide: const BorderSide(color: MAIZE_PRIMARY),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(kAppMediumPadding.r),
                    borderSide: const BorderSide(color: MAIZE_PRIMARY, width: 2),
                  ),
                  hintText: '000000',
                  hintStyle: textTheme.headlineMedium?.copyWith(
                    color: MAIZE_ACCENT.withOpacity(0.3),
                    letterSpacing: 8.0,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: kAppMediumPadding.w,
                    vertical: kAppLargePadding.h,
                  ),
                ),
                maxLength: 6,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.verification_code_required;
                  }
                  if (value.length != 6) {
                    return 'Verification code must be 6 digits';
                  }
                  if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                    return 'Invalid verification code format';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (value.length == 6) {
                    _verifyCode();
                  }
                },
              ),
              
              SizedBox(height: kAppLargePadding.h),
              
              // Verify button
              CustomButton(
                text: _isLoading ? 'Verifying...' : 'Verify',
                onPressed: _handleVerifyCode,
              ),
              
              SizedBox(height: kAppMediumPadding.h),
              
              // Resend code button
              Center(
                child: TextButton(
                  onPressed: _resendCountdown > 0 || _isResending ? null : _resendCode,
                  child: Text(
                    _isResending
                        ? 'Resending...'
                        : _resendCountdown > 0
                            ? 'Resend in $_resendCountdown seconds'
                            : 'Resend Code',
                    style: textTheme.bodyMedium?.copyWith(
                      color: _resendCountdown > 0 || _isResending
                          ? MAIZE_ACCENT.withOpacity(0.5)
                          : MAIZE_PRIMARY,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Help text
              Text(
                'Didn\'t receive a code? Check your SMS messages or try resending.',
                style: textTheme.bodySmall?.copyWith(
                  color: MAIZE_ACCENT.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
