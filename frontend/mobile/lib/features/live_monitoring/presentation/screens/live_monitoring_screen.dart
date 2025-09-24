import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/features/live_monitoring/domain/usecases/get_localized_greeting.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/services/notification_service.dart';
import '../../../farm/presentation/bloc/farm_bloc.dart';
import '../../../farm/domain/entities/farm.dart';
import '../bloc/monitoring_bloc.dart';
import '../widgets/farm_detail_widget.dart';
import '../widgets/growth_stage_lottie.dart';
import '../../../authentication/presentation/bloc/authentication_bloc.dart';

class LiveMonitoringScreen extends StatefulWidget {
  const LiveMonitoringScreen({super.key});

  @override
  State<LiveMonitoringScreen> createState() => _LiveMonitoringScreenState();
}

class _LiveMonitoringScreenState extends State<LiveMonitoringScreen>
    with SingleTickerProviderStateMixin {
  Farm? _selectedFarm;
  Field? _selectedField;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final NotificationService _notificationService = NotificationService();
  Set<String> _notifiedPrescriptions = {};

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Initialize notification service
    _notificationService.initialize();

    // Load initial data
    _loadData();
    _animationController.forward();
  }

  void _loadData() {
    // Only load data if not already loaded
    final farmState = context.read<FarmBloc>().state;
    final monitoringState = context.read<MonitoringBloc>().state;
    
    // Load user farms only if not already loaded
    if (farmState is! FarmsLoaded) {
      final authState = context.read<AuthenticationBloc>().state;
      if (authState.status == AuthenticationStatus.authenticated &&
          authState.user != null) {
        final user = authState.user;
        if (user != null) {
          context.read<FarmBloc>().add(GetUserFarmsEvent(userId: user.id));
        }
      }
    }
    
    // Load latest sensor readings only if not already loaded
    if (monitoringState.latestReadings.isEmpty && !monitoringState.isLoading) {
      context.read<MonitoringBloc>().add(LoadLatestReadingsEvent());
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _goBackToMap() {
    _animationController.reverse().then((_) {
      setState(() {
        _selectedFarm = null;
        _selectedField = null;
      });
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.white,
        body: _selectedFarm != null ? _buildFarmDetailView() : _buildHomeView(),
      ),
    );
  }

  Widget _buildHomeView() {
    return Stack(
      children: [
        // Main scrollable content
        SingleChildScrollView(
          child: Column(
            children: [
              // Weather information overlay
              _buildWeatherOverlay(),

              // Farming tasks/schedule cards
              _buildTaskCards(),

              // Farm fields section
              _buildFarmFieldsSection(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, authState) {
        final user = authState.user;
        final location =
            '${user?.address['municipality']}, ${user?.address['province']}';

        return Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: kAppSmallGap,
                vertical: kAppSmallGap,
              ),
              decoration: BoxDecoration(
                color: MAIZE_ACCENT.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min, // <-- key to wrapping!
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, color: MAIZE_ACCENT, size: 18.sp),
                  horizontalSpace(8),
                  Flexible(
                    child: Text(
                      location,
                      style: TextTheme.of(
                        context,
                      ).bodySmall?.copyWith(color: MAIZE_ACCENT),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWeatherOverlay() {
    return Container(
      height: 250.h, // Add explicit height constraint
      margin: EdgeInsets.only(bottom: kAppSmallGap),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        image: const DecorationImage(
          image: AssetImage('assets/images/background.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(
          kAppMediumPadding,
        ), // Add padding instead of using margin on child
        child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, authState) {
            final user = authState.user;
            return BlocBuilder<MonitoringBloc, MonitoringState>(
              builder: (context, monitoringState) {
                // Use analytics weather data if available, otherwise fallback to sensor data
                final weatherData = monitoringState.weatherData;
                final latestReading =
                    monitoringState.latestReadings.isNotEmpty
                        ? monitoringState.latestReadings.first
                        : null;

                // Try to get weather data from analytics first
                double temperature = 16.0;
                double humidity = 72.5;
                double windSpeed = 5.2;
                String weatherCondition = 'Partly Cloudy';
                IconData weatherIcon = Icons.cloud;
                String weatherDescription = 'Partly cloudy';

                // Check if we have analytics data with weather information
                final analyticsData = monitoringState.farmAnalytics;
                if (analyticsData != null && analyticsData['predictive'] != null) {
                  final predictive = analyticsData['predictive'] as Map<String, dynamic>;
                  if (predictive['weather_forecast'] != null) {
                    final weatherForecast = predictive['weather_forecast'] as Map<String, dynamic>;
                    if (weatherForecast['current'] != null) {
                      final currentWeather = weatherForecast['current'] as Map<String, dynamic>;
                      temperature = (currentWeather['temperature'] as num?)?.toDouble() ?? 16.0;
                      humidity = (currentWeather['humidity'] as num?)?.toDouble() ?? 72.5;
                      windSpeed = (currentWeather['wind_speed'] as num?)?.toDouble() ?? 5.2;
                      weatherCondition = currentWeather['condition'] as String? ?? 'Partly Cloudy';
                      weatherDescription = currentWeather['description'] as String? ?? 'Partly cloudy';
                      weatherIcon = _getWeatherIcon(weatherCondition);
                      
                      print('🎯 UI using analytics weather data: temp=${temperature}°C, humidity=${humidity}%');
                    }
                  }
                } else if (weatherData != null) {
                  // Fallback to weather API data
                  temperature = weatherData.temperature;
                  humidity = weatherData.humidity;
                  windSpeed = weatherData.windSpeed;
                  weatherCondition = weatherData.condition;
                  weatherDescription = weatherData.description;
                  weatherIcon = _getWeatherIcon(weatherData.condition);
                  
                  print('🎯 UI using weather API data: temp=${temperature}°C, humidity=${humidity}%');
                } else if (latestReading != null) {
                  // Fallback to sensor data
                  temperature = latestReading.temperature;
                  humidity = latestReading.humidity;
                  windSpeed = _calculateWindSpeed(latestReading.lightIntensity);
                  weatherCondition = _getWeatherCondition(
                    temperature,
                    humidity,
                    latestReading.lightIntensity,
                  );
                  weatherDescription = weatherCondition;
                  weatherIcon = _getWeatherIcon(weatherCondition);
                  
                  print('🎯 UI using sensor data: temp=${temperature}°C, humidity=${humidity}%');
                } else {
                  print('⚠️ UI using default fallback data - no data available');
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with location and profile
                    _buildHeader(),
                    Spacer(),
                    Text(
                      '${GetLocalizedGreeting(context)}, ${user?.fullName}',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    verticalSpace(8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${temperature.toStringAsFixed(0)}°C',
                          style: TextStyle(
                            fontSize: 72.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 0.9,
                          ),
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            verticalSpace(8),
                            Row(
                              children: [
                                Icon(
                                  weatherIcon,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                                horizontalSpace(8),
                                Text(
                                  weatherDescription,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            verticalSpace(4),
                            Text(
                              _getCurrentTimeString(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    verticalSpace(16),
                    Row(
                      children: [
                        _buildWeatherStat(
                          '${windSpeed.toStringAsFixed(1)} km/h',
                          Icons.air,
                        ),
                        SizedBox(width: kAppSmallGap),
                        _buildWeatherStat(
                          '${humidity.toStringAsFixed(1)}%',
                          Icons.water_drop,
                        ),
                        // Add pressure if available from analytics
                        ...(() {
                          if (analyticsData != null && 
                              analyticsData['predictive'] != null &&
                              analyticsData['predictive']['weather_forecast'] != null &&
                              analyticsData['predictive']['weather_forecast']['current'] != null) {
                            final currentWeather = analyticsData['predictive']['weather_forecast']['current'] as Map<String, dynamic>;
                            if (currentWeather['pressure'] != null) {
                              return [
                                SizedBox(width: kAppSmallGap),
                                _buildWeatherStat(
                                  '${(currentWeather['pressure'] as num).toStringAsFixed(0)} hPa',
                                  Icons.speed,
                                ),
                              ];
                            }
                          }
                          return <Widget>[];
                        })(),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildWeatherStat(String value, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18.sp),
          horizontalSpace(6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCards() {
    return BlocListener<FarmBloc, FarmState>(
      listener: (context, farmState) {
        // Load farm analytics when farms are loaded
        if (farmState is FarmsLoaded && farmState.farms.isNotEmpty) {
          final farmId = farmState.farms.first.id;
          if (farmId != null) {
            context.read<MonitoringBloc>().add(
              LoadFarmAnalyticsEvent(farmId: farmId),
            );
          }
        }
      },
      child: BlocBuilder<FarmBloc, FarmState>(
        builder: (context, farmState) {
          return BlocBuilder<MonitoringBloc, MonitoringState>(
            builder: (context, monitoringState) {
              // Generate dynamic tasks based on farm data and sensor readings
              final tasks = _generateDynamicTasks(farmState, monitoringState);

              return SizedBox(
                height: 140.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index < tasks.length - 1 ? kAppSmallGap : 0,                        
                      ),
                      child: _buildTaskCard(
                        time: task['time'],
                        title: task['title'],
                        status: task['status'],
                        color: task['color'],
                        isActive: task['isActive'],
                        taskData: task,
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTaskCard({
    required String time,
    required String title,
    required String status,
    required Color color,
    required bool isActive,
    Map<String, dynamic>? taskData,
  }) {
    return GestureDetector(
      onTap: () {
        if (taskData != null) {
          Navigator.pushNamed(
            context,
            '/detailed-prescription',
            arguments: taskData,
          );
        }
      },
      child: Container(
        width: 160.w,
        padding: EdgeInsets.all(kAppMediumPadding),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16.sp,
                  color: isActive ? MAIZE_PRIMARY_LIGHT : Colors.grey[600],
                ),
                SizedBox(width: kAppSmallGap),
                Text(
                  time,
                  style: TextTheme.of(context).bodySmall?.copyWith(
                    color: isActive ? MAIZE_PRIMARY_LIGHT : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: kAppSmallGap),
            Text(
              title,
              style: TextTheme.of(context).bodyMedium?.copyWith(
                color: isActive ? MAIZE_PRIMARY_LIGHT : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: isActive ? Colors.white : Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildFarmFieldsSection() {
    return Container(
      margin: EdgeInsets.only(top: kAppSmallPadding),
      padding: EdgeInsets.only(left: kAppMediumPadding, right: kAppMediumPadding, top: kAppMediumPadding, bottom: kAppLargePadding),
      decoration: BoxDecoration(
        color: MAIZE_PRIMARY_LIGHT,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: BlocBuilder<FarmBloc, FarmState>(
        builder: (context, farmState) {
          return BlocBuilder<MonitoringBloc, MonitoringState>(
            builder: (context, monitoringState) {
              final farmName =
                  farmState is FarmsLoaded && farmState.farms.isNotEmpty
                      ? farmState.farms.first.farmName
                      : 'My Farm';
              final farms =
                  farmState is FarmsLoaded ? farmState.farms : <Farm>[];
              final fieldCount = farms.fold<int>(
                0,
                (total, farm) => total + farm.fields.length,
              );

              // Load analytics and weather data for the first farm if available
              if (farms.isNotEmpty) {
                final firstFarmId = farms.first.id ?? '';
                if (monitoringState.farmAnalytics == null) {
                  context.read<MonitoringBloc>().add(
                    LoadFarmAnalyticsEvent(farmId: firstFarmId),
                  );
                }
                // Load weather data for the first farm
                if (monitoringState.weatherData == null) {
                  context.read<MonitoringBloc>().add(
                    LoadWeatherDataEvent(farmId: firstFarmId),
                  );
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            farmName,
                            style: TextTheme.of(
                              context,
                            ).bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          verticalSpace(1),
                          Text(
                            '$fieldCount field${fieldCount != 1 ? 's' : ''} registered',
                            style: TextTheme.of(
                              context,
                            ).bodySmall?.copyWith(fontSize: 12.sp),
                          ),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/field-registration');
                        },
                        icon: Icon(
                          Icons.add,
                          size: 16.sp,
                          color: MAIZE_PRIMARY_LIGHT,
                        ),
                        label: Text(
                          'Add',
                          style: TextTheme.of(
                            context,
                          ).bodySmall?.copyWith(color: MAIZE_PRIMARY_LIGHT),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MAIZE_PRIMARY,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: kAppSmallPadding),
                  if (farmState is FarmsLoaded && farmState.farms.isNotEmpty)
                    Column(
                      children: _buildFieldCards(
                        farmState.farms,
                        monitoringState,
                      ),
                    )
                  else
                    _buildFarmFieldCard(null, monitoringState),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFarmFieldCard(Farm? farm, MonitoringState? monitoringState) {
    return GestureDetector(
      onTap: () {
        if (farm != null) {
          setState(() {
            _selectedFarm = farm;
            _selectedField = farm.fields.isNotEmpty ? farm.fields.first : null;
          });
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: Colors.grey[100],
              ),
              child: farm?.fields.isNotEmpty == true
                  ? GrowthStageLottie(
                      growthStage: farm!.fields.first.growthStage,
                      width: 50.w,
                      height: 50.h,
                      fit: BoxFit.contain,
                    )
                  : Icon(
                      Icons.agriculture,
                      size: 24.sp,
                      color: Colors.grey[600],
                    ),
            ),
            horizontalSpace(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    farm?.farmName ?? 'Corn Field 1',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  verticalSpace(8),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8BC34A),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'Towards Harvest',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  verticalSpace(8),
                  Row(
                    children: [
                      Icon(Icons.grass, size: 14.sp, color: Colors.grey[600]),
                      horizontalSpace(4),
                      Text(
                        _getFarmGrowthStatus(farm, monitoringState),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      horizontalSpace(16),
                      Icon(
                        Icons.calendar_today,
                        size: 14.sp,
                        color: Colors.grey[600],
                      ),
                      horizontalSpace(4),
                      Text(
                        _getFarmActivityCount(farm, monitoringState),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 24.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmDetailView() {
    return BlocBuilder<MonitoringBloc, MonitoringState>(
      builder: (context, monitoringState) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: FarmDetailWidget(
            farm:
                _selectedFarm ??
                Farm(
                  userId: '',
                  farmName: 'Default Farm',
                  location: '',
                  fields: [],
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                ),
            sensorReadings: monitoringState.latestReadings,
            onBack: _goBackToMap,
            selectedField: _selectedField,
            sensors: [],
          ),
        );
      },
    );
  }

  // Helper methods for weather calculations
  String _getWeatherCondition(
    double temperature,
    double humidity,
    double lightIntensity,
  ) {
    // Determine weather condition based on sensor readings
    if (lightIntensity > 80) {
      return 'Sunny';
    } else if (lightIntensity > 60) {
      return 'Partly Cloudy';
    } else if (lightIntensity > 40) {
      return 'Cloudy';
    } else if (humidity > 85) {
      return 'Rainy';
    } else {
      return 'Overcast';
    }
  }

  IconData _getWeatherIcon(String condition) {
    switch (condition) {
      case 'Sunny':
        return Icons.wb_sunny;
      case 'Partly Cloudy':
        return Icons.cloud;
      case 'Cloudy':
        return Icons.cloud_outlined;
      case 'Rainy':
        return Icons.grain;
      case 'Overcast':
        return Icons.cloud_queue;
      default:
        return Icons.cloud;
    }
  }

  double _calculateWindSpeed(double lightIntensity) {
    // Approximate wind speed based on light intensity
    // Higher light intensity might indicate clearer skies and potentially more wind
    return (lightIntensity / 20) + 1.0; // Range: 1.0 - 5.0 km/h
  }

  String _getCurrentTimeString() {
    final now = DateTime.now();
    final timeFormat =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final dateFormat = '${months[now.month - 1]} ${now.day}';
    return '$timeFormat | $dateFormat';
  }

  // Generate dynamic tasks based on analytics_v2 recommendations
  List<Map<String, dynamic>> _generateDynamicTasks(
    FarmState farmState,
    MonitoringState monitoringState,
  ) {
    final tasks = <Map<String, dynamic>>[];
    final now = DateTime.now();

    if (farmState is FarmsLoaded && farmState.farms.isNotEmpty) {
      // Try to get analytics recommendations from monitoring state
      final analyticsData = monitoringState.farmAnalytics;

      // Debug: Print analytics data status
      print(
        '🔍 Analytics Data Status: ${analyticsData != null ? "Available" : "NULL"}',
      );
      if (analyticsData != null) {
        print('🔍 Analytics Keys: ${analyticsData.keys.toList()}');
        print('🔍 Has Prescriptive: ${analyticsData['prescriptive'] != null}');
        print('🔍 Has Descriptive: ${analyticsData['descriptive'] != null}');
        print('🔍 Has Predictive: ${analyticsData['predictive'] != null}');
        
        // Debug prescriptive data
        if (analyticsData['prescriptive'] != null) {
          final prescriptive = analyticsData['prescriptive'] as Map<String, dynamic>;
          print('🔍 Prescriptive Keys: ${prescriptive.keys.toList()}');
          print('🔍 Prescriptive Data: $prescriptive');
        }
      }

      List<dynamic> recommendations = [];

      if (analyticsData != null) {
        // The complete analytics endpoint returns data directly with prescriptive key
        if (analyticsData['prescriptive'] != null) {
          final prescriptive = analyticsData['prescriptive'] as Map<String, dynamic>;
          recommendations = prescriptive['recommendations'] as List<dynamic>? ?? [];
          print('🔍 Found prescriptive recommendations: ${recommendations.length}');
        }

        print('🔍 Final Recommendations Count: ${recommendations.length}');
      }

      if (recommendations.isNotEmpty) {
        // Show notifications for new high-priority prescriptions
        _showPrescriptionNotifications(recommendations);
        
        // Convert analytics recommendations to task cards
        for (int i = 0; i < recommendations.length && i < 4; i++) {
          final rec = recommendations[i] as Map<String, dynamic>;
          print('🔍 Processing recommendation $i: $rec');
          
          final urgency = rec['urgency'] as String? ?? 'LOW';
          final timeline = rec['timeline'] as String? ?? '1 day';
          final action = rec['action'] as String? ?? 'Check farm';
          final details = rec['details'] as String? ?? '';
          final category = rec['category'] as String? ?? 'general';
          
          // Extract field-specific information
          final fieldName = rec['field_name'] as String? ?? 'Unknown Field';
          final soilType = rec['soil_type'] as String? ?? 'Unknown';
          final growthStage = rec['growth_stage'] as String? ?? 'Unknown';
          final fieldId = rec['field_id'] as String?;
          final parameter = rec['parameter'] as String? ?? 'general';
          
          print('🔍 Extracted field data - Name: $fieldName, Soil: $soilType, Stage: $growthStage');

          // Format the title to show the actual action with better readability
          String formattedTitle = _formatRecommendationTitle(action, category);

          // Use details for status if available, otherwise use urgency
          String status =
              details.isNotEmpty
                  ? _formatDetailsForStatus(details, urgency, timeline)
                  : _mapUrgencyToStatus(urgency);

          // Format timeline for display instead of calculated time
          String displayTime = _formatTimelineForDisplay(timeline);

          tasks.add({
            'time': displayTime,
            'title': formattedTitle,
            'status': status,
            'color': _getColorForUrgency(urgency),
            'isActive': urgency == 'HIGH' || urgency == 'URGENT',
            'details': details, // Store full details for potential expansion
            'category': category,
            'fieldName': fieldName, // ✅ Add field-specific data
            'soilType': soilType, // ✅ Add field-specific data
            'growthStage': growthStage, // ✅ Add field-specific data
            'fieldId': fieldId, // ✅ Add field-specific data
            'parameter': parameter, // ✅ Add parameter info
            'urgency': urgency, // ✅ Add urgency for detailed view
          });
        }
      } else if (monitoringState.isLoading) {
        // Show loading indicator when analytics is being processed
        tasks.add({
          'time':
              '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
          'title': 'Loading\nAnalytics...',
          'status': 'Processing',
          'color': Colors.grey[300],
          'isActive': false,
        });
      } else {
        // Show proper no-data message instead of fallback tasks
        tasks.add({
          'time':
              '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
          'title': 'No Tasks\nfor Today',
          'status': 'All Clear',
          'color': Colors.green[300],
          'isActive': false,
        });
      }
    } else {
      // Default tasks when no farm data
      tasks.addAll([
        {
          'time': '${now.hour.toString().padLeft(2, '0')}:30',
          'title': 'Setup\nFarm',
          'status': 'Required',
          'color': MAIZE_PRIMARY,
          'isActive': true,
        },
        {
          'time': '${(now.hour + 1).toString().padLeft(2, '0')}:00',
          'title': 'Add\nSensors',
          'status': 'Pending',
          'color': Colors.white,
          'isActive': false,
        },
      ]);
    }

    return tasks;
  }

  // Helper methods for analytics-based task generation
  String _formatRecommendationTitle(String action, String category) {
    // Extract the main action from the details
    String cleanAction =
        action.replaceAll('URGENT:', '').replaceAll('HIGH:', '').trim();

    // Format based on category for better readability
    switch (category) {
      case 'temperature_control':
        return 'Temperature\nControl';
      case 'humidity_control':
        return 'Humidity\nControl';
      case 'lighting':
        return 'Lighting\nAdjustment';
      case 'water_management':
        return 'Water\nManagement';
      case 'fertilization':
        return 'Apply\nFertilizer';
      default:
        // For other categories, use the action but keep it short
        if (cleanAction.length > 20) {
          final words = cleanAction.split(' ');
          if (words.length > 2) {
            final midPoint = (words.length / 2).ceil();
            final firstLine = words.take(midPoint).join(' ');
            final secondLine = words.skip(midPoint).join(' ');
            return '$firstLine\n$secondLine';
          }
        }
        return cleanAction.length > 15
            ? '${cleanAction.substring(0, 15)}...'
            : cleanAction;
    }
  }

  String _formatDetailsForStatus(
    String details,
    String urgency,
    String timeline,
  ) {
    // Create a comprehensive status that includes urgency and timeline
    String urgencyPrefix = '';
    switch (urgency.toUpperCase()) {
      case 'URGENT':
        urgencyPrefix = 'URGENT';
        break;
      case 'HIGH':
        urgencyPrefix = 'HIGH';
        break;
      case 'MEDIUM':
        urgencyPrefix = 'MEDIUM';
        break;
      default:
        urgencyPrefix = urgency.toUpperCase();
    }

    // Format timeline for display
    String timelineFormatted = timeline.toLowerCase().replaceAll('next ', '');
    if (timelineFormatted == 'today') {
      timelineFormatted = 'Today';
    } else if (timelineFormatted.contains('day')) {
      timelineFormatted = timelineFormatted.replaceAll('1-2 days', '1-2d');
    } else if (timelineFormatted.contains('week')) {
      timelineFormatted = timelineFormatted.replaceAll('weeks', 'w');
    }

    return '$urgencyPrefix • $timelineFormatted';
  }

  String _formatTimelineForDisplay(String timeline) {
    final lowerTimeline = timeline.toLowerCase();

    if (lowerTimeline == 'today') {
      return 'Now';
    } else if (lowerTimeline.contains('next') &&
        lowerTimeline.contains('1-2 days')) {
      return '1-2d';
    } else if (lowerTimeline.contains('next') &&
        lowerTimeline.contains('day')) {
      final match = RegExp(r'(\d+)').firstMatch(lowerTimeline);
      final days = match?.group(1) ?? '1';
      return '${days}d';
    } else if (lowerTimeline.contains('week')) {
      final match = RegExp(r'(\d+)').firstMatch(lowerTimeline);
      final weeks = match?.group(1) ?? '1';
      return '${weeks}w';
    } else if (lowerTimeline.contains('hour')) {
      final match = RegExp(r'(\d+)').firstMatch(lowerTimeline);
      final hours = match?.group(1) ?? '1';
      return '${hours}h';
    }

    return timeline.length > 8 ? '${timeline.substring(0, 8)}...' : timeline;
  }

  String _mapUrgencyToStatus(String urgency) {
    switch (urgency.toUpperCase()) {
      case 'HIGH':
      case 'URGENT':
        return 'Urgent';
      case 'MEDIUM':
        return 'Important';
      case 'LOW':
      default:
        return 'Scheduled';
    }
  }

  Color _getColorForUrgency(String urgency) {
    switch (urgency.toUpperCase()) {
      case 'HIGH':
        return Colors.orange[600]!;
      case 'URGENT':
        return Colors.red[600]!;
      case 'MEDIUM':
        return MAIZE_PRIMARY;
      case 'LOW':
      default:
        return Colors.white;
    }
  }

  // Get farm growth status based on analytics and sensor data
  String _getFarmGrowthStatus(Farm? farm, MonitoringState? monitoringState) {
    // Try to get growth stage from analytics first
    if (monitoringState?.farmAnalytics != null) {
      final analyticsData = monitoringState!.farmAnalytics!;
      if (analyticsData['descriptive'] != null) {
        final descriptive = analyticsData['descriptive'] as Map<String, dynamic>;
        final growthStage = descriptive['growth_stage'] as String? ?? 'VE';
        final daysSincePlanting = descriptive['daysSincePlanting'] as int? ?? 0;
        
        // Calculate growth percentage based on stage (more accurate mapping)
        final growthPercentages = {
          'VE': 5,
          'V2': 15,
          'V3': 25,
          'V4': 35,
          'V5': 45,
          'V6': 55,
          'V7': 65,
          'V8': 70,
          'VT': 75,
          'R1': 80,
          'R2': 85,
          'R3': 90,
          'R4': 92,
          'R5': 95,
          'R6': 100,
        };

        final percentage = growthPercentages[growthStage] ?? 10;
        return 'Growth: $percentage% (${daysSincePlanting}d)';
      }
    }

    // Fallback to farm field data
    if (farm?.fields.isNotEmpty == true) {
      final field = farm!.fields.first;
      final growthStage = field.growthStage;

      // Calculate growth percentage based on stage
      final growthPercentages = {
        'VE': 10,
        'V3': 25,
        'V8': 50,
        'VT': 75,
        'R1': 85,
        'R6': 95,
      };

      final percentage = growthPercentages[growthStage] ?? 10;
      return 'Growth: $percentage%';
    }

    return 'Growth: 0%';
  }

  // Get farm activity count based on analytics
  String _getFarmActivityCount(Farm? farm, MonitoringState? monitoringState) {
    if (monitoringState?.farmAnalytics != null) {
      final analytics = monitoringState!.farmAnalytics!;
      
      // Get sensor count from farm fields
      int sensorCount = 0;
      if (farm?.fields.isNotEmpty == true) {
        for (final field in farm!.fields) {
          sensorCount += field.sensors.length;
        }
      }
      
      // Get recommendations count from prescriptive analytics
      int recommendationsCount = 0;
      if (analytics['prescriptive'] != null) {
        final prescriptive = analytics['prescriptive'] as Map<String, dynamic>;
        recommendationsCount = prescriptive['total_recommendations'] as int? ?? 0;
      }
      
      // Get alerts count if available
      int alertCount = 0;
      if (analytics['predictive'] != null) {
        final predictive = analytics['predictive'] as Map<String, dynamic>;
        if (predictive['risk_assessment'] != null) {
          final riskAssessment = predictive['risk_assessment'] as Map<String, dynamic>;
          final riskLevel = riskAssessment['overall_risk_level'] as String? ?? 'low';
          if (riskLevel == 'high' || riskLevel == 'urgent') {
            alertCount = 1;
          }
        }
      }
      
      final totalActivities = sensorCount + recommendationsCount + alertCount;
      return '$totalActivities Activities';
    }

    return '0 Activities';
  }

  // Build individual field cards from all farms
  List<Widget> _buildFieldCards(
    List<Farm> farms,
    MonitoringState? monitoringState,
  ) {
    final List<Widget> fieldCards = [];

    for (final farm in farms) {
      if (farm.fields.isNotEmpty) {
        // Create cards for each field in this farm
        for (final field in farm.fields) {
          fieldCards.add(
            _buildIndividualFieldCard(farm, field, monitoringState),
          );
        }
      } else {
        // If farm has no fields, show the farm itself as a placeholder
        fieldCards.add(_buildFarmFieldCard(farm, monitoringState));
      }
    }

    return fieldCards;
  }

  // Build card for individual field
  Widget _buildIndividualFieldCard(
    Farm farm,
    Field field,
    MonitoringState? monitoringState,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFarm = farm;
          _selectedField = field;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[200] ?? Colors.grey, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: Colors.grey[100],
              ),
              child: GrowthStageLottie(
                growthStage: field.growthStage,
                width: 50.w,
                height: 50.h,
                fit: BoxFit.contain,
              ),
            ),
            horizontalSpace(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    field.fieldName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  verticalSpace(4),
                  Text(
                    farm.farmName,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  verticalSpace(8),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: _getGrowthStageColor(field.growthStage),
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: _getGrowthStageColor(field.growthStage).withOpacity(0.3),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _getGrowthStageText(field.growthStage),
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  verticalSpace(8),
                  Row(
                    children: [
                      Icon(Icons.grass, size: 14.sp, color: _getGrowthStatusColor(field.growthStage)),
                      horizontalSpace(4),
                      Text(
                        _getFieldGrowthStatus(field),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: _getGrowthStatusColor(field.growthStage),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      horizontalSpace(16),
                      Icon(Icons.sensors, size: 14.sp, color: field.sensors.isNotEmpty ? Colors.green : Colors.grey[600]),
                      horizontalSpace(4),
                      Text(
                        _getFieldDeviceCount(field),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: field.sensors.isNotEmpty ? Colors.green : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 24.sp),
          ],
        ),
      ),
    );
  }

  // Helper methods for field display
  Color _getGrowthStatusColor(String growthStage) {
    // Color based on growth stage progress
    switch (growthStage) {
      case 'VE':
      case 'V2':
      case 'V3':
      case 'V4':
        return Colors.blue; // Early stages - blue
      case 'V5':
      case 'V6':
      case 'V7':
      case 'V8':
        return Colors.green; // Good vegetative growth - green
      case 'VT':
        return Colors.orange; // Transition - orange
      case 'R1':
      case 'R2':
      case 'R3':
        return Colors.purple; // Reproductive - purple
      case 'R4':
      case 'R5':
        return Colors.deepOrange; // Maturing - deep orange
      case 'R6':
        return Colors.red; // Maturity - red
      default:
        return Colors.grey;
    }
  }

  Color _getGrowthStageColor(String growthStage) {
    switch (growthStage) {
      case 'VE':
        return Colors.green[300]!;
      case 'V2':
      case 'V3':
      case 'V4':
        return Colors.green[400]!;
      case 'V5':
      case 'V6':
      case 'V7':
      case 'V8':
      case 'VT':
        return Colors.green[500]!;
      case 'R1':
      case 'R2':
      case 'R3':
        return Colors.orange[400]!;
      case 'R4':
      case 'R5':
        return Colors.orange[500]!;
      case 'R6':
        return Colors.red[400]!;
      default:
        return Colors.grey[400]!;
    }
  }

  String _getGrowthStageText(String growthStage) {
    switch (growthStage) {
      case 'VE':
        return 'Emergence';
      case 'V2':
      case 'V3':
      case 'V4':
        return 'Early Vegetative';
      case 'V5':
      case 'V6':
      case 'V7':
      case 'V8':
      case 'VT':
        return 'Mid Vegetative';
      case 'R1':
      case 'R2':
      case 'R3':
        return 'Reproductive';
      case 'R4':
      case 'R5':
        return 'Maturing';
      case 'R6':
        return 'Maturity/Harvest';
      default:
        return 'Unknown';
    }
  }

  String _getFieldGrowthStatus(Field field) {
    // Calculate growth percentage based on growth stage (more accurate mapping)
    final growthStage = field.growthStage;
    final growthPercentages = {
      'VE': 5,
      'V2': 15,
      'V3': 25,
      'V4': 35,
      'V5': 45,
      'V6': 55,
      'V7': 65,
      'V8': 70,
      'VT': 75,
      'R1': 80,
      'R2': 85,
      'R3': 90,
      'R4': 92,
      'R5': 95,
      'R6': 100,
    };

    final percentage = growthPercentages[growthStage] ?? 5;
    return 'Growth: $percentage%';
  }

  String _getFieldDeviceCount(Field field) {
    final deviceCount = field.sensors.length;
    return '$deviceCount Device${deviceCount != 1 ? 's' : ''}';
  }

  void _showPrescriptionNotifications(List<dynamic> recommendations) {
    for (final rec in recommendations) {
      final recMap = rec as Map<String, dynamic>;
      final action = recMap['action'] as String? ?? 'Farm Task';
      final urgency = recMap['urgency'] as String? ?? 'LOW';
      final details = recMap['details'] as String? ?? '';
      final category = recMap['category'] as String? ?? 'general';
      
      // Create unique ID for this prescription
      final prescriptionId = '${action}_${urgency}_${category}';
      
      // Only notify for high/urgent priority prescriptions that haven't been notified yet
      if ((urgency.toUpperCase() == 'HIGH' || urgency.toUpperCase() == 'URGENT') && 
          !_notifiedPrescriptions.contains(prescriptionId)) {
        
        _notificationService.showPrescriptionAlertNotification(
          title: action,
          message: details.isNotEmpty ? details : 'High priority farm task requires attention',
          priority: urgency,
        );
        
        // Mark as notified
        _notifiedPrescriptions.add(prescriptionId);
      }
    }
  }
}
