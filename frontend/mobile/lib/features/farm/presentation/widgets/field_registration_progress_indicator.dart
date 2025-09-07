import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/colors.dart';

class FieldRegistrationProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const FieldRegistrationProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final stepInfo = [
      {'title': 'Name', 'icon': Icons.agriculture},
      {'title': 'Planting', 'icon': Icons.calendar_today},
      {'title': 'Device', 'icon': Icons.device_hub},
      {'title': 'Confirm', 'icon': Icons.check_circle},
    ];

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: kAppSmallPadding),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;

              return Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Background line (full width)
                  Positioned(
                    top: 22.w - 1.h, // centers line relative to 44.w circle
                    child: Container(
                      width: availableWidth,
                      height: 2.h,
                      color: Colors.grey.shade300,
                    ),
                  ),

                  // Animated progress line
                  Positioned(
                    top: 22.w - 1.h,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      width:
                          availableWidth *
                          ((currentStep - 1) / (totalSteps - 1)),
                      height: 2.h,
                      color: MAIZE_ACCENT,
                    ),
                  ),

                  // Step indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(totalSteps, (index) {
                      final stepNumber = index + 1;
                      final isCompleted = currentStep > stepNumber;
                      final isActive = currentStep == stepNumber;
                      final step = stepInfo[index];

                      return Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            width: 44.w,
                            height: 44.w,
                            decoration: BoxDecoration(
                              color:
                                  isCompleted
                                      ? MAIZE_ACCENT
                                      : Colors.grey.shade100,
                              shape: BoxShape.circle,
                              border:
                                  isActive
                                      ? Border.all(
                                        color: MAIZE_ACCENT,
                                        width: 1.5.w,
                                      )
                                      : null,
                            ),
                            child:
                                isCompleted
                                    ? Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 20.sp,
                                    )
                                    : Icon(
                                      step['icon'] as IconData,
                                      color:
                                          isActive
                                              ? MAIZE_ACCENT
                                              : Colors.grey.shade400,
                                      size: 18.sp,
                                    ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            step['title'] as String,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color:
                                  isCompleted || isActive
                                      ? MAIZE_ACCENT
                                      : Colors.grey.shade500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
