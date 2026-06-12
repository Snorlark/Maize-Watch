import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/theme/colors.dart';

class PrivacySettingsWidget extends StatelessWidget {
  final bool dataCollectionEnabled;
  final bool analyticsEnabled;
  final ValueChanged<bool> onDataCollectionChanged;
  final ValueChanged<bool> onAnalyticsChanged;

  const PrivacySettingsWidget({
    super.key,
    required this.dataCollectionEnabled,
    required this.analyticsEnabled,
    required this.onDataCollectionChanged,
    required this.onAnalyticsChanged,
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
                Icons.privacy_tip,
                color: MAIZE_ACCENT,
                size: 24.sp,
              ),
              SizedBox(width: kAppSmallGap),
              Text(
                'Privacy & Data',
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
            'Data Collection',
            'Allow collection of farm data for analysis',
            dataCollectionEnabled,
            onDataCollectionChanged,
            Icons.data_usage,
          ),
          SizedBox(height: kAppSmallPadding),
          _buildSwitchTile(
            'Analytics',
            'Help improve the app with usage analytics',
            analyticsEnabled,
            onAnalyticsChanged,
            Icons.analytics,
          ),
          SizedBox(height: kAppMediumPadding),
          Container(
            padding: EdgeInsets.all(kAppSmallPadding),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue[600],
                  size: 16.sp,
                ),
                SizedBox(width: kAppSmallGap),
                Expanded(
                  child: Text(
                    'Your data is encrypted and stored securely. We never share your personal information.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
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
