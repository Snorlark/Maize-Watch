import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/theme/colors.dart';

class NotificationSettingsWidget extends StatelessWidget {
  final bool isNotificationsEnabled;
  final bool isVibrationOnly;
  final ValueChanged<bool> onNotificationToggled;
  final ValueChanged<bool> onVibrationOnlyToggled;

  const NotificationSettingsWidget({
    super.key,
    required this.isNotificationsEnabled,
    required this.isVibrationOnly,
    required this.onNotificationToggled,
    required this.onVibrationOnlyToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(kAppMediumPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            MAIZE_PRIMARY_LIGHT.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: MAIZE_ACCENT.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: MAIZE_ACCENT.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: MAIZE_ACCENT.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.notifications,
                  color: MAIZE_ACCENT,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: kAppSmallGap),
              Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: MAIZE_ACCENT,
                ),
              ),
            ],
          ),
          SizedBox(height: kAppMediumPadding),
          _buildSwitchTile(
            'Enable Notifications',
            'Get alerts for farm updates, weather warnings, and sensor issues',
            isNotificationsEnabled,
            onNotificationToggled,
            Icons.notifications_active,
            Colors.green,
          ),
          if (isNotificationsEnabled) ...[
            SizedBox(height: kAppSmallPadding),
            Padding(
              padding: EdgeInsets.only(left: 20.w),
              child: _buildSwitchTile(
                'Vibration Only',
                'Silent notifications with vibration only',
                isVibrationOnly,
                onVibrationOnlyToggled,
                Icons.vibration,
                Colors.orange,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: EdgeInsets.all(kAppSmallPadding),
      decoration: BoxDecoration(
        color: value ? iconColor.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: value ? iconColor.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: value ? iconColor.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: value ? iconColor : Colors.grey,
              size: 18.sp,
            ),
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
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.9,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: iconColor,
              activeTrackColor: iconColor.withOpacity(0.3),
              inactiveThumbColor: Colors.grey[400],
              inactiveTrackColor: Colors.grey[200],
            ),
          ),
        ],
      ),
    );
  }
}
