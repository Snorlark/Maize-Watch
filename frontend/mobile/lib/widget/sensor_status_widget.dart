import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maize_watch/custom/custom_font.dart';
import 'package:maize_watch/services/translation_service.dart';

class SensorStatusWidget extends StatelessWidget {
  final bool ldrSensor;
  final bool phLevelSensor;
  final bool tempAndHumidSensor;
  final bool soilLevelSensor;
  final TranslationService translationService;

  const SensorStatusWidget({
    super.key,
    required this.ldrSensor,
    required this.phLevelSensor,
    required this.tempAndHumidSensor,
    required this.soilLevelSensor,
    required this.translationService,
  });

  Widget sensorRow(String labelKey, bool isActive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? Colors.green : Colors.red,
              ),
            ),
            SizedBox(width: ScreenUtil().setWidth(10)),
            CustomFont(
              text: translationService.translate(labelKey),
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
        CustomFont(
          text: translationService.translate(isActive ? 'on' : 'off'),
          color: isActive ? Colors.green : Colors.red,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: ScreenUtil().setWidth(10),
          horizontal: ScreenUtil().setHeight(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomFont(
              text: translationService.translate('sensors'),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            SizedBox(height: ScreenUtil().setHeight(15)),
            sensorRow('ldr_sensor', ldrSensor),
            SizedBox(height: ScreenUtil().setHeight(10)),
            sensorRow("ph_sensor", phLevelSensor),
            SizedBox(height: ScreenUtil().setHeight(10)),
            sensorRow("temp_humid_sensor", tempAndHumidSensor),
            SizedBox(height: ScreenUtil().setHeight(10)),
            sensorRow("soil_moisture_sensor", soilLevelSensor),
          ],
        ),
      ),
    );
  }
}
