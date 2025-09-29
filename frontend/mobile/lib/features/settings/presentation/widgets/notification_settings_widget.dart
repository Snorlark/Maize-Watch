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
      width: double.infinity,
      padding: EdgeInsets.all(kAppMediumPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.notifications,
                color: MAIZE_ACCENT,
                size: 20.sp,
              ),
              SizedBox(width: kAppSmallGap),
              Text(
                'Notification Settings',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: MAIZE_ACCENT,
                ),
              ),
            ],
          ),
          SizedBox(height: kAppMediumPadding),
          
          // Notification Options
          _buildNotificationOption(
            context,
            'Enable Notifications',
            'Get alerts for farm updates, weather warnings, and sensor issues',
            isNotificationsEnabled,
            onNotificationToggled,
            Icons.notifications_active,
            Colors.green,
          ),
          SizedBox(height: kAppSmallGap),
          
          if (isNotificationsEnabled) ...[
            _buildNotificationOption(
              context,
              'Vibration Only',
              'Silent notifications with vibration only',
              isVibrationOnly,
              onVibrationOnlyToggled,
              Icons.vibration,
              Colors.orange,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationOption(
    BuildContext context,
    String title,
    String subtitle,
    bool isEnabled,
    ValueChanged<bool> onChanged,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: kAppSmallGap),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            print('🔧 NotificationSettingsWidget: $title toggled to ${!isEnabled}');
            onChanged(!isEnabled);
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: kAppMediumPadding,
              vertical: kAppSmallPadding,
            ),
            decoration: BoxDecoration(
              color: isEnabled ? color.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isEnabled ? color : Colors.grey.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isEnabled ? color : Colors.grey,
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
                          fontWeight: isEnabled ? FontWeight.w600 : FontWeight.w500,
                          color: isEnabled ? color : Colors.black87,
                        ),
                      ),
                      SizedBox(height: 2.h),
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
                  value: isEnabled,
                  onChanged: (value) {
                    onChanged(value);
                    Navigator.pop(context);
                  },
                  activeColor: color,
                  activeTrackColor: color.withOpacity(0.3),
                  inactiveThumbColor: Colors.grey[400],
                  inactiveTrackColor: Colors.grey[200],
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
