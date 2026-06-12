// features/live_monitoring/presentation/widgets/dashboard_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/sensor_reading.dart';
import '../../../../generated/l10n.dart';

class DashboardWidget extends StatelessWidget {
  final List<SensorReading> readings;

  const DashboardWidget({super.key, required this.readings});

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return Center(child: Text(S.of(context).no_sensor_data_available));
    }

    final currentReading = readings.first;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Current readings cards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10.h,
            crossAxisSpacing: 10.w,
            childAspectRatio: 1.2,
            children: [
              _buildSensorCard(
                S.of(context).temperature,
                '${currentReading.temperature.toStringAsFixed(1)}°C',
                Icons.thermostat,
                currentReading.isTemperatureOptimal
                    ? Colors.green
                    : Colors.orange,
              ),
              _buildSensorCard(
                S.of(context).humidity,
                '${currentReading.humidity.toStringAsFixed(1)}%',
                Icons.water_drop,
                currentReading.isHumidityOptimal ? Colors.blue : Colors.orange,
              ),
              _buildSensorCard(
                S.of(context).soil_moisture,
                '${currentReading.soilMoisture.toStringAsFixed(1)}%',
                Icons.grass,
                currentReading.isSoilMoistureOptimal
                    ? Colors.brown
                    : Colors.orange,
              ),
              _buildSensorCard(
                S.of(context).light,
                '${currentReading.lightIntensity.toStringAsFixed(1)}%',
                Icons.wb_sunny,
                currentReading.isLightOptimal ? Colors.yellow : Colors.orange,
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Health status card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).crop_health_status,
                  style: TextTheme.of(context).bodyMedium?.copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Container(
                      width: 12.w,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: _getHealthColor(currentReading.cropHealthStatus),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      currentReading.cropHealthStatus,
                      style: TextTheme.of(context).bodyMedium?.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32.sp),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]!),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Color _getHealthColor(String status) {
    switch (status) {
      case 'Excellent':
        return Colors.green;
      case 'Good':
        return Colors.lightGreen;
      case 'Fair':
        return Colors.yellow;
      case 'Poor':
        return Colors.orange;
      case 'Critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
