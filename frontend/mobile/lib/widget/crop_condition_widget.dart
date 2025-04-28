import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'package:maize_watch/custom/constants.dart';
import 'package:maize_watch/custom/custom_font.dart';
import 'package:maize_watch/model/sensor_data_model.dart';

class CropConditionWidget extends StatelessWidget {
  final SensorReading? currentData;

  const CropConditionWidget({super.key, required this.currentData});

  @override
  Widget build(BuildContext context) {
    String message = "No Data";
    IconData icon = FlutterIcons.smile_circle_ant;
    Color iconColor = Colors.green;

    if (currentData != null) {
      final temp = currentData!.measurements.temperature;
      final moisture = currentData!.measurements.soilMoisture;
      final humidity = currentData!.measurements.humidity;
      final light = currentData!.measurements.lightLevel;

      double avg = (temp + moisture + humidity + light) / 4;

      if (avg >= 70) {
        message = "Your crops are in excellent condition.";
        icon = FlutterIcons.smile_circle_ant;
        iconColor = Colors.green;
      } else if (avg >= 40) {
        message = "Your crops are doing okay. Monitor closely.";
        icon = FlutterIcons.meho_ant;
        iconColor = Colors.orange;
      } else {
        message = "Crops are at risk! Immediate action needed.";
        icon = FlutterIcons.frown_ant;
        iconColor = Colors.red;
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
            Icon(
              icon,
              color: iconColor,
              size: 35,
            ),
          ],
        ),
        SizedBox(width: ScreenUtil().setWidth(15)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomFont(
                text: message,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              SizedBox(height: ScreenUtil().setHeight(2)),
              const CustomFont(
                text: 'Stay updated with your farm!',
                fontSize: 15,
              ),
            ],
          ),
        ),
      ],
    );
  }
}