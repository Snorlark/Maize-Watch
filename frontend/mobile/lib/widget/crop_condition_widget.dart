    import 'package:flutter/material.dart';
    import 'package:flutter_screenutil/flutter_screenutil.dart';
    import 'package:icons_flutter/icons_flutter.dart';
import 'package:maize_watch/custom/constants.dart';
    import 'package:maize_watch/custom/custom_font.dart';
    import 'package:maize_watch/model/sensor_data_model.dart';
    import 'package:flutter_gen/gen_l10n/app_localizations.dart';

    class CropConditionWidget extends StatelessWidget {
      final SensorReading? currentData;
      final bool includeUpdated;
      final bool isEmphasized;

      const CropConditionWidget({
        super.key, 
        required this.currentData,
        required this.includeUpdated,
        this.isEmphasized = true
      });

      @override
      Widget build(BuildContext context) {

        final localizations = AppLocalizations.of(context)!;

        String messageKey = localizations.no_data;
        IconData icon = FlutterIcons.smile_circle_ant;
        Color iconColor = Colors.green;

        if (currentData != null) {
          final temp = currentData!.temperature;
          final moisture = currentData!.soilMoisture;
          final humidity = currentData!.humidity;
          final light = currentData!.lightIntensity;

          double avg = (temp + moisture + humidity + light) / 4;

          if (avg >= 70) {
            messageKey = localizations.crop_excellent;
            icon = FlutterIcons.smile_circle_ant;
            iconColor = Colors.green;
          } else if (avg >= 40) {
            messageKey = localizations.crop_okay;
            icon = FlutterIcons.meho_ant;
            iconColor = Colors.orange;
          } else {
            messageKey = localizations.crop_risk;
            icon = FlutterIcons.frown_ant;
            iconColor = Colors.red;
          }
        }

        // Wrap with a Container with constraints to prevent overflow
        return Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 30.w, // Adjusted for ScreenUtil
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon container
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 42.r, // Increased from 36.r
                    height: 42.r, // Increased from 36.r
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  Icon(
                    icon,
                    color: iconColor,
                    size: 32.r, // Increased from 26.r
                  ),
                ],
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomFont(
                      text: messageKey,
                      fontWeight: FontWeight.w700,
                      fontSize: 18.sp, // Increased from 15.sp
                      color: MAIZE_PRIMARY_LIGHT
                    ),
                    SizedBox(height: 4.h), // Increased from 2.h
                    if (includeUpdated)
                      CustomFont(
                        text: localizations.stay_updated,
                        fontSize: 14.sp, // Increased from 13.sp
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade700,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    }