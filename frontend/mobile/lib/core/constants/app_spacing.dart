import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final double kAppLargePadding = 24.w;
final double kAppMediumPadding = 16.w;
final double kAppSmallPadding = 8.w;

final double kAppLargeGap = 32.h;
final double kAppMediumGap = 16.h;
final double kAppSmallGap = 8.h;

Widget verticalSpace(double height) => SizedBox(height: height.h);

Widget horizontalSpace(double width) => SizedBox(width: width.w);

final Widget kVerticalMediumGap = verticalSpace(kAppMediumGap);

final Widget kHorizontalMediumGap = horizontalSpace(kAppMediumGap);
