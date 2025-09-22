import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/theme/colors.dart';

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
                Icons.sensors,
                color: MAIZE_ACCENT,
                size: 24.sp,
              ),
              SizedBox(width: kAppSmallGap),
              Text(
                'Sensor Status',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: MAIZE_ACCENT,
                ),
              ),
            ],
          ),
          SizedBox(height: kAppMediumPadding),
          _buildSensorRow(
            'Light Sensor (LDR)',
            ldrSensor,
            Icons.wb_sunny,
          ),
          SizedBox(height: kAppSmallPadding),
          _buildSensorRow(
            'pH Level Sensor',
            phLevelSensor,
            Icons.science,
          ),
          SizedBox(height: kAppSmallPadding),
          _buildSensorRow(
            'Temperature & Humidity',
            tempAndHumidSensor,
            Icons.thermostat,
          ),
          SizedBox(height: kAppSmallPadding),
          _buildSensorRow(
            'Soil Moisture Sensor',
            soilLevelSensor,
            Icons.water_drop,
          ),
        ],
      ),
    );
  }

  Widget _buildSensorRow(String name, bool isConnected, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: isConnected ? Colors.green : Colors.grey,
          size: 20.sp,
        ),
        SizedBox(width: kAppSmallGap),
        Expanded(
          child: Text(
            name,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          width: 12.w,
          height: 12.h,
          decoration: BoxDecoration(
            color: isConnected ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: kAppSmallGap),
        Text(
          isConnected ? 'Connected' : 'Disconnected',
          style: TextStyle(
            fontSize: 12.sp,
            color: isConnected ? Colors.green : Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
