import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/colors.dart';

class CornRegistrationAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBackPressed;

  const CornRegistrationAppBar({
    super.key,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: MAIZE_BOTTOM_OVERLAY,
      elevation: 0,
      leading: onBackPressed != null
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: MAIZE_ACCENT,
                size: 24.sp,
              ),
              onPressed: onBackPressed,
            )
          : null,
      automaticallyImplyLeading: onBackPressed == null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56.h);
}
