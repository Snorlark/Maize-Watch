import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/theme/colors.dart';
import 'package:mobile/core/services/notification_service.dart';
import 'package:mobile/features/settings/presentation/bloc/sensor_status_bloc.dart';

import '../../../../core/widgets/custom_button.dart';

class SensorStatusScreen extends StatefulWidget {
  const SensorStatusScreen({super.key});

  @override
  State<SensorStatusScreen> createState() => _SensorStatusScreenState();
}

class _SensorStatusScreenState extends State<SensorStatusScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _hasShownSleepModeNotification = false;

  @override
  void initState() {
    super.initState();
    // Initialize notification service
    _notificationService.initialize();
    // Load sensor status when screen initializes
    context.read<SensorStatusBloc>().add(const GetSensorStatusEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: MAIZE_PRIMARY_LIGHT,
      appBar: AppBar(        
        backgroundColor: MAIZE_PRIMARY_LIGHT,
        leading: IconButton(onPressed: () {
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back, color: MAIZE_ACCENT,)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildSensorStatusSection(),
            ),
            _buildRefreshButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorStatusSection() {
    return Padding(
      padding: EdgeInsets.all(kAppMediumPadding),
      child: SingleChildScrollView(
        child: BlocBuilder<SensorStatusBloc, SensorStatusState>(
          builder: (context, state) {
            if (state.status == SensorStatusStatus.loading) {
              return Center(
                child: CircularProgressIndicator(
                  color: MAIZE_ACCENT,
                ),
              );
            }
            
            if (state.status == SensorStatusStatus.failure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.sp,
                      color: Colors.red,
                    ),
                    verticalSpace(kAppMediumGap),
                    Text(
                      'Failed to load sensor status',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.red,
                      ),
                    ),
                    verticalSpace(kAppSmallGap),
                    Text(
                      state.message ?? 'Please try again',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }
            
            if (state.status == SensorStatusStatus.success && state.sensorStatus != null) {
              final isSleepMode = state.sensorStatus!['sleepMode'] ?? false;
              
              // Show sleep mode notification if not already shown
              if (isSleepMode && !_hasShownSleepModeNotification) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _notificationService.showSensorSleepModeNotification();
                  setState(() {
                    _hasShownSleepModeNotification = true;
                  });
                });
              } else if (!isSleepMode) {
                // Reset notification flag when not in sleep mode
                _hasShownSleepModeNotification = false;
              }
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [                 
                  Text(
                    'Sensor Status',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  verticalSpace(5.h),
                  Text(
                    isSleepMode 
                      ? 'Sensors are in sleep mode (8pm-3am PH time)'
                      : 'Monitor the condition of your sensors',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSleepMode ? Colors.orange : null,
                    ),
                  ),   
                  verticalSpace(kAppSmallGap),
                  
                  // Status checking indicator
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(kAppMediumPadding),
                    decoration: BoxDecoration(
                      color: MAIZE_ACCENT.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: MAIZE_ACCENT.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: MAIZE_ACCENT,
                          size: 20.sp,
                        ),
                        SizedBox(width: kAppSmallGap),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status Check',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: MAIZE_ACCENT,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Checking if sensors are actively sending data to ThingSpeak',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: MAIZE_ACCENT.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  verticalSpace(kAppSmallGap),
                  
                  // Sleep mode indicator
                  if (isSleepMode) ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(kAppMediumPadding),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                    children: [
                          Icon(
                            Icons.bedtime,
                            color: Colors.orange,
                            size: 24.sp,
                      ),
                      SizedBox(width: kAppSmallGap),
                      Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sleep Mode Active',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Sensors are sleeping from 8pm to 3am PH time',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                         verticalSpace(kAppSmallGap),
                  ],
                  
                  // Temperature Sensor
                  _buildSensorStatusItem(
                    title: 'Temperature Sensor',
                    
                    isActive: state.sensorStatus!['temperature'] ?? false,
                    icon: Icons.thermostat,
                  ),
                  verticalSpace(kAppSmallGap),
                  
                  // Humidity Sensor
                  _buildSensorStatusItem(
                    title: 'Humidity Sensor',
                    
                    isActive: state.sensorStatus!['humidity'] ?? false,
                    icon: Icons.water_drop,
                  ),
                  verticalSpace(kAppSmallGap),
                  
                  // Soil Moisture Sensor
                  _buildSensorStatusItem(
                    title: 'Soil Moisture Sensor',
                    
                    isActive: state.sensorStatus!['soilMoisture'] ?? false,
                    icon: Icons.grass,
                  ),
                  verticalSpace(kAppSmallGap),
                  
                  // Soil pH Sensor
                  _buildSensorStatusItem(
                    title: 'Soil pH Sensor',
                   
                    isActive: state.sensorStatus!['soilPh'] ?? false,
                    icon: Icons.science,
                   ),
                  verticalSpace(kAppSmallGap),
                  
                  // Light Intensity Sensor
                  _buildSensorStatusItem(
                    title: 'Light Intensity Sensor',
                    
                    isActive: state.sensorStatus!['lightIntensity'] ?? false,
                    icon: Icons.light_mode,
                   ),
                  verticalSpace(kAppSmallGap),
                  
                  // Status Legend
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(kAppSmallPadding),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status Legend',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Container(
                              width: 12.w,
                              height: 12.h,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Active: Sensor is sending data to ThingSpeak',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Container(
                              width: 12.w,
                              height: 12.h,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'Inactive: Sensor is offline or not sending data',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  verticalSpace(kAppSmallGap / 2),
                ],
              );
            }
            
            return Center(
              child: CircularProgressIndicator(
                color: MAIZE_ACCENT,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSensorStatusItem({
    required String title,
    required bool isActive,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(kAppMediumPadding),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: isActive 
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Icon(
                  icon,
                  color: isActive ? Colors.green : Colors.red,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: kAppSmallGap),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: isActive ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Status explanation
          Row(
            children: [
              Icon(
                isActive ? Icons.check_circle : Icons.cancel,
                color: isActive ? Colors.green : Colors.red,
                size: 16.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  isActive 
                    ? 'Sensor is actively sending data to ThingSpeak'
                    : 'Sensor is not sending data or offline',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isActive ? Colors.green.shade700 : Colors.red.shade700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshButton() {
    return Padding(
      padding: EdgeInsets.all(kAppMediumPadding),
              child: CustomButton(
                onPressed: () {
          context.read<SensorStatusBloc>().add(const GetSensorStatusEvent());
        },
        text: 'Refresh Status',
      ),
    );
  }
}