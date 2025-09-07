import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/features/live_monitoring/domain/usecases/get_localized_greeting.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/colors.dart';
import '../../../farm/presentation/bloc/farm_bloc.dart';
import '../../../farm/domain/entities/farm.dart';
import '../bloc/monitoring_bloc.dart';
import '../widgets/farm_detail_widget.dart';
import '../../../authentication/presentation/bloc/authentication_bloc.dart';

class LiveMonitoringScreen extends StatefulWidget {
  const LiveMonitoringScreen({super.key});

  @override
  State<LiveMonitoringScreen> createState() => _LiveMonitoringScreenState();
}

class _LiveMonitoringScreenState extends State<LiveMonitoringScreen>
    with SingleTickerProviderStateMixin {
  Farm? _selectedFarm;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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

    // Load initial data
    _loadData();
    _animationController.forward();
  }

  void _loadData() {
    // Load user farms
    final authState = context.read<AuthenticationBloc>().state;
    if (authState.status == AuthenticationStatus.authenticated &&
        authState.user != null) {
      final user = authState.user;
      if (user != null) {
        context.read<FarmBloc>().add(GetUserFarmsEvent(userId: user.id));
      }

      // Load weather data for user's first farm (will be updated when farm is selected)
      // Weather data will be loaded when farm data is available
    }
    // Load latest sensor readings
    context.read<MonitoringBloc>().add(LoadLatestReadingsEvent());
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
      });
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MAIZE_PRIMARY_LIGHT,
      body: _selectedFarm != null ? _buildFarmDetailView() : _buildHomeView(),
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
                color: MAIZE_PRIMARY,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min, // <-- key to wrapping!
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, color: Colors.white, size: 18.sp),
                  horizontalSpace(8),
                  Flexible(
                    child: Text(
                      location,
                      style: TextTheme.of(
                        context,
                      ).bodySmall?.copyWith(color: MAIZE_PRIMARY_LIGHT),
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
      height: 280.h, // Add explicit height constraint
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
          20.w,
        ), // Add padding instead of using margin on child
        child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, authState) {
            final user = authState.user;
            return BlocBuilder<MonitoringBloc, MonitoringState>(
              builder: (context, monitoringState) {
                // Use real weather data if available, otherwise fallback to sensor data
                final weatherData = monitoringState.weatherData;
                final latestReading =
                    monitoringState.latestReadings.isNotEmpty
                        ? monitoringState.latestReadings.first
                        : null;

                // Get temperature from weather API or sensor data
                final temperature =
                    weatherData?.temperature ??
                    latestReading?.temperature ??
                    16.0;
                final humidity =
                    weatherData?.humidity ?? latestReading?.humidity ?? 72.5;
                final windSpeed =
                    weatherData?.windSpeed ??
                    _calculateWindSpeed(latestReading?.lightIntensity ?? 50.0);

                // Get weather condition from API or calculate from sensor data
                String weatherCondition;
                IconData weatherIcon;

                if (weatherData != null) {
                  weatherCondition = weatherData.condition;
                  weatherIcon = _getWeatherIcon(weatherData.condition);
                } else {
                  weatherCondition = _getWeatherCondition(
                    temperature,
                    humidity,
                    latestReading?.lightIntensity ?? 50.0,
                  );
                  weatherIcon = _getWeatherIcon(weatherCondition);
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
                        fontWeight: FontWeight.w500,
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
                                  weatherData?.description ?? weatherCondition,
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
                        if (weatherData?.pressure != null) ...[
                          SizedBox(width: kAppSmallGap),
                          _buildWeatherStat(
                            '${weatherData?.pressure?.toStringAsFixed(0) ?? '0'} hPa',
                            Icons.speed,
                          ),
                        ],
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
        color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20.r),
      ),

      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18.sp),
          horizontalSpace(6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCards() {
    return BlocBuilder<FarmBloc, FarmState>(
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
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTaskCard({
    required String time,
    required String title,
    required String status,
    required Color color,
    required bool isActive,
  }) {
    return Container(
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
    );
  }

  Widget _buildFarmFieldsSection() {
    return Container(
      margin: EdgeInsets.only(top: kAppSmallPadding),
      padding: EdgeInsets.all(kAppMediumPadding),
      decoration: BoxDecoration(
        color: Colors.white,
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
                (total, farm) => total + (farm.fields?.length ?? 0),
              );

              // Load analytics for the first farm if available
              if (farms.isNotEmpty && monitoringState.farmAnalytics == null) {
                context.read<MonitoringBloc>().add(
                  LoadFarmAnalyticsEvent(farmId: farms.first.id ?? ''),
                );
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
                      children:
                          farmState.farms
                              .take(2)
                              .map(
                                (farm) =>
                                    _buildFarmFieldCard(farm, monitoringState),
                              )
                              .toList(),
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
          });
        }
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
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                image: const DecorationImage(
                  image: AssetImage('assets/images/corn-logo.png'),
                  fit: BoxFit.cover,
                ),
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

  // Generate dynamic tasks based on farm data and sensor readings
  List<Map<String, dynamic>> _generateDynamicTasks(
    FarmState farmState,
    MonitoringState monitoringState,
  ) {
    final tasks = <Map<String, dynamic>>[];
    final now = DateTime.now();

    if (farmState is FarmsLoaded && farmState.farms.isNotEmpty) {
      final farm = farmState.farms.first;
      final latestReading =
          monitoringState.latestReadings.isNotEmpty
              ? monitoringState.latestReadings.first
              : null;

      // Generate irrigation task based on soil moisture
      if (latestReading != null && latestReading.soilMoisture < 40) {
        tasks.add({
          'time':
              '${now.hour.toString().padLeft(2, '0')}:${(now.minute + 30).toString().padLeft(2, '0')}',
          'title': 'Irrigation\nRequired',
          'status': 'Urgent',
          'color': Colors.red[400],
          'isActive': true,
        });
      }

      // Generate monitoring task
      tasks.add({
        'time': '${(now.hour + 1).toString().padLeft(2, '0')}:00',
        'title': 'Sensor\nCheck',
        'status': 'Scheduled',
        'color': MAIZE_PRIMARY,
        'isActive': false,
      });

      // Generate fertilizer task based on growth stage
      if (farm.fields != null && farm.fields.isNotEmpty) {
        final field = farm.fields.first;
        if (field.growthStage == 'V3' || field.growthStage == 'V8') {
          tasks.add({
            'time': '${(now.hour + 2).toString().padLeft(2, '0')}:00',
            'title': 'Fertilizer\nApplication',
            'status': 'Pending',
            'color': Colors.white,
            'isActive': false,
          });
        }
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

  // Get farm growth status based on analytics and sensor data
  String _getFarmGrowthStatus(Farm? farm, MonitoringState? monitoringState) {
    if (farm?.fields != null && farm?.fields?.isNotEmpty == true) {
      final field = farm!.fields!.first;
      final growthStage = field.growthStage ?? 'VE';

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
      final sensorCount = analytics['totalSensors'] ?? 0;
      final alertCount = analytics['alerts']?['total'] ?? 0;
      final totalActivities = sensorCount + alertCount;
      return '$totalActivities Activities';
    }

    return '0 Activities';
  }
}
