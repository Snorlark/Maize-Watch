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
            maxWidth: MediaQuery.of(context).size.width - 30, // Adjust as needed
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, // Use minimum space needed
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Fixed size for icon container to prevent layout issues
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  Icon(
                    icon,
                    color: iconColor,
                    size: 30.r,
                  ),
                ],
              ),
              SizedBox(width: 10.w), // Use a smaller fixed width
              Flexible(
                // Use Flexible instead of Expanded to allow the text to wrap
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomFont(
                      text: messageKey,
                      fontWeight: FontWeight.bold,
                      color: MAIZE_PRIMARY_LIGHT
                    ),
                    SizedBox(height: 2.h),

                    (includeUpdated) ?
                    CustomFont(
                      text: localizations.stay_updated,
                      fontSize: 14, // Slightly reduced to help with overflow
                    ) :
                    Container()
                  ],
                ),
              ),
            ],
          ),
        );
      }
    }