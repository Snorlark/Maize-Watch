import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maize_watch/custom/custom_font.dart';

class SensorStatusWidget extends StatelessWidget {
  final bool ldrSensor;
  final bool phLevelSensor;
  final bool tempAndHumidSensor;
  final bool soilLevelSensor;

  const SensorStatusWidget({
    super.key,
    required this.ldrSensor,
    required this.phLevelSensor,
    required this.tempAndHumidSensor,
    required this.soilLevelSensor,
  });

  Widget sensorRow(String label, bool isActive) {
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
              text: label,
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
        CustomFont(
          text: isActive ? 'On' : 'Off',
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
              text: "Sensors",
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            SizedBox(height: ScreenUtil().setHeight(15)),
            sensorRow("Light Dependent Resistor", ldrSensor),
            SizedBox(height: ScreenUtil().setHeight(10)),
            sensorRow("PH Level of Soil", phLevelSensor),
            SizedBox(height: ScreenUtil().setHeight(10)),
            sensorRow("Temperature and Humidity", tempAndHumidSensor),
            SizedBox(height: ScreenUtil().setHeight(10)),
            sensorRow("Soil Moisture", soilLevelSensor),
          ],
        ),
      ),
    );
  }
}
