import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/colors.dart';
import '../../../../generated/l10n.dart';

class FarmRegistrationSuccessScreen extends StatelessWidget {
  final String farmName;
  final String fieldName;
  final VoidCallback onContinue;

  const FarmRegistrationSuccessScreen({
    super.key,
    required this.farmName,
    required this.fieldName,
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
                  Icons.agriculture,
                  size: 80.sp,
                  color: MAIZE_PRIMARY,
                ),
              ),

              SizedBox(height: 32.h),

              // Success Title
              Text(
                S.current.farm_registration_successful,
                style: textTheme.headlineMedium?.copyWith(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: MAIZE_ACCENT,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 16.h),

              // Success Message
              Text(
                S.current.congratulations_field_registered(fieldName, farmName),
                style: textTheme.bodyLarge?.copyWith(
                  fontSize: 16.sp,
                  color: MAIZE_ACCENT.withOpacity(0.8),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 32.h),

              // Features List
              _buildFeatureItem(
                Icons.sensors,
                S.current.monitor_crop_health,
              ),
              SizedBox(height: 16.h),
              _buildFeatureItem(
                Icons.analytics,
                S.current.get_real_time_analytics,
              ),
              SizedBox(height: 16.h),
              _buildFeatureItem(
                Icons.notifications,
                S.current.receive_alerts_recommendations,
              ),

              SizedBox(height: 48.h),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MAIZE_PRIMARY,
                    foregroundColor: MAIZE_PRIMARY_LIGHT,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    S.current.continue_to_dashboard,
                    style: TextStyle(
                      fontSize: 16.sp,
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

  Widget _buildFeatureItem(IconData icon, String text) {
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
