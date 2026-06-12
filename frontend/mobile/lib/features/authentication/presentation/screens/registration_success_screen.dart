import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/colors.dart';
import '../../../../generated/l10n.dart';

class RegistrationSuccessScreen extends StatelessWidget {
  final String userName;
  final VoidCallback onContinue;

  const RegistrationSuccessScreen({
    super.key,
    required this.userName,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: MAIZE_BOTTOM_OVERLAY,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(kAppLargePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon
              Container(
                width: 120.w,
                height: 120.h,
                decoration: BoxDecoration(
                  color: MAIZE_PRIMARY.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 80.sp,
                  color: MAIZE_PRIMARY,
                ),
              ),

              SizedBox(height: 32.h),

              // Success Title
              Text(
                S.of(context).user_registration_successful,
                style: textTheme.headlineMedium?.copyWith(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: MAIZE_ACCENT,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 16.h),

              Text(
                S.of(context).setup_farm_data_message,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 16.sp,
                  height: 1.5,
                  color: MAIZE_ACCENT,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 24.h),

              // Description
              Container(
                padding: EdgeInsets.all(kAppMediumPadding),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(kAppMediumPadding.r),
                  border: Border.all(color: MAIZE_PRIMARY.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    // Features List
                    _buildFeatureItem(
                      icon: Icons.agriculture,
                      text: 'Register your farm details',
                    ),
                    SizedBox(height: 8.h),
                    _buildFeatureItem(
                      icon: Icons.sensors,
                      text: 'Connect IoT device',
                    ),
                    SizedBox(height: 8.h),
                    _buildFeatureItem(
                      icon: Icons.analytics,
                      text: 'Monitor crop growth stages',
                    ),
                  ],
                ),
              ),

              Spacer(),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MAIZE_PRIMARY,
                    foregroundColor: MAIZE_PRIMARY_LIGHT,
                    elevation: 2,
                    shadowColor: MAIZE_PRIMARY.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kAppMediumPadding.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: kAppLargePadding.w,
                      vertical: kAppMediumPadding.h,
                    ),
                  ),
                  child: Text(
                    S.of(context).continue_to_field_registration,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: MAIZE_PRIMARY),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: MAIZE_ACCENT,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
