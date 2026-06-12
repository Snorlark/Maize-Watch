import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/sensor_reading.dart';
import '../../../farm/domain/entities/farm.dart';

class CornProgressWidget extends StatelessWidget {
  final Farm farm;
  final SensorReading? currentData;
  final List<SensorReading> historicalData;

  const CornProgressWidget({
    super.key,
    required this.farm,
    this.currentData,
    this.historicalData = const [],
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Farm info card
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
                  farm.farmName,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                // Display field information from new structure
                if (farm.fields.isNotEmpty) ...[
                  Text(
                    'Field: ${farm.fields.first.fieldName}',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Growth Stage: ${farm.fields.first.growthStage}',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Planted: ${farm.fields.first.plantingDate.day}/${farm.fields.first.plantingDate.month}/${farm.fields.first.plantingDate.year}',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                ] else ...[
                  Text(
                    'No fields configured',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Current conditions card - get data from farm sensors
          _buildCurrentConditionsFromFarm(),

          SizedBox(height: 16.h),

          // Growth progress from field data
          _buildGrowthProgressFromField(),
        ],
      ),
    );
  }

  Widget _buildCurrentConditionsFromFarm() {
    if (farm.fields.isEmpty || farm.fields.first.sensors.isEmpty) {
      return Container(
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
              'Current Conditions',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'No sensors configured for this farm',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    final sensor = farm.fields.first.sensors.first;
    final readings = sensor.readings;

    return Container(
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
            'Current Conditions',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Sensor: ${sensor.sensorName} (${sensor.deviceID})',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildConditionItem(
                  'Temperature',
                  '${readings.temperature.toStringAsFixed(1)}°C',
                  Icons.thermostat,
                  _getTemperatureColor(readings.temperature),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildConditionItem(
                  'Humidity',
                  '${readings.humidity.toStringAsFixed(1)}%',
                  Icons.water_drop,
                  _getHumidityColor(readings.humidity),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildConditionItem(
                  'Soil Moisture',
                  '${readings.soilMoisture.toStringAsFixed(1)}%',
                  Icons.grass,
                  _getSoilMoistureColor(readings.soilMoisture),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildConditionItem(
                  'Light',
                  '${readings.lightIntensity.toStringAsFixed(0)}',
                  Icons.wb_sunny,
                  _getLightColor(readings.lightIntensity),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildConditionItem(
                  'Soil pH',
                  '${readings.soilPh.toStringAsFixed(1)}',
                  Icons.science,
                  _getPhColor(readings.soilPh),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildConditionItem(
                  'Soil Type',
                  sensor.soilType,
                  Icons.terrain,
                  Colors.brown,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthProgressFromField() {
    if (farm.fields.isEmpty) {
      return Container(
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
              'Corn Growth Progress',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'No fields configured',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    final field = farm.fields.first;
    final daysSincePlanting = DateTime.now().difference(field.plantingDate).inDays;
    final growthStageProgress = _getGrowthStageProgress(field.growthStage);

    return Container(
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
            'Corn Growth Progress',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Stage: ${field.growthStage}',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
              Text(
                '$daysSincePlanting days',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          LinearProgressIndicator(
            value: growthStageProgress,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(_getGrowthStageColor(field.growthStage)),
          ),
          SizedBox(height: 8.h),
          Text(
            _getGrowthStageDescription(field.growthStage),
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Color _getTemperatureColor(double temp) {
    if (temp >= 20 && temp <= 30) return Colors.green;
    if (temp >= 15 && temp <= 35) return Colors.orange;
    return Colors.red;
  }

  Color _getHumidityColor(double humidity) {
    if (humidity >= 60 && humidity <= 70) return Colors.blue;
    if (humidity >= 50 && humidity <= 80) return Colors.orange;
    return Colors.red;
  }

  Color _getSoilMoistureColor(double moisture) {
    if (moisture >= 40 && moisture <= 60) return Colors.brown;
    if (moisture >= 30 && moisture <= 70) return Colors.orange;
    return Colors.red;
  }

  Color _getLightColor(double light) {
    if (light >= 800 && light <= 1200) return Colors.yellow;
    if (light >= 600 && light <= 1400) return Colors.orange;
    return Colors.red;
  }

  Color _getPhColor(double ph) {
    if (ph >= 6.0 && ph <= 7.0) return Colors.green;
    if (ph >= 5.5 && ph <= 7.5) return Colors.orange;
    return Colors.red;
  }

  double _getGrowthStageProgress(String stage) {
    switch (stage) {
      case 'VE': return 0.16; // Emergence
      case 'V3': return 0.33; // 3rd leaf
      case 'V8': return 0.50; // 8th leaf
      case 'VT': return 0.66; // Tasseling
      case 'R1': return 0.83; // Silking
      case 'R6': return 1.0;  // Maturity
      default: return 0.0;
    }
  }

  Color _getGrowthStageColor(String stage) {
    switch (stage) {
      case 'VE': return Colors.lightGreen;
      case 'V3': return Colors.green;
      case 'V8': return Colors.green[700]!;
      case 'VT': return Colors.orange;
      case 'R1': return Colors.deepOrange;
      case 'R6': return Colors.brown;
      default: return Colors.grey;
    }
  }

  String _getGrowthStageDescription(String stage) {
    switch (stage) {
      case 'VE': return 'Emergence stage (0-7 days) - Seedling emerging from soil';
      case 'V3': return '3rd leaf stage (8-21 days) - Early vegetative growth';
      case 'V8': return '8th leaf stage (22-42 days) - Rapid vegetative growth';
      case 'VT': return 'Tasseling stage (43-65 days) - Reproductive development';
      case 'R1': return 'Silking stage (66-85 days) - Pollination period';
      case 'R6': return 'Maturity stage (86+ days) - Ready for harvest';
      default: return 'Unknown growth stage';
    }
  }

  Widget _buildConditionItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24.sp),
        SizedBox(height: 4.h),
        Text(
          title,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
