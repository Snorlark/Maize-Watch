import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/theme/colors.dart';

class SyncSettingsWidget extends StatefulWidget {
  final bool autoSync;
  final int syncInterval;
  final ValueChanged<bool> onAutoSyncChanged;
  final ValueChanged<int> onSyncIntervalChanged;

  const SyncSettingsWidget({
    super.key,
    required this.autoSync,
    required this.syncInterval,
    required this.onAutoSyncChanged,
    required this.onSyncIntervalChanged,
  });

  @override
  State<SyncSettingsWidget> createState() => _SyncSettingsWidgetState();
}

class _SyncSettingsWidgetState extends State<SyncSettingsWidget> {
  final List<int> syncIntervals = [5, 15, 30, 60, 120]; // in minutes

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
                Icons.sync,
                color: MAIZE_ACCENT,
                size: 24.sp,
              ),
              SizedBox(width: kAppSmallGap),
              Text(
                'Sync Settings',
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
            'Auto Sync',
            'Automatically sync data with server',
            widget.autoSync,
            widget.onAutoSyncChanged,
            Icons.sync,
          ),
          if (widget.autoSync) ...[
            SizedBox(height: kAppMediumPadding),
            Text(
              'Sync Interval',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: kAppSmallPadding),
            _buildIntervalSelector(),
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

  Widget _buildIntervalSelector() {
    return Container(
      height: 50.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: syncIntervals.length,
        itemBuilder: (context, index) {
          final interval = syncIntervals[index];
          final isSelected = widget.syncInterval == interval;
          
          return GestureDetector(
            onTap: () {
              widget.onSyncIntervalChanged(interval);
            },
            child: Container(
              margin: EdgeInsets.only(right: kAppSmallGap),
              padding: EdgeInsets.symmetric(horizontal: kAppMediumPadding),
              decoration: BoxDecoration(
                color: isSelected ? MAIZE_ACCENT : Colors.grey[100],
                borderRadius: BorderRadius.circular(25.r),
                border: Border.all(
                  color: isSelected ? MAIZE_ACCENT : Colors.grey[300]!,
                ),
              ),
              child: Center(
                child: Text(
                  _formatInterval(interval),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatInterval(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      return '${hours}h';
    }
  }
}
