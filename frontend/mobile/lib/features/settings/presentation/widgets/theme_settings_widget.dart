import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/theme/colors.dart';

class ThemeSettingsWidget extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const ThemeSettingsWidget({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(kAppMediumPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.palette,
                color: MAIZE_ACCENT,
                size: 24.sp,
              ),
              SizedBox(width: kAppSmallGap),
              Text(
                'Theme',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: MAIZE_ACCENT,
                ),
              ),
            ],
          ),
          SizedBox(height: kAppMediumPadding),
          _buildThemeOption(
            'Light Mode',
            'Use light theme',
            false,
            Icons.light_mode,
          ),
          SizedBox(height: kAppSmallPadding),
          _buildThemeOption(
            'Dark Mode',
            'Use dark theme',
            true,
            Icons.dark_mode,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    String title,
    String subtitle,
    bool isDark,
    IconData icon,
  ) {
    final isSelected = isDarkMode == isDark;
    
    return GestureDetector(
      onTap: () {
        onThemeChanged(isDark);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: kAppSmallPadding),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? MAIZE_ACCENT : Colors.grey,
              size: 20.sp,
            ),
            SizedBox(width: kAppSmallGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: MAIZE_ACCENT,
                size: 20.sp,
              )
            else
              Icon(
                Icons.radio_button_unchecked,
                color: Colors.grey,
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }
}
