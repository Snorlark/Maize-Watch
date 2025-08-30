import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/colors.dart';
import '../../../../generated/l10n.dart';

class CornRegistrationProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const CornRegistrationProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final stepLabels = [
      S.of(context).step1_title,
      S.of(context).step2_title,
      S.of(context).step3_title,
      S.of(context).step4_title,
      S.of(context).step5_title,
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: kAppMediumPadding,
        vertical: kAppMediumPadding,
      ),
      child: Column(
        children: [
          // Step labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: stepLabels.map((label) {
              return SizedBox(
                width: 60.w,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: MAIZE_ACCENT,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
          ),
          verticalSpace(8),
          // Progress bar
          SizedBox(
            height: 20.h,
            child: Stack(
              children: [
                // Background track
                Container(
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: MAIZE_PRIMARY_LIGHT,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                  margin: EdgeInsets.only(top: 8.h),
                ),
                // Filled progress
                Container(
                  height: 4.h,
                  width: MediaQuery.of(context).size.width *
                      ((currentStep - 1) / totalSteps) *
                      0.85, // Adjust for padding
                  decoration: BoxDecoration(
                    color: MAIZE_ACCENT,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                  margin: EdgeInsets.only(top: 8.h, left: 10.w),
                ),
                // Step indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(totalSteps, (index) {
                    final stepNum = index + 1;
                    final isCompleted = currentStep >= stepNum;
                    
                    return Container(
                      width: 20.w,
                      height: 20.h,
                      decoration: BoxDecoration(
                        color: isCompleted ? MAIZE_ACCENT : MAIZE_PRIMARY_LIGHT,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted ? MAIZE_ACCENT : Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$stepNum',
                          style: TextStyle(
                            color: isCompleted ? Colors.white : MAIZE_ACCENT,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
