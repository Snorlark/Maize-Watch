import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/theme/colors.dart';
import 'package:mobile/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:mobile/features/settings/presentation/bloc/settings_event.dart';
import 'package:mobile/features/settings/presentation/bloc/settings_state.dart';
import 'package:mobile/features/settings/presentation/widgets/sensor_status_widget.dart';
import 'package:mobile/features/settings/presentation/widgets/notification_settings_widget.dart';
import 'package:mobile/features/settings/presentation/widgets/language_settings_widget.dart';
import 'package:mobile/features/settings/presentation/widgets/help_section_widget.dart';
import 'package:mobile/features/settings/presentation/widgets/faq_section_widget.dart';
import 'package:mobile/features/settings/domain/entities/settings_entity.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    print("🔧 SettingsScreen: initState - Loading settings...");
    // Load settings immediately
    context.read<SettingsBloc>().add(const LoadSettings());
  }

  @override
  Widget build(BuildContext context) {
    print("🔧 SettingsScreen: build method called");
    return Scaffold(
      backgroundColor: MAIZE_PRIMARY_LIGHT,
      extendBodyBehindAppBar: true,
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is SettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is SettingsUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SettingsLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: MAIZE_ACCENT),
                  SizedBox(height: 16.h),
                  Text(
                    'Loading settings...',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: MAIZE_ACCENT,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is SettingsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.sp,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    state.message,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<SettingsBloc>().add(const RefreshSettings());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Get settings data
          SettingsEntity? settings;
          SensorStatusEntity? sensorStatus;
          
          if (state is SettingsLoaded) {
            settings = state.settings;
            sensorStatus = state.sensorStatus;
          } else if (state is SettingsUpdating) {
            settings = state.settings;
            sensorStatus = state.sensorStatus;
          } else if (state is SettingsUpdated) {
            settings = state.settings;
            sensorStatus = state.sensorStatus;
          }

          return Column(
            children: [
              // Header section with background
              _buildHeaderSection(context),
              
              // Main content area
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: kAppSmallPadding),
                  padding: EdgeInsets.only(
                    left: kAppMediumPadding, 
                    right: kAppMediumPadding, 
                    top: kAppMediumPadding, 
                    bottom: kAppLargePadding,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Sensor Status
                        SensorStatusWidget(
                          ldrSensor: sensorStatus?.ldrSensor ?? false,
                          phLevelSensor: sensorStatus?.phLevelSensor ?? false,
                          tempAndHumidSensor: sensorStatus?.tempAndHumidSensor ?? false,
                          soilLevelSensor: sensorStatus?.soilLevelSensor ?? false,
                        ),
                        SizedBox(height: kAppMediumPadding),

                        // Notification Settings
                        NotificationSettingsWidget(
                          isNotificationsEnabled: settings?.notificationsEnabled ?? true,
                          isVibrationOnly: settings?.vibrationOnly ?? false,
                          onNotificationToggled: (value) {
                            context.read<SettingsBloc>().add(
                              UpdateNotificationSettings(
                                enabled: value,
                                vibrationOnly: settings?.vibrationOnly ?? false,
                              ),
                            );
                          },
                          onVibrationOnlyToggled: (value) {
                            context.read<SettingsBloc>().add(
                              UpdateNotificationSettings(
                                enabled: settings?.notificationsEnabled ?? true,
                                vibrationOnly: value,
                              ),
                            );
                          },
                        ),
                        SizedBox(height: kAppMediumPadding),

                        // Language Settings
                        LanguageSettingsWidget(
                          currentLanguage: settings?.language ?? 'en',
                          onLanguageChanged: (language) {
                            context.read<SettingsBloc>().add(UpdateLanguage(language));
                          },
                        ),
                        SizedBox(height: kAppMediumPadding),

                        // Help Section
                        HelpSectionWidget(
                          isExpanded: false,
                          onToggle: () {
                            // Implementation for help section
                          },
                        ),
                        SizedBox(height: kAppSmallPadding),

                        // FAQ Section
                        FAQSectionWidget(
                          isExpanded: false,
                          onToggle: () {
                            // Implementation for FAQ section
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      height: 200.h,
      padding: EdgeInsets.all(kAppMediumPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
        image: const DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status bar spacing
          SizedBox(height: 40.h),
          
          // Back button and title
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
              ),
              SizedBox(width: kAppSmallGap),
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                width: 50.w,
                height: 50.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 28.sp,
                ),
              ),
            ],
          ),
          
          Spacer(),
          
          // Settings summary
          Text(
            'Manage your app preferences and device settings',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}