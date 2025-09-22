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
                Icons.notifications,
                color: MAIZE_ACCENT,
                size: 24.sp,
              ),
              SizedBox(width: kAppSmallGap),
              Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: MAIZE_ACCENT,
                ),
              ),
            ],
          ),
          SizedBox(height: kAppMediumPadding),
          _buildSwitchTile(
            'Enable Notifications',
            'Receive alerts for farm updates',
            isNotificationsEnabled,
            onNotificationToggled,
            Icons.notifications_active,
          ),
          if (isNotificationsEnabled) ...[
            SizedBox(height: kAppSmallPadding),
            Padding(
              padding: EdgeInsets.only(left: 40.w),
              child: _buildSwitchTile(
                'Vibration Only',
                'Only vibrate without sound',
                isVibrationOnly,
                onVibrationOnlyToggled,
                Icons.vibration,
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
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: value ? MAIZE_ACCENT : Colors.grey,
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
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: MAIZE_ACCENT,
        ),
      ],
    );
  }
}
