import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/features/live_monitoring/domain/usecases/get_localized_greeting.dart';
import 'package:mobile/generated/l10n.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/home_screen_service.dart';
import '../../../../core/services/background_notification_service.dart';
import '../../../farm/presentation/bloc/farm_bloc.dart';
import '../../../farm/domain/entities/farm.dart';
import '../bloc/monitoring_bloc.dart';
import '../widgets/farm_detail_widget.dart';
import '../widgets/growth_stage_lottie.dart';
import '../../../authentication/presentation/bloc/authentication_bloc.dart';
import '../../domain/entities/sensor_reading.dart';

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
  List<Map<String, dynamic>> _cachedTasks = [];

  // Refresh completion status for all tasks
  Future<void> _refreshCompletionStatus([StateSetter? setState]) async {
    print('🔧 LIVE MONITORING: Refreshing completion status for ${_cachedTasks.length} tasks');
    
    // Check if user is authenticated
    final authState = context.read<AuthenticationBloc>().state;
    print('🔧 LIVE MONITORING: Auth state during refresh - status: ${authState.status}, user: ${authState.user?.id}');
    
    if (authState.status != AuthenticationStatus.authenticated || authState.user == null) {
      print('🔧 LIVE MONITORING: User not authenticated, skipping completion status refresh');
      return;
    }
    
    // Direct approach: Get completion status directly from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    
    
    if (_cachedTasks.isNotEmpty) {
      for (final task in _cachedTasks) {
        final taskId = task['id'] as String;
        final oldStatus = task['isCompleted'];
        final completionKey = 'completion_${authState.user!.id}_$taskId';
        final isCompleted = prefs.getBool(completionKey) ?? false;
        print('🔧 LIVE MONITORING: Refresh - $taskId: old=$oldStatus, new=$isCompleted (user: ${authState.user!.id})');
        if (task['isCompleted'] != isCompleted) {
          task['isCompleted'] = isCompleted;
          task['status'] = isCompleted ? 'completed' : 'pending';
          print('🔧 LIVE MONITORING: Updated task $taskId status to $isCompleted');
        }
      }
      if (setState != null) {
        setState(() {}); // Trigger rebuild using StatefulBuilder's setState
      } else {
        this.setState(() {}); // Fallback to main widget's setState
      }
      print('🔧 LIVE MONITORING: Refresh completed, UI rebuilt');
    }
  }

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

    // Initialize background notification service
    BackgroundNotificationService.initialize();

    // Load initial data
    _loadData();
    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh completion status when screen becomes visible
    _refreshCompletionStatus();
  }

  void _loadData() {
    // Load data with optimized caching
    _loadDataOptimized();
  }

  /// Optimized data loading with smart caching
  Future<void> _loadDataOptimized() async {
    try {
      final farmState = context.read<FarmBloc>().state;
      final monitoringState = context.read<MonitoringBloc>().state;
      
      print('🌽 LiveMonitoring: _loadDataOptimized called - FarmBloc state: ${farmState.runtimeType}');
      
      // Load user farms only if not already loaded
      if (farmState is! FarmsLoaded) {
        print('🌽 LiveMonitoring: FarmBloc not loaded, checking auth...');
        final authState = context.read<AuthenticationBloc>().state;
        if (authState.status == AuthenticationStatus.authenticated &&
            authState.user != null) {
          final user = authState.user;
          if (user != null) {
            print('🌽 LiveMonitoring: Loading farms for user: ${user.id}');
            context.read<FarmBloc>().add(GetUserFarmsEvent(userId: user.id));
          } else {
            print('🌽 LiveMonitoring: User is null');
          }
        } else {
          print('🌽 LiveMonitoring: Auth not ready - status: ${authState.status}, user: ${authState.user?.id}');
        }
      } else {
        print('🌽 LiveMonitoring: Farms already loaded with ${farmState.farms.length} farms');
        
        // If farms are loaded, try to load cached home data for instant display
        if (farmState.farms.isNotEmpty) {
          final selectedFarm = farmState.farms.first;
          print('🌽 LiveMonitoring: Loading cached home data for farm: ${selectedFarm.id}');
          
          try {
            final homeData = await HomeScreenService.getHomeScreenData(
              farmId: selectedFarm.id,
              forceRefresh: false,
            );
            
            if (homeData.isNotEmpty) {
              print('🌽 LiveMonitoring: Loaded cached data - Analytics: ${homeData['analytics'] != null}, Prescriptions: ${homeData['prescriptions']?.length ?? 0}');
              
              // Update UI with cached data immediately
              if (homeData['analytics'] != null) {
                // Trigger analytics update with cached data
                context.read<MonitoringBloc>().add(LoadFarmAnalyticsEvent(
                  farmId: selectedFarm.id ?? '',
                ));
              }
            }
          } catch (e) {
            print('🌽 LiveMonitoring: Error loading cached data: $e');
          }
        }
      }
      
      // Always load latest sensor readings to get fresh data
      print('🌽 LiveMonitoring: Checking if should load readings - isLoading: ${monitoringState.isLoading}');
      if (!monitoringState.isLoading) {
        print('🌽 LiveMonitoring: Loading latest readings...');
        context.read<MonitoringBloc>().add(LoadLatestReadingsEvent());
      } else {
        print('🌽 LiveMonitoring: Skipping load readings - already loading');
      }
      
    } catch (e) {
      print('🌽 LiveMonitoring: Error in _loadDataOptimized: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    // Stop background refresh when screen is disposed
    HomeScreenService.stopBackgroundRefresh();
    // Stop background notification service when leaving the screen
    BackgroundNotificationService.stopAllTasks();
    // Clear notification tracking to prevent duplicate notifications
    BackgroundNotificationService.clearNotificationTracking();
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
        backgroundColor: MAIZE_PRIMARY_LIGHT.withOpacity(0.5),
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
                String weatherCondition = S.of(context).partly_cloudy;
                IconData weatherIcon = Icons.cloud;
                String weatherDescription = S.of(context).partly_cloudy_description;

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
                      final rawCondition = currentWeather['condition'] as String? ?? 'Partly Cloudy';
                      weatherCondition = _translateWeatherCondition(rawCondition);
                      weatherDescription = currentWeather['description'] as String? ?? S.of(context).partly_cloudy_description;
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
              return FutureBuilder<List<Map<String, dynamic>>>(
                future: _generateDynamicTasks(farmState, monitoringState),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: 140.h,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  
                  final tasks = snapshot.data ?? [];

              return SizedBox(
                height: 140.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? kAppSmallGap : 0,
                        right: index < tasks.length ? kAppSmallGap : 0,                        
                      ),
                      child: _buildTaskCard(
                        time: task['time'],
                        title: task['title'],
                        status: task['status'],
                        color: _getColorForUrgency(task['urgency']),
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
    // Extract additional information from taskData
    final fieldName = taskData?['fieldName'] as String? ?? S.of(context).unknown_field;    
    final deadline = taskData?['deadline'] as String? ?? S.of(context).asap;
    final urgency = taskData?['urgency'] as String? ?? 'MEDIUM';
    final isCompleted = taskData?['isCompleted'] as bool? ?? false;
    
    // Convert color string back to Color object if needed
    Color actualColor = color;
    if (taskData?['color'] is String) {
      final colorString = taskData!['color'] as String;
      final colorValue = int.tryParse(colorString);
      if (colorValue != null) {
        actualColor = Color(colorValue);
      }
    }
    
    // Debug logging for completion status
    print('🔧 BUILDING TASK CARD: $title - isCompleted: $isCompleted');
    print('🔧 BUILDING TASK CARD: Full task data: $taskData');
    return Material(
      color: Colors.transparent,
      child: InkWell(
      onTap: () async {
        if (taskData != null) {
          await Navigator.pushNamed(
            context,
            '/detailed-prescription',
            arguments: taskData,
          );
          // Refresh completion status when returning from detailed screen
          print('🔧 LIVE MONITORING: Returning from detailed screen, refreshing completion status');
          await _refreshCompletionStatus();
          // Force a rebuild by calling setState
          setState(() {});
        }
      },
        borderRadius: BorderRadius.circular(16.r),
        splashColor: Colors.black.withOpacity(0.1),
        highlightColor: Colors.black.withOpacity(0.1),
      child: Container(
          width: 155.w, // Increased width to accommodate more information
        padding: EdgeInsets.all(kAppMediumPadding),
        decoration: BoxDecoration(
            color: isCompleted 
                ? Colors.green[300] 
                : actualColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16.r),
            border: isCompleted 
                ? Border.all(color: Colors.green[300]!, width: 2)
                : null,
            boxShadow: isCompleted ? [
              BoxShadow(
                color: Colors.green.withOpacity(0.1),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Completion status and urgency row
            Row(
              children: [
                // Enhanced completion status indicator
                
                
                // Urgency indicator (shows completion status when completed)
                Container(
                 padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green[600] : actualColor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child:  Text(
                        isCompleted ? S.of(context).done : urgency.toUpperCase(),
                        style: TextTheme.of(
                          context,
                        ).bodySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.sp),
                      ),
      
              ),
              ],
            ),

                
              SizedBox(height: 6.h),
              
       
              // Task title
                Text(
              title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isCompleted 
                      ? Colors.green[700] 
                      : (isActive ? MAIZE_ACCENT : Colors.grey[600]),
                    fontWeight: FontWeight.w600,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              Spacer(),
              

                    Row(                    
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       // Field name container
 Container(
                           padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                           decoration: BoxDecoration(
                             color: isActive 
                                 ? MAIZE_ACCENT.withOpacity(0.2)
                                 : Colors.black.withOpacity(0.1),
                             borderRadius: BorderRadius.circular(20.r),
                           ),
                           child: Row(
                             
                             children: [
                               Icon(Icons.location_on, color: MAIZE_ACCENT, size: 12.sp),
                               horizontalSpace(2),
            Text(
                                   fieldName,
                                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                     color: MAIZE_ACCENT,
                fontWeight: FontWeight.w600,
                                     fontSize: 12.sp,
                                   ),
                                 ),
                               
                             ],
                           ),
                         ),
                       
                       
                       SizedBox(width: 8.w), // Add spacing between containers
                       
                       // Deadline container
                       Flexible(
                         child: Container(
                           padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                             color: isActive 
                                 ? MAIZE_ACCENT.withOpacity(0.2)
                                 : Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
                           child:  Text(
                             deadline,
                             style: Theme.of(context).textTheme.bodySmall?.copyWith(
                               color: isActive ? MAIZE_ACCENT : Colors.grey[600],
                               fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
                             overflow: TextOverflow.ellipsis,
              ),
            ),
                       ),
                 
          ],
              ),
              // Status and send time
               
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildFarmFieldsSection() {
    return Container(
      margin: EdgeInsets.only(top: kAppSmallPadding),
      padding: EdgeInsets.only(
        left: kAppMediumPadding, 
        right: kAppMediumPadding, 
        top: kAppMediumPadding, 
        bottom: kAppLargePadding,
      ),
      decoration: BoxDecoration(
        color: MAIZE_PRIMARY_LIGHT,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: BlocBuilder<FarmBloc, FarmState>(
        builder: (context, farmState) {
          print('🌽 LiveMonitoring: FarmBloc state: ${farmState.runtimeType}');
          if (farmState is FarmsLoaded) {
            print('🌽 LiveMonitoring: FarmsLoaded with ${farmState.farms.length} farms');
            for (int i = 0; i < farmState.farms.length; i++) {
              final farm = farmState.farms[i];
              print('🌽 LiveMonitoring: Farm $i - Name: ${farm.farmName}, Fields: ${farm.fields.length}');
            }
          }
          
          return BlocBuilder<MonitoringBloc, MonitoringState>(
            builder: (context, monitoringState) {
              final farmName =
                  farmState is FarmsLoaded && farmState.farms.isNotEmpty
                      ? farmState.farms.first.farmName
                      : S.of(context).my_farm;
              final farms =
                  farmState is FarmsLoaded ? farmState.farms : <Farm>[];
              final fieldCount = farms.fold<int>(
                0,
                (total, farm) => total + farm.fields.length,
              );
              
              print('🌽 LiveMonitoring: Final farmName: $farmName, fieldCount: $fieldCount');

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
                            ).bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          verticalSpace(1),
                          Text(
                            '$fieldCount field${fieldCount != 1 ? 's' : ''} registered',
                            style: TextTheme.of(
                              context,
                            ).bodySmall?.copyWith(),
                          ),
                        ],
                      ),
                      const Spacer(),
                       Flexible(
                         child: ElevatedButton.icon(
                           onPressed: () {
                             Navigator.pushNamed(context, '/field-registration');
                           },
                           icon: Icon(
                             Icons.add,
                             size: 16.sp,
                             color: Colors.white,
                           ),
                           label: Text(
                             S.of(context).add_field,
                             style: Theme.of(context).textTheme.bodySmall?.copyWith(
                               color: Colors.white,
                               fontWeight: FontWeight.w600,
                             ),
                             maxLines: 1,
                             overflow: TextOverflow.ellipsis,
                           ),
                           style: ElevatedButton.styleFrom(
                             backgroundColor: MAIZE_PRIMARY,
                             padding: EdgeInsets.symmetric(
                               horizontal: 20.w,
                               vertical: 12.h,
                             ),
                             shape: RoundedRectangleBorder(
                               borderRadius: BorderRadius.circular(16.r),
                             ),
                           ),
                         ),
                       ),
                       
                      
                      
                  ],
                  ),
                  SizedBox(height: kAppMediumGap),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
      onTap: () {
        if (farm != null) {
          setState(() {
            _selectedFarm = farm;
            _selectedField = farm.fields.isNotEmpty ? farm.fields.first : null;
          });
          
          // Reload analytics data for the selected farm
          if (farm.id != null) {
            context.read<MonitoringBloc>().add(
              LoadFarmAnalyticsEvent(farmId: farm.id!),
            );
          }
        }
      },
        borderRadius: BorderRadius.circular(16.r),
        splashColor: MAIZE_ACCENT.withOpacity(0.1),
        highlightColor: MAIZE_ACCENT.withOpacity(0.05),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: MAIZE_ACCENT.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
        ),
        child: Row(
          children: [
            Container(
                width: 60.w,
                height: 60.h,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  color: MAIZE_ACCENT.withOpacity(0.2),
                  border: Border.all(
                    color: Colors.white,
                    width: 1,
                  ),
              ),
              child: farm?.fields.isNotEmpty == true
                  ? GrowthStageLottie(
                      growthStage: farm!.fields.first.growthStage,
                        width: 60.w,
                        height: 60.h,
                      fit: BoxFit.contain,
                    )
                  : Icon(
                      Icons.agriculture,
                        size: 28.sp,
                        color: MAIZE_ACCENT,
                    ),
            ),
            horizontalSpace(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      farm?.farmName ?? S.of(context).no_field,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  verticalSpace(8),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                        color: _getGrowthStageColor(farm?.fields.isNotEmpty == true 
                            ? farm!.fields.first.growthStage 
                            : 'VE'),
                        borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                        _getGrowthStageText(farm?.fields.isNotEmpty == true 
                            ? farm!.fields.first.growthStage 
                            : 'VE'),
                      style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                    verticalSpace(12),
                  Row(
                    children: [
                        Icon(
                          Icons.grass, 
                          size: 16.sp, 
                          color: MAIZE_ACCENT.withOpacity(0.7),
                        ),
                        horizontalSpace(6),
                        Flexible(
                          child: Text(
                        _getFarmGrowthStatus(farm, monitoringState),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: MAIZE_ACCENT.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        horizontalSpace(12),
                      Icon(
                          Icons.sensors,
                          size: 16.sp,
                          color: MAIZE_ACCENT.withOpacity(0.7),
                        ),
                        horizontalSpace(6),
                        Flexible(
                          child: Text(
                        _getFarmActivityCount(farm, monitoringState),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: MAIZE_ACCENT.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
              Icon(
                Icons.chevron_right, 
                color: MAIZE_ACCENT.withOpacity(0.6), 
                size: 24.sp,
              ),
            ],
          ),
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
                  farmName: S.of(context).default_farm,
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
      return S.of(context).sunny;
    } else if (lightIntensity > 60) {
      return S.of(context).partly_cloudy_weather;
    } else if (lightIntensity > 40) {
      return S.of(context).cloudy;
    } else if (humidity > 85) {
      return S.of(context).rainy;
    } else {
      return S.of(context).overcast;
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

  String _translateWeatherCondition(String condition) {
    switch (condition) {
      case 'Sunny':
        return S.of(context).sunny;
      case 'Partly Cloudy':
        return S.of(context).partly_cloudy;
      case 'Cloudy':
        return S.of(context).cloudy;
      case 'Rainy':
        return S.of(context).rainy;
      case 'Overcast':
        return S.of(context).overcast;
      default:
        return S.of(context).partly_cloudy;
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
      S.of(context).january,
      S.of(context).february,
      S.of(context).march,
      S.of(context).april,
      S.of(context).may,
      S.of(context).june,
      S.of(context).july,
      S.of(context).august,
      S.of(context).september,
      S.of(context).october,
      S.of(context).november,
      S.of(context).december,
    ];
    final dateFormat = '${months[now.month - 1]} ${now.day}';
    return '$timeFormat | $dateFormat';
  }

  // Generate dynamic tasks based on analytics_v2 recommendations
  Future<List<Map<String, dynamic>>> _generateDynamicTasks(
    FarmState farmState,
    MonitoringState monitoringState,
  ) async {
    final tasks = <Map<String, dynamic>>[];
    final now = DateTime.now();

    // Debug: Print farm data status
    print('🔍 _generateDynamicTasks called with farmState: ${farmState.runtimeType}');
    if (farmState is FarmsLoaded) {
      print('🔍 Farm Data Status: ${farmState.farms.length} farms loaded');
    } else {
      print('🔍 Farm Data Status: Not loaded (${farmState.runtimeType})');
    }

    if (farmState is FarmsLoaded && farmState.farms.isNotEmpty) {
      // Debug: Print farm data status
      print('🔍 Farm Data Status: ${farmState.farms.length} farms loaded');
      if (farmState.farms.isNotEmpty) {
        final farm = farmState.farms.first;
        print('🔍 First Farm: ${farm.farmName}, Fields: ${farm.fields.length}');
        if (farm.fields.isNotEmpty) {
          final field = farm.fields.first;
          print('🔍 First Field: ${field.fieldName}, Soil: ${field.soilType}, Stage: ${field.growthStage}');
        }
      }
      
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
        
        // Debug field analyses data
        if (analyticsData['descriptive'] != null) {
          final descriptive = analyticsData['descriptive'] as Map<String, dynamic>;
          if (descriptive['field_analyses'] != null) {
            final fieldAnalyses = descriptive['field_analyses'] as Map<String, dynamic>;
            print('🔍 Field Analyses Keys: ${fieldAnalyses.keys.toList()}');
            for (final key in fieldAnalyses.keys) {
              final fieldData = fieldAnalyses[key] as Map<String, dynamic>;
              print('🔍 Field $key: field_id=${fieldData['field_id']}, growth_stage=${fieldData['growth_stage']}');
            }
          }
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
        await _showPrescriptionNotifications(recommendations);
        
        print('🔍 Processing ${recommendations.length} recommendations for task cards');
        
        // Convert analytics recommendations to task cards
        for (int i = 0; i < recommendations.length; i++) {
          final rec = recommendations[i] as Map<String, dynamic>;
          print('🔍 Processing recommendation $i: ${rec['action']} for field ${rec['field_id']}');
          
          // Check if this prescription is deleted
          final deletionStableId = '${rec['action']}_${rec['field_name']}_${rec['category']}_${rec['parameter']}';
          final deletionTaskId = 'analytics_${deletionStableId.hashCode.abs()}';
          
          // Check if this task is deleted
          final deletionAuthState = context.read<AuthenticationBloc>().state;
          if (deletionAuthState.status == AuthenticationStatus.authenticated && deletionAuthState.user != null) {
            final prefs = await SharedPreferences.getInstance();
            final deletedKey = 'deleted_${deletionAuthState.user!.id}_$deletionTaskId';
            final isDeleted = prefs.getBool(deletedKey) ?? false;
            if (isDeleted) {
              print('🔍 Skipping deleted prescription: $deletionTaskId');
              continue;
            }
          }
          
          final urgency = rec['urgency'] as String? ?? 'LOW';
          final timeline = rec['timeline'] as String? ?? '1 day';
          final action = rec['action'] as String? ?? 'Check farm';
          final details = rec['details'] as String? ?? '';
          final category = rec['category'] as String? ?? 'general';
          final instructions = rec['instructions'] as List<dynamic>? ?? [];
          
      // Extract field-specific information directly from recommendation data
      String fieldName = rec['field_name'] as String? ?? 'Unknown Field';
      String soilType = rec['soil_type'] as String? ?? 'Loam';
      String growthStage = rec['growth_stage'] as String? ?? 'Unknown';
      String? fieldId = rec['field_id'] as String?;
          final parameter = rec['parameter'] as String? ?? 'general';
          
      print('🔍 Using recommendation data directly: $fieldName, $soilType, $growthStage, $fieldId');
          
          print('🔍 Extracted field data - Name: $fieldName, Soil: $soilType, Stage: $growthStage, FieldId: $fieldId');

          // Format the title to show the actual action with better readability
          String formattedTitle = _formatRecommendationTitle(action, category);

          // Use details for status if available, otherwise use urgency
          String status =
              details.isNotEmpty
                  ? _formatDetailsForStatus(details, urgency, timeline)
                  : _mapUrgencyToStatus(urgency);

          // Format timeline for display instead of calculated time
          String displayTime = _formatTimelineForDisplay(timeline);
          
          // Use current time for tasks to ensure they show as "just now"
          // This ensures tasks are always fresh and not dependent on backend timestamp
          final createdAt = DateTime.now();
          
          // Calculate send time (when the recommendation was created)
          String sendTime = _formatSendTime(createdAt.toIso8601String());
          
          // Calculate deadline based on timeline and urgency
          String deadline = _calculateDeadline(timeline, urgency);

          // Get completion status for this task
          // Create a stable ID based on task content to ensure consistency
          final stableId = '${action}_${fieldName}_${category}_${parameter}';
          final taskId = 'analytics_${stableId.hashCode.abs()}';
          
          // Check if user is authenticated before getting completion status
          final authState = context.read<AuthenticationBloc>().state;
          bool isCompleted = false;
          
          print('🔧 Live Monitoring: Auth state - status: ${authState.status}, user: ${authState.user?.id}');
          
          if (authState.status == AuthenticationStatus.authenticated && authState.user != null) {
            // Direct approach: Get completion status directly from SharedPreferences
            final prefs = await SharedPreferences.getInstance();
            final completionKey = 'completion_${authState.user!.id}_$taskId';
            isCompleted = prefs.getBool(completionKey) ?? false;
            print('🔧 Live Monitoring: Direct completion status for task $taskId: $isCompleted (user: ${authState.user!.id})');
          } else {
            print('🔧 Live Monitoring: User not authenticated, skipping completion status check for task $taskId');
          }
          
          tasks.add({
            'id': taskId,
            'title': formattedTitle,
            'description': details,
            'category': category,
            'urgency': urgency,
            'timeline': timeline,
            'parameter': parameter,
            'fieldName': fieldName,
            'soilType': soilType,
            'growthStage': growthStage,
            'fieldId': fieldId,
            'priority': _mapUrgencyToPriority(urgency),
            'status': isCompleted ? 'completed' : status,
            'isCompleted': isCompleted,
            'dueDate': _calculateDueDate(timeline).toIso8601String(),
            'createdAt': createdAt.toIso8601String(),
            'updatedAt': createdAt.toIso8601String(),
            'time': displayTime,
            'color': (isCompleted ? Colors.green : _getColorForUrgency(urgency)).value.toString(),
            'isActive': isCompleted ? false : (urgency == 'HIGH' || urgency == 'URGENT' || urgency == 'MEDIUM'),
            'details': details,
            'sendTime': sendTime,
            'deadline': deadline,
            'instructions': instructions,
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
          'fieldName': 'System',
          'sendTime': 'Just now',
          'deadline': 'Soon',
          'urgency': 'LOW',
          'instructions': [],
          'description': 'Processing farm analytics data...',
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
          'fieldName': 'All Fields',
          'sendTime': 'Just now',
          'deadline': 'N/A',
          'urgency': 'LOW',
          'instructions': [],
          'description': 'All farm operations are up to date.',
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
          'fieldName': 'New Farm',
          'sendTime': 'Just now',
          'deadline': 'Today',
          'urgency': 'HIGH',
          'instructions': ['Register your farm details', 'Add field information', 'Configure sensor settings'],
          'description': 'Complete farm registration to start monitoring',
        },
        {
          'time': '${(now.hour + 1).toString().padLeft(2, '0')}:00',
          'title': 'Add\nSensors',
          'status': 'Pending',
          'color': Colors.white,
          'isActive': false,
          'fieldName': 'All Fields',
          'sendTime': 'Just now',
          'deadline': 'This week',
          'urgency': 'MEDIUM',
          'instructions': ['Install soil moisture sensors', 'Set up weather station', 'Connect to monitoring system'],
          'description': 'Install sensors to enable real-time monitoring',
        },
      ]);
    }

    // Cache tasks for refresh functionality
    _cachedTasks = tasks;
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
      case 'URGENT':
        return Colors.red[600]!;
      case 'HIGH':
        return Colors.orange[800]!;
      case 'MEDIUM':
        return MAIZE_PRIMARY;
      case 'LOW':
      default:
        return MAIZE_BUTTON_TRANSPARENT;
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
    return Padding(padding: EdgeInsets.only(bottom: kAppMediumGap),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
      onTap: () {
        setState(() {
          _selectedFarm = farm;
          _selectedField = field;
        });
        
        // Reload analytics data for the selected field
        if (farm.id != null) {
          context.read<MonitoringBloc>().add(
            LoadFarmAnalyticsEvent(farmId: farm.id!),
          );
        }
      },
        borderRadius: BorderRadius.circular(16.r),
        splashColor: MAIZE_ACCENT.withOpacity(0.1),
        highlightColor: MAIZE_ACCENT.withOpacity(0.05),
      child: Container(
          padding: EdgeInsets.all(kAppMediumPadding),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),  
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: Colors.white,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
        ),
        child: Row(
          children: [
            Container(
                width: 70.w,
                height: 70.h,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40.r),
                  color: MAIZE_ACCENT.withOpacity(0.1),                 
              ),
              child: GrowthStageLottie(
                growthStage: field.growthStage,
                  width: 70.w,
                  height: 70.h,
                fit: BoxFit.contain,
              ),
            ),
              horizontalSpace(kAppSmallGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Row(                      
                      children: [
                      
                  Text(
                    field.fieldName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,                        
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    horizontalSpace(kAppSmallGap),
                  Expanded(child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.w, vertical: 4.h
                    ),
                    decoration: BoxDecoration(
                        color: _getCropConditionColor(monitoringState),
                        borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                       _getCropConditionText(monitoringState),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                          fontSize: 12.sp,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),

              )]),

                  
                     verticalSpace(kAppSmallGap),
                    

     
                      Text(
                            '${S.of(context).soil_type}: ${field.soilType}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(                          
                          
                          color: MAIZE_ACCENT,
                        ),
                      ),

                      
                      horizontalSpace(kAppSmallGap),
                      Text(
                        _getFieldGrowthStatus(field),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                         
                          color: MAIZE_ACCENT,
                        ),
                      ),
                                                                                                                        
                  ],
                ),
              ),
              Icon(
                Icons.north_east, 
                color: MAIZE_ACCENT, 
                size: 18.sp,
              ),
          ],
        ),
      ),
      ),
    ));
  }

  // Helper methods for field display

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
        return S.of(context).growth_stage_emergence;
      case 'V2':
      case 'V3':
      case 'V4':
        return S.of(context).growth_stage_early_vegetative;
      case 'V5':
      case 'V6':
      case 'V7':
      case 'V8':
      case 'VT':
        return S.of(context).growth_stage_mid_vegetative;
      case 'R1':
      case 'R2':
      case 'R3':
        return S.of(context).growth_stage_reproductive;
      case 'R4':
      case 'R5':
        return S.of(context).growth_stage_maturing;
      case 'R6':
        return S.of(context).growth_stage_maturity_harvest;
      default:
        return S.of(context).unknown;
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


  String _getCropConditionText(MonitoringState? monitoringState) {
    // First try to get from analytics data
    if (monitoringState?.farmAnalytics != null) {
      final analyticsData = monitoringState!.farmAnalytics!;
      print('🔍 Analytics data for crop condition: $analyticsData');
      
      // Try to get crop condition from prescriptive analytics first
      if (analyticsData['prescriptive'] != null) {
        final prescriptive = analyticsData['prescriptive'] as Map<String, dynamic>;
        final cropCondition = prescriptive['crop_condition'] as Map<String, dynamic>?;
        if (cropCondition != null) {
          final status = cropCondition['status'] as String? ?? 'Unknown';
          print('🔍 Found crop condition from prescriptive: $status');
          return status;
        }
      }
      
      // Fallback to descriptive analytics
      final descriptive = analyticsData['descriptive'] as Map<String, dynamic>?;
      if (descriptive != null) {
        final overallStress = descriptive['overall_stress'] as String?;
        if (overallStress != null && overallStress.toLowerCase() != 'unknown') {
          print('🔍 Found overall stress from descriptive: $overallStress');
          switch (overallStress.toLowerCase()) {
            case 'low':
              return S.of(context).crop_condition_healthy;
            case 'medium':
              return S.of(context).crop_condition_moderate_stress;
            case 'high':
              return S.of(context).crop_condition_high_stress;
            case 'severe':
              return S.of(context).crop_condition_critical_stress;
            default:
              return S.of(context).unknown;
          }
        } else {
          // If overall_stress is unknown, analyze individual stress levels
          final stressAnalysis = descriptive['stress_analysis'] as Map<String, dynamic>?;
          if (stressAnalysis != null) {
            print('🔍 Analyzing individual stress levels from stress_analysis');
            return _analyzeCropConditionFromStressAnalysis(stressAnalysis);
          }
        }
      }
    }
    
    // Fallback to sensor readings analysis
    if (monitoringState?.latestReadings.isNotEmpty == true) {
      final latestReading = monitoringState!.latestReadings.first;
      return _analyzeCropConditionFromSensor(latestReading);
    }
    
    print('🔍 No crop condition data available');
    return S.of(context).unknown;
  }

  String _analyzeCropConditionFromSensor(SensorReading reading) {
    // Analyze sensor readings to determine crop condition
    int issues = 0;
    
    // Check temperature
    if (reading.temperature < 15 || reading.temperature > 35) {
      issues++;
    }
    
    // Check soil moisture
    if (reading.soilMoisture < 30) {
      issues++;
    } else if (reading.soilMoisture > 80) {
      issues++;
    }
    
    // Check soil pH
    if (reading.pH < 6.0 || reading.pH > 7.5) {
      issues++;
    }
    
    // Check humidity
    if (reading.humidity < 30 || reading.humidity > 90) {
      issues++;
    }
    
    // Determine condition based on number of issues
    switch (issues) {
      case 0:
        return S.of(context).crop_condition_healthy;
      case 1:
        return S.of(context).crop_condition_moderate_stress;
      case 2:
        return S.of(context).crop_condition_high_stress;
      default:
        return S.of(context).crop_condition_critical_stress;
    }
  }

  String _analyzeCropConditionFromStressAnalysis(Map<String, dynamic> stressAnalysis) {
    // Count high stress factors
    int highStressCount = 0;
    int mediumStressCount = 0;
    
    for (final entry in stressAnalysis.entries) {
      final data = entry.value as Map<String, dynamic>?;
      if (data != null) {
        final stressLevel = data['stress_level'] as String? ?? 'low';
        switch (stressLevel.toLowerCase()) {
          case 'high':
            highStressCount++;
            break;
          case 'medium':
            mediumStressCount++;
            break;
        }
      }
    }
    
    // Determine condition based on stress levels
    if (highStressCount >= 3) {
      return S.of(context).crop_condition_critical_stress;
    } else if (highStressCount >= 2) {
      return S.of(context).crop_condition_high_stress;
    } else if (highStressCount >= 1 || mediumStressCount >= 2) {
      return S.of(context).crop_condition_moderate_stress;
    } else {
      return S.of(context).crop_condition_healthy;
    }
  }

  Color _getCropConditionColorFromStressAnalysis(Map<String, dynamic> stressAnalysis) {
    // Count high stress factors
    int highStressCount = 0;
    int mediumStressCount = 0;
    
    for (final entry in stressAnalysis.entries) {
      final data = entry.value as Map<String, dynamic>?;
      if (data != null) {
        final stressLevel = data['stress_level'] as String? ?? 'low';
        switch (stressLevel.toLowerCase()) {
          case 'high':
            highStressCount++;
            break;
          case 'medium':
            mediumStressCount++;
            break;
        }
      }
    }
    
    // Determine color based on stress levels
    if (highStressCount >= 3) {
      return Colors.red[800]!;
    } else if (highStressCount >= 2) {
      return Colors.red;
    } else if (highStressCount >= 1 || mediumStressCount >= 2) {
      return Colors.orange[800]!;
    } else {
      return MAIZE_PRIMARY;
    }
  }

  Color _getCropConditionColor(MonitoringState? monitoringState) {
    // First try to get from analytics data
    if (monitoringState?.farmAnalytics != null) {
      final analyticsData = monitoringState!.farmAnalytics!;
      
      // Try to get crop condition from prescriptive analytics first
      if (analyticsData['prescriptive'] != null) {
        final prescriptive = analyticsData['prescriptive'] as Map<String, dynamic>;
        final cropCondition = prescriptive['crop_condition'] as Map<String, dynamic>?;
        if (cropCondition != null) {
          final status = cropCondition['status'] as String? ?? 'Unknown';
          switch (status.toLowerCase()) {
            case 'healthy':
            case 'excellent':
              return MAIZE_PRIMARY;
            case 'moderate stress':
            case 'warning':
              return Colors.orange[800]!;
            case 'high stress':
            case 'critical stress':
              return Colors.red;
            default:
              return Colors.grey;
          }
        }
      }
      
      // Fallback to descriptive analytics
      final descriptive = analyticsData['descriptive'] as Map<String, dynamic>?;
      if (descriptive != null) {
        final overallStress = descriptive['overall_stress'] as String?;
        if (overallStress != null && overallStress.toLowerCase() != 'unknown') {
          switch (overallStress.toLowerCase()) {
            case 'low':
              return MAIZE_PRIMARY;
            case 'medium':
              return Colors.orange[800]!;
            case 'high':
              return Colors.red;
            case 'severe':
              return Colors.red[800]!;
            default:
              return Colors.grey;
          }
        } else {
          // If overall_stress is unknown, analyze individual stress levels
          final stressAnalysis = descriptive['stress_analysis'] as Map<String, dynamic>?;
          if (stressAnalysis != null) {
            return _getCropConditionColorFromStressAnalysis(stressAnalysis);
          }
        }
      }
    }
    
    // Fallback to sensor readings analysis
    if (monitoringState?.latestReadings.isNotEmpty == true) {
      final latestReading = monitoringState!.latestReadings.first;
      final condition = _analyzeCropConditionFromSensor(latestReading);
      switch (condition) {
        case 'Healthy':
          return MAIZE_PRIMARY;
        case 'Moderate stress':
          return Colors.orange[800]!;
        case 'High stress':
          return Colors.red;
        case 'Critical stress':
          return Colors.red[800]!;
        default:
          return Colors.grey;
      }
    }
    
    return Colors.grey;
  }

  Future<void> _showPrescriptionNotifications(List<dynamic> recommendations) async {
    print('🔔 Checking ${recommendations.length} recommendations for notifications');
    
    // Check if notifications are enabled
    final notificationsEnabled = await _notificationService.areNotificationsEnabled();
    print('🔔 Notification settings check: enabled = $notificationsEnabled');
    
    // Additional debug check with SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final prefsEnabled = prefs.getBool('notifications_enabled') ?? true;
    print('🔔 SharedPreferences check: enabled = $prefsEnabled');
    
    if (!notificationsEnabled || !prefsEnabled) {
      print('🔔 Notifications are disabled, skipping prescription notifications');
      return;
    }
    
    for (final rec in recommendations) {
      final recMap = rec as Map<String, dynamic>;
      final action = recMap['action'] as String? ?? 'Farm Task';
      final urgency = recMap['urgency'] as String? ?? 'LOW';
      final details = recMap['details'] as String? ?? '';
      final category = recMap['category'] as String? ?? 'general';
      final fieldId = recMap['field_id'] as String? ?? 'unknown';
      final fieldName = recMap['field_name'] as String? ?? 'Unknown Field';
      final parameter = recMap['parameter'] as String? ?? 'general';
      
      // Create unique ID for this prescription including field info
      final prescriptionId = '${action}_${urgency}_${category}_${fieldId}';
      
      // Check if this prescription is deleted
      final notificationStableId = '${action}_${fieldName}_${category}_${parameter}';
      final notificationTaskId = 'analytics_${notificationStableId.hashCode.abs()}';
      
      // Check if this task is deleted
      final notificationAuthState = context.read<AuthenticationBloc>().state;
      if (notificationAuthState.status == AuthenticationStatus.authenticated && notificationAuthState.user != null) {
        final prefs = await SharedPreferences.getInstance();
        final deletedKey = 'deleted_${notificationAuthState.user!.id}_$notificationTaskId';
        final isDeleted = prefs.getBool(deletedKey) ?? false;
        if (isDeleted) {
          print('🔔 Skipping deleted prescription notification: $notificationTaskId');
          continue;
        }
      }
      
      print('🔔 Checking prescription: $action (${urgency}) for $fieldName - Already notified: ${_notifiedPrescriptions.contains(prescriptionId)}');
      
      // Notify for all priority prescriptions (HIGH, URGENT, MEDIUM) that haven't been notified yet
      if ((urgency.toUpperCase() == 'HIGH' || urgency.toUpperCase() == 'URGENT' || urgency.toUpperCase() == 'MEDIUM') && 
          !_notifiedPrescriptions.contains(prescriptionId)) {
        
        print('🔔 Showing notification for: $action on $fieldName');
        
        _notificationService.showPrescriptionAlertNotificationWithCaching(
          title: '$action - $fieldName',
          message: details.isNotEmpty ? details : S.current.farm_task_requires_attention,
          priority: urgency,
          prescriptionId: prescriptionId,
          fieldName: fieldName,
        );
        
        // Mark as notified
        _notifiedPrescriptions.add(prescriptionId);
        print('🔔 Marked as notified: $prescriptionId');
      }
    }
  }

  // Helper method to format send time
  String _formatSendTime(String? timestamp) {
    if (timestamp == null) return S.of(context).just_now;
    
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inMinutes < 1) {
        return S.of(context).just_now;
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${dateTime.day}/${dateTime.month}';
      }
    } catch (e) {
      return S.of(context).just_now;
    }
  }

  String _mapUrgencyToPriority(String urgency) {
    switch (urgency.toUpperCase()) {
      case 'URGENT':
        return 'high';
      case 'HIGH':
        return 'high';
      case 'MEDIUM':
        return 'medium';
      case 'LOW':
        return 'low';
      default:
        return 'medium';
    }
  }

  DateTime _calculateDueDate(String timeline) {
    final now = DateTime.now();
    switch (timeline.toLowerCase()) {
      case 'today':
        return now.add(const Duration(hours: 2));
      case 'this week':
        return now.add(const Duration(days: 3));
      case 'next week':
        return now.add(const Duration(days: 7));
      default:
        return now.add(const Duration(days: 1));
    }
  }

  // Helper method to calculate deadline
  String _calculateDeadline(String timeline, String urgency) {
    final now = DateTime.now();
    
    // Parse timeline to determine deadline
    final lowerTimeline = timeline.toLowerCase();
    
    if (lowerTimeline == 'today') {
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59);
      final hoursLeft = endOfDay.difference(now).inHours;
      if (hoursLeft <= 0) return 'Overdue';
      return '${hoursLeft}h left';
    } else if (lowerTimeline.contains('this week')) {
      final endOfWeek = now.add(Duration(days: 7 - now.weekday));
      final daysLeft = endOfWeek.difference(now).inDays;
      if (daysLeft <= 0) return 'Overdue';
      return '${daysLeft}d left';
    } else if (lowerTimeline.contains('next') && lowerTimeline.contains('day')) {
      final match = RegExp(r'(\d+)').firstMatch(lowerTimeline);
      final days = int.tryParse(match?.group(1) ?? '1') ?? 1;
      final deadline = now.add(Duration(days: days));
      final daysLeft = deadline.difference(now).inDays;
      if (daysLeft <= 0) return 'Overdue';
      return '${daysLeft}d left';
    } else if (lowerTimeline.contains('week')) {
      final match = RegExp(r'(\d+)').firstMatch(lowerTimeline);
      final weeks = int.tryParse(match?.group(1) ?? '1') ?? 1;
      final deadline = now.add(Duration(days: weeks * 7));
      final daysLeft = deadline.difference(now).inDays;
      if (daysLeft <= 0) return 'Overdue';
      return '${daysLeft}d left';
    } else if (lowerTimeline.contains('hour')) {
      final match = RegExp(r'(\d+)').firstMatch(lowerTimeline);
      final hours = int.tryParse(match?.group(1) ?? '1') ?? 1;
      final deadline = now.add(Duration(hours: hours));
      final hoursLeft = deadline.difference(now).inHours;
      if (hoursLeft <= 0) return 'Overdue';
      return '${hoursLeft}h left';
    }
    
    // Default based on urgency
    switch (urgency.toUpperCase()) {
      case 'URGENT':
        return 'ASAP';
      case 'HIGH':
        return 'Today';
      case 'MEDIUM':
        return 'This week';
      case 'LOW':
      default:
        return 'Flexible';
    }
  }
}
