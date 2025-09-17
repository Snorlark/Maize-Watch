import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/language_toggle.dart';

class CornRegistrationAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback? onBackPressed;
  final bool showBackButton;

  const CornRegistrationAppBar({
    super.key,
    this.onBackPressed,
    this.showBackButton = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: MAIZE_BOTTOM_OVERLAY,
      elevation: 0,
      leading:
          showBackButton
              ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              )
              : null,
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: const LanguageToggle(color_toggle: MAIZE_ACCENT),
        ),
      ],
    );
  }
}
