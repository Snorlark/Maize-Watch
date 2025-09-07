// features/live_monitoring/presentation/widgets/crop_condition_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mobile/generated/l10n.dart';

import '../../domain/entities/sensor_reading.dart';

class CropConditionWidget extends StatelessWidget {
  final SensorReading? currentData;
  final bool includeUpdated;

  const CropConditionWidget({
    super.key,
    this.currentData,
    this.includeUpdated = true,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = S.of(context);

    String messageKey = "no_data";
    IconData icon = Icons.help_outline;
    Color color = Colors.grey;

    if (currentData != null) {
      switch (currentData!.cropHealthStatus) {
        case 'Excellent':
          messageKey = "crop_excellent";
          icon = Icons.sentiment_very_satisfied;
          color = Colors.green;
          break;
        case 'Good':
          messageKey = "crop_good";
          icon = Icons.sentiment_satisfied;
          color = Colors.lightGreen;
          break;
        case 'Fair':
          messageKey = "crop_okay";
          icon = Icons.sentiment_neutral;
          color = Colors.orange;
          break;
        case 'Poor':
          messageKey = "crop_poor";
          icon = Icons.sentiment_dissatisfied;
          color = Colors.deepOrange;
          break;
        case 'Critical':
          messageKey = "crop_risk";
          icon = Icons.sentiment_very_dissatisfied;
          color = Colors.red;
          break;
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 24.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      _getLocalizedMessage(context, messageKey),
                      style: TextTheme.of(context).bodyMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              if (includeUpdated && currentData != null)
                Padding(
                  padding: EdgeInsets.only(top: 4.h, left: 32.w),
                  child: Text(
                    'updated: ${_formatTime(currentData!.timestamp)}',
                    style: TextTheme.of(context).bodyMedium?.copyWith(
                      color: Colors.white70,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _getLocalizedMessage(BuildContext context, String messageKey) {
    final localizations = S.of(context);
    switch (messageKey) {
      case "crop_excellent":
        return localizations.crop_excellent ?? "Crops are thriving!";
      case "crop_good":
        return "Crops are doing well";
      case "crop_okay":
        return localizations.crop_okay ?? "Crops need attention";
      case "crop_poor":
        return "Crops need immediate care";
      case "crop_risk":
        return localizations.crop_risk ?? "Crops at risk!";
      default:
        return "No data available";
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return "Just now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else {
      return "${difference.inDays}d ago";
    }
  }
}
