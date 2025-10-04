import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:mobile/features/live_monitoring/domain/usecases/get_localized_greeting.dart';
import 'package:mobile/generated/l10n.dart';
import 'package:mobile/core/services/prescription_translation_service.dart';
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
  
  // Analytics caching
  Map<String, dynamic>? _cachedAnalytics;
  DateTime? _lastAnalyticsLoad;
  DateTime? _lastNotificationCheck;
  static const Duration _analyticsCacheTimeout = Duration(minutes: 5);
        // static const Duration _notificationCooldown = Duration(seconds: 30); // Prevent notification spam - temporarily disabled for debugging

  // Load notification check timestamp from SharedPreferences
  Future<void> _loadNotificationCheckTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampString = prefs.getString('last_notification_check');
      if (timestampString != null) {
        _lastNotificationCheck = DateTime.parse(timestampString);
        print('🔔 Loaded notification check timestamp: $_lastNotificationCheck');
      }
    } catch (e) {
      print('🔔 Error loading notification check timestamp: $e');
    }
  }



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
    
    // Initialize notification processing flags (don't clear cache to allow stacking)
    _isNotificationProcessing = false;
    _lastNotificationTime = null;
    print('🔔 Initialized notification processing flags');

    // Don't clear notifications on init - let them persist
    // _clearExistingNotifications();

    // Load notification check timestamp
    _loadNotificationCheckTimestamp();

    // Load initial data
    _loadData();
    _animationController.forward();
    
    // Trigger notifications after a short delay to ensure data is loaded
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _triggerNotificationsOnScreenLoad();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh completion status when screen becomes visible
    _refreshCompletionStatus();
    
    // Listen for analytics data changes and trigger notifications
    _listenForAnalyticsAndTriggerNotifications();
  }

  void _loadData() {
    // Check if this is a new user session and force refresh if needed
    _checkAndForceRefreshForNewUser();
    
    // Load data with optimized caching
    _loadDataOptimized();
  }

  /// Check if this is a new user session and force refresh data
  Future<void> _checkAndForceRefreshForNewUser() async {
    try {
      final authState = context.read<AuthenticationBloc>().state;
      if (authState.status == AuthenticationStatus.authenticated && authState.user != null) {
        final userId = authState.user!.id;
        
        // Check if this is a new user session by looking for a flag
        final prefs = await SharedPreferences.getInstance();
        final lastUserId = prefs.getString('last_user_id');
        final isNewUserSession = lastUserId != userId;
        
        if (isNewUserSession) {
          print('🔄 LiveMonitoring: New user session detected (old: $lastUserId, new: $userId), forcing data refresh');
          
          // Update the last user ID
          await prefs.setString('last_user_id', userId);
          
          // Clear any cached data for this user
          await HomeScreenService.clearUserCache();
          
          // Force refresh farms data
          context.read<FarmBloc>().add(GetUserFarmsEvent(userId: userId));
          
          // Force refresh monitoring data
          context.read<MonitoringBloc>().add(LoadLatestReadingsEvent());
          
          print('🔄 LiveMonitoring: Forced data refresh for new user session');
        } else {
          print('🔄 LiveMonitoring: Same user session, using cached data');
        }
      }
    } catch (e) {
      print('🔄 LiveMonitoring: Error checking new user session: $e');
    }
  }

  /// Ensure field-specific analytics are loaded for all fields to enable prescriptions
  void _ensureFieldSpecificAnalyticsLoaded(List<Farm> farms) async {
    try {
      print('🌽 LiveMonitoring: Ensuring field-specific analytics are loaded for all fields');
      
      for (final farm in farms) {
        if (farm.id != null) {
          print('🌽 LiveMonitoring: Loading field-specific analytics for farm: ${farm.id} (${farm.farmName})');
          
          // Load field-specific analytics for each field in this farm
          for (final field in farm.fields) {
            print('🌽 LiveMonitoring: Loading field-specific analytics for field: ${field.fieldName}');
            
            // Load field-specific analytics for this field
            context.read<MonitoringBloc>().add(
              LoadWeeklyDataEvent(
                farmId: farm.id!, 
                fieldId: field.fieldName,
                weekOffset: 0
              )
            );
          }
        }
      }
      
      print('🌽 LiveMonitoring: Completed ensuring field-specific analytics for all fields');
    } catch (e) {
      print('🌽 LiveMonitoring: Error ensuring field-specific analytics: $e');
    }
  }

  /// Listen for analytics data changes and trigger notifications
  void _listenForAnalyticsAndTriggerNotifications() {
    // Listen to MonitoringBloc stream for analytics data changes
    context.read<MonitoringBloc>().stream.listen((monitoringState) {
      if (mounted && monitoringState.farmAnalytics != null) {
        print('🔔 LiveMonitoring: Analytics data available, triggering notifications');
        _triggerNotificationsOnScreenLoad();
      }
    });
  }

  /// Trigger notifications when live monitoring screen loads
  void _triggerNotificationsOnScreenLoad() async {
    try {
      print('🔔 LiveMonitoring: Triggering notifications on screen load');
      
      // Wait a bit for analytics to be processed
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Get current monitoring state
      final monitoringState = context.read<MonitoringBloc>().state;
      
      if (monitoringState.farmAnalytics != null) {
        print('🔔 LiveMonitoring: Found analytics data, processing for notifications');
        
        // Process analytics data for notifications
        final analyticsData = monitoringState.farmAnalytics!;
        List<dynamic> recommendations = [];
        
        if (analyticsData['prescriptive'] != null) {
          final prescriptive = analyticsData['prescriptive'] as Map<String, dynamic>;
          recommendations = prescriptive['recommendations'] as List<dynamic>? ?? [];
          print('🔔 LiveMonitoring: Found ${recommendations.length} prescriptive recommendations');
        }
        
        // If no prescriptive data, try to generate from stress analysis
        if (recommendations.isEmpty && analyticsData['descriptive'] != null) {
          final descriptive = analyticsData['descriptive'] as Map<String, dynamic>;
          final stressAnalysis = descriptive['stress_analysis'] as Map<String, dynamic>?;
          
          if (stressAnalysis != null) {
            print('🔔 LiveMonitoring: Generating recommendations from stress analysis');
            final farmState = context.read<FarmBloc>().state;
            if (farmState is FarmsLoaded) {
              recommendations = _generateRecommendationsFromStressAnalysis(stressAnalysis, farmState);
              print('🔔 LiveMonitoring: Generated ${recommendations.length} recommendations from stress analysis');
            }
          }
        }
        
        // Send notifications if we have recommendations
        if (recommendations.isNotEmpty) {
          print('🔔 LiveMonitoring: Sending ${recommendations.length} notifications on screen load');
          await _showPrescriptionNotifications(recommendations);
        } else {
          print('🔔 LiveMonitoring: No recommendations found for notifications');
        }
      } else {
        print('🔔 LiveMonitoring: No analytics data available for notifications');
      }
    } catch (e) {
      print('🔔 LiveMonitoring: Error triggering notifications on screen load: $e');
    }
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
            // Check if this is a new user session and force refresh if needed
            final prefs = await SharedPreferences.getInstance();
            final authState = context.read<AuthenticationBloc>().state;
            final currentUserId = authState.user?.id;
            final lastUserId = prefs.getString('last_user_id');
            final shouldForceRefresh = currentUserId != null && lastUserId != currentUserId;
            
            final homeData = await HomeScreenService.getHomeScreenData(
              farmId: selectedFarm.id,
              forceRefresh: shouldForceRefresh,
            );
            
            if (homeData.isNotEmpty) {
              print('🌽 LiveMonitoring: Loaded cached data - Analytics: ${homeData['analytics'] != null}, Prescriptions: ${homeData['prescriptions']?.length ?? 0}');
              
              // Analytics should already be loaded from splash screen, no need to reload
              print('🌽 LiveMonitoring: Using pre-loaded analytics from splash screen');
            }
            
            // Ensure field-specific analytics are loaded for all fields to enable prescriptions
            _ensureFieldSpecificAnalyticsLoaded(farmState.farms);
            
            // Trigger notifications when live monitoring screen loads
            _triggerNotificationsOnScreenLoad();
          } catch (e) {
            print('🌽 LiveMonitoring: Error loading cached data: $e');
          }
        }
      }
      
      // Load latest sensor readings only if not already loaded (pre-loaded from splash screen)
      print('🌽 LiveMonitoring: Checking if should load readings - isLoading: ${monitoringState.isLoading}, readings: ${monitoringState.latestReadings.length}');
      if (!monitoringState.isLoading && monitoringState.latestReadings.isEmpty) {
        print('🌽 LiveMonitoring: Loading latest readings (not pre-loaded)...');
        context.read<MonitoringBloc>().add(LoadLatestReadingsEvent());
      } else {
        print('🌽 LiveMonitoring: Using pre-loaded readings from splash screen or already loading');
      }
      
      // Fallback: Load analytics if not already loaded from splash screen
      if (farmState is FarmsLoaded && farmState.farms.isNotEmpty && monitoringState.farmAnalytics == null) {
        final selectedFarm = farmState.farms.first;
        print('🌽 LiveMonitoring: Fallback - Loading analytics for farm: ${selectedFarm.id}');
        context.read<MonitoringBloc>().add(LoadFarmAnalyticsEvent(farmId: selectedFarm.id ?? ''));
      } else if (monitoringState.farmAnalytics != null) {
        print('🌽 LiveMonitoring: Analytics already loaded from splash screen');
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
    // Don't clear notification tracking - let notifications persist
    // BackgroundNotificationService.clearNotificationTracking();
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
            Spacer(),
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

                // Initialize with null values to prevent fallback data flash
                double? temperature;
                double? humidity;
                double? windSpeed;
                String? weatherCondition;
                IconData? weatherIcon;
                String? weatherDescription;
                
                // Check if we have any data at all before showing fallback
                bool hasAnyData = false;
                bool isLoading = monitoringState.isLoading;

                // Check if we have analytics data with weather information
                final analyticsData = monitoringState.farmAnalytics;
                if (analyticsData != null && analyticsData['predictive'] != null) {
                  final predictive = analyticsData['predictive'] as Map<String, dynamic>;
                  if (predictive['weather_forecast'] != null) {
                    final weatherForecast = predictive['weather_forecast'] as Map<String, dynamic>;
                    if (weatherForecast['current'] != null) {
                      final currentWeather = weatherForecast['current'] as Map<String, dynamic>;
                      temperature = (currentWeather['temperature'] as num?)?.toDouble();
                      humidity = (currentWeather['humidity'] as num?)?.toDouble();
                      windSpeed = (currentWeather['wind_speed'] as num?)?.toDouble();
                      final rawCondition = currentWeather['condition'] as String?;
                      if (rawCondition != null) {
                      weatherCondition = _translateWeatherCondition(rawCondition);
                      weatherIcon = _getWeatherIcon(weatherCondition);
                      }
                      weatherDescription = _translateWeatherCondition(currentWeather['description'] as String? ?? rawCondition ?? 'Partly Cloudy');
                      
                      hasAnyData = true;
                      print('🎯 UI using analytics weather data: temp=${temperature}°C, humidity=${humidity}%');
                    }
                  }
                } else if (weatherData != null) {
                  // Fallback to weather API data
                  temperature = weatherData.temperature;
                  humidity = weatherData.humidity;
                  windSpeed = weatherData.windSpeed;
                  weatherCondition = _translateWeatherCondition(weatherData.condition);
                  weatherDescription = _translateWeatherCondition(weatherData.description);
                  weatherIcon = _getWeatherIcon(weatherData.condition);
                  
                  hasAnyData = true;
                  print('🎯 UI using weather API data: temp=${temperature}°C, humidity=${humidity}%');
                } else if (latestReading != null) {
                  // Fallback to sensor data
                  temperature = latestReading.temperature;
                  humidity = latestReading.humidity;
                  windSpeed = _calculateWindSpeed(latestReading.lightIntensity);
                  final rawCondition = _getWeatherCondition(
                    temperature,
                    humidity,
                    latestReading.lightIntensity,
                  );
                  weatherCondition = _translateWeatherCondition(rawCondition);
                  weatherDescription = weatherCondition;
                  weatherIcon = _getWeatherIcon(weatherCondition);
                  
                  hasAnyData = true;
                  print('🎯 UI using sensor data: temp=${temperature}°C, humidity=${humidity}%');
                }
                
                // Debug weather data status
                print('🌤️ Weather Debug - hasAnyData: $hasAnyData, isLoading: $isLoading');
                print('🌤️ Weather Debug - temperature: $temperature, humidity: $humidity, windSpeed: $windSpeed');
                print('🌤️ Weather Debug - weatherCondition: $weatherCondition, weatherDescription: $weatherDescription');
                
                // Only set fallback values if we have absolutely no data and not loading
                if (!hasAnyData && !isLoading) {
                  temperature ??= 16.0;
                  humidity ??= 72.5;
                  windSpeed ??= 5.2;
                  weatherCondition ??= S.of(context).partly_cloudy;
                  weatherIcon ??= Icons.cloud;
                  weatherDescription ??= S.of(context).partly_cloudy_description;
                  print('⚠️ UI using default fallback data - no data available');
                } else if (isLoading) {
                  // Show loading state instead of fallback data
                  temperature ??= 0.0;
                  humidity ??= 0.0;
                  windSpeed ??= 0.0;
                  weatherCondition ??= S.of(context).loading;
                  weatherIcon ??= Icons.cloud;
                  weatherDescription ??= S.of(context).loading;
                  print('🔄 UI showing loading state');
                } else {
                  // Ensure we have valid values even if some are null
                  temperature ??= 0.0;
                  humidity ??= 0.0;
                  windSpeed ??= 0.0;
                  weatherCondition ??= S.of(context).loading;
                  weatherIcon ??= Icons.cloud;
                  weatherDescription ??= S.of(context).loading;
                  print('🎯 UI using available data with null fallbacks');
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
                        temperature > 0 
                          ? Text(
                          '${temperature.toStringAsFixed(0)}°C',
                          style: TextStyle(
                            fontSize: 72.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 0.9,
                          ),
                            )
                          : SizedBox(
                              width: 60.w,
                              height: 60.h,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 3.0,
                          ),
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            verticalSpace(8),
                            Row(
                              children: [
                                ...[
                                Icon(
                                  weatherIcon,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                                horizontalSpace(8),
                                ],
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
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 8.h),
                            Text(
                              S.of(context).loading,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: MAIZE_ACCENT,
                              ),
                            ),
                          ],
                        ),
                      ),
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
    final urgency =  taskData?['urgency'] as String? ?? 'MEDIUM';
    final isCompleted = taskData?['isCompleted'] as bool? ?? false;
    final isLoading = taskData?['isLoading'] as bool? ?? false;
    
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
    
    // Show loading spinner only if this is specifically a loading task AND no other data is available
    if (isLoading && title == S.of(context).loading_analytics_data) {
      return Container(
        width: 155.w,
        height: 140.h,
        padding: EdgeInsets.all(kAppMediumPadding),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(MAIZE_PRIMARY),
              strokeWidth: 2.0,
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(
                color: MAIZE_ACCENT,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
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
                
                
                
                // Urgency indicator (shows completion status when completed)
                Container(
                 padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green[600] : actualColor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child:  Text(
                        isCompleted ? S.of(context).done : _getUrgencyText(urgency),
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
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
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
                
                // Check if analytics need to be loaded (not cached or expired)
                final shouldLoadAnalytics = monitoringState.farmAnalytics == null || 
                    _cachedAnalytics == null ||
                    _lastAnalyticsLoad == null ||
                    DateTime.now().difference(_lastAnalyticsLoad!) > _analyticsCacheTimeout;
                
                if (shouldLoadAnalytics) {
                  print('🌽 LiveMonitoring: Loading fresh analytics for farm: $firstFarmId');
                  context.read<MonitoringBloc>().add(
                    LoadFarmAnalyticsEvent(farmId: firstFarmId),
                  );
                } else {
                  final cacheAge = DateTime.now().difference(_lastAnalyticsLoad!);
                  print('🌽 LiveMonitoring: Using cached analytics (age: ${cacheAge.inMinutes} minutes)');
                  
                  // If using cached data, don't show notifications
                  if (cacheAge < _analyticsCacheTimeout) {
                    print('🌽 LiveMonitoring: Cached data is fresh, will skip notifications');
                  }
                }
                
                // Load weather data for the first farm
                if (monitoringState.weatherData == null) {
                  print('🌽 LiveMonitoring: Loading weather data for farm: $firstFarmId');
                  context.read<MonitoringBloc>().add(
                    LoadWeatherDataEvent(farmId: firstFarmId),
                  );
                } else {
                  print('🌽 LiveMonitoring: Weather data already loaded');
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            farmName,
                            style: TextTheme.of(
                              context,
                            ).bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                          ),
                          verticalSpace(1),
                          Text(
                              '$fieldCount ${S.of(context).fields_registered}',
                            style: TextTheme.of(
                              context,
                            ).bodySmall?.copyWith(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      ),
                      Spacer(),
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
                            label: Flexible(
                              child: Text(
                             S.of(context).add_field,
                             style: Theme.of(context).textTheme.bodySmall?.copyWith(
                               color: Colors.white,
                               fontWeight: FontWeight.w600,
                             ),
                             maxLines: 1,
                             overflow: TextOverflow.ellipsis,
                              ),
                           ),
                           style: ElevatedButton.styleFrom(
                             backgroundColor: MAIZE_PRIMARY,
                             padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                               vertical: 12.h,
                             ),
                             shape: RoundedRectangleBorder(
                               borderRadius: BorderRadius.circular(16.r),
                             ),
                              minimumSize: Size(0, 40.h),
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
      return S.of(context).partly_cloudy;
    } else if (lightIntensity > 40) {
      return S.of(context).cloudy;
    } else if (humidity > 85) {
      return S.of(context).rainy;
    } else {
      return S.of(context).overcast;
    }
  }

  IconData _getWeatherIcon(String condition) {
    // Handle both English and translated conditions
    final lowerCondition = condition.toLowerCase();
    if (lowerCondition.contains('sunny') || lowerCondition.contains('maalaga')) {
        return Icons.wb_sunny;
    } else if (lowerCondition.contains('partly') || lowerCondition.contains('bahagyang')) {
        return Icons.cloud;
    } else if (lowerCondition.contains('cloudy') || lowerCondition.contains('maulap')) {
        return Icons.cloud_outlined;
    } else if (lowerCondition.contains('rainy') || lowerCondition.contains('ulan')) {
        return Icons.grain;
    } else if (lowerCondition.contains('overcast') || lowerCondition.contains('makulimlim')) {
        return Icons.cloud_queue;
    } else {
        return Icons.cloud;
    }
  }

  String _translateWeatherCondition(String condition) {
    final lowerCondition = condition.toLowerCase().trim();
    print('🌤️ Translating weather condition: "$condition" -> "$lowerCondition"');
    
    switch (lowerCondition) {
      case 'sunny':
        return S.of(context).sunny;
      case 'partly cloudy':
      case 'partly_cloudy':
        return S.of(context).partly_cloudy;
      case 'cloudy':
        return S.of(context).cloudy;
      case 'rainy':
        return S.of(context).rainy;
      case 'overcast':
        return S.of(context).overcast;
      case 'clear':
        return S.of(context).sunny;
      default:
        print('🌤️ Unknown weather condition: "$condition", using partly cloudy as fallback');
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
    print('🚀 _generateDynamicTasks STARTED');
    final tasks = <Map<String, dynamic>>[];
    final now = DateTime.now();
    final Set<String> addedTaskIds = <String>{}; // Track added task IDs to prevent duplicates

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
      
      // Try to get analytics recommendations from monitoring state or cache
      Map<String, dynamic>? analyticsData = monitoringState.farmAnalytics;
      
      print('🔍 Raw analytics data from monitoring state: ${analyticsData != null ? "EXISTS" : "NULL"}');
      if (analyticsData != null) {
        print('🔍 Analytics keys: ${analyticsData.keys.toList()}');
      }
      
      // Debug farm state
      print('🔍 Farm State Type: ${farmState.runtimeType}');
      print('🔍 Is FarmsLoaded: ${farmState is FarmsLoaded}');
      if (farmState is FarmsLoaded) {
        print('🔍 Farms Count: ${farmState.farms.length}');
      }
      
      // If no analytics from monitoring state, try to get from HomeScreenService cache
      if (analyticsData == null && farmState is FarmsLoaded && farmState.farms.isNotEmpty) {
        try {
          final selectedFarm = farmState.farms.first;
          print('🔍 No analytics from monitoring state, trying HomeScreenService cache for farm: ${selectedFarm.id}');
          final homeData = await HomeScreenService.getHomeScreenData(
            farmId: selectedFarm.id,
            forceRefresh: false,
          );
          
          if (homeData['analytics'] != null) {
            analyticsData = homeData['analytics'] as Map<String, dynamic>;
            print('🔍 Found analytics data from HomeScreenService cache');
            print('🔍 HomeScreenService analytics keys: ${analyticsData!.keys.toList()}');
          }
        } catch (e) {
          print('🔍 Error getting analytics from HomeScreenService: $e');
        }
      }
      
      // CRITICAL: Force analytics data to be available for notifications
      if (analyticsData == null && farmState is FarmsLoaded && farmState.farms.isNotEmpty) {
        print('🚨 CRITICAL: No analytics data found, forcing analytics load for notifications');
        try {
          final selectedFarm = farmState.farms.first;
          print('🚨 Forcing analytics load for farm: ${selectedFarm.id}');
          
          // Force load analytics from MonitoringBloc
          context.read<MonitoringBloc>().add(LoadFarmAnalyticsEvent(farmId: selectedFarm.id ?? ''));
          
          // Wait a bit for the analytics to load
          await Future.delayed(const Duration(milliseconds: 500));
          
          // Try to get analytics again
          final currentState = context.read<MonitoringBloc>().state;
          if (currentState.farmAnalytics != null) {
            analyticsData = currentState.farmAnalytics;
            print('🚨 Successfully loaded analytics data for notifications');
            print('🚨 Analytics keys: ${analyticsData!.keys.toList()}');
          }
        } catch (e) {
          print('🚨 Error forcing analytics load: $e');
        }
      }
      
      // CRITICAL: If still no analytics data, force load it from HomeScreenService
      if (analyticsData == null && farmState is FarmsLoaded && farmState.farms.isNotEmpty) {
        try {
          final selectedFarm = farmState.farms.first;
          print('🔔 CRITICAL: No analytics data found, forcing fresh load for farm: ${selectedFarm.id}');
          final homeData = await HomeScreenService.getHomeScreenData(
            farmId: selectedFarm.id,
            forceRefresh: true, // Force refresh to get fresh data
          );
          
          if (homeData['analytics'] != null) {
            analyticsData = homeData['analytics'] as Map<String, dynamic>;
            print('🔔 CRITICAL: Forced fresh analytics data loaded');
            print('🔔 CRITICAL: Analytics keys: ${analyticsData!.keys.toList()}');
          } else {
            print('🔔 CRITICAL: Even forced refresh returned no analytics data!');
          }
        } catch (e) {
          print('🔔 CRITICAL: Error forcing fresh analytics load: $e');
        }
      }
      
      // Use cached data if available and not expired
      if (analyticsData == null && _cachedAnalytics != null && _lastAnalyticsLoad != null) {
        final cacheAge = DateTime.now().difference(_lastAnalyticsLoad!);
        if (cacheAge < _analyticsCacheTimeout) {
          analyticsData = _cachedAnalytics;
          print('🔍 Using cached analytics data (age: ${cacheAge.inMinutes} minutes)');
        } else {
          print('🔍 Cached analytics data expired (age: ${cacheAge.inMinutes} minutes)');
        }
      }
      
      // Cache analytics data for performance
      if (analyticsData != null) {
        _cachedAnalytics = analyticsData;
        _lastAnalyticsLoad = DateTime.now();
        print('🔍 Cached analytics data for performance');
      }

      // Debug: Print analytics data status
      print(
        '🔍 Analytics Data Status: ${analyticsData != null ? S.of(context).available : S.of(context).null_value}',
      );
      print('🔍 Monitoring State Loading: ${monitoringState.isLoading}');
      print('🔍 Cached Analytics Available: ${_cachedAnalytics != null}');
      if (_lastAnalyticsLoad != null) {
        final cacheAge = DateTime.now().difference(_lastAnalyticsLoad!);
        print('🔍 Cache Age: ${cacheAge.inMinutes} minutes');
      }
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

      print('🔔 PRE-NOTIFICATION CHECK: analyticsData = ${analyticsData != null ? "EXISTS" : "NULL"}');

      if (analyticsData != null) {
        print('🔔 Analytics data exists, checking for prescriptive...');
        // The complete analytics endpoint returns data directly with prescriptive key
        if (analyticsData['prescriptive'] != null) {
          final prescriptive = analyticsData['prescriptive'] as Map<String, dynamic>;
          recommendations = prescriptive['recommendations'] as List<dynamic>? ?? [];
          print('🔍 Found prescriptive recommendations: ${recommendations.length}');
          
          // Debug: Print all recommendations to see what we have
          for (int i = 0; i < recommendations.length; i++) {
            final rec = recommendations[i] as Map<String, dynamic>;
            print('🔍 Recommendation $i: ${rec['action']} - ${rec['category']} - ${rec['urgency']} - ${rec['field_name']}');
          }
        } else {
          print('🔔 WARNING: No prescriptive data in analytics!');
          
          // Try to generate recommendations from descriptive analytics if prescriptive is missing
          if (analyticsData['descriptive'] != null) {
            print('🔔 Attempting to generate recommendations from descriptive analytics...');
            final descriptive = analyticsData['descriptive'] as Map<String, dynamic>;
            final stressAnalysis = descriptive['stress_analysis'] as Map<String, dynamic>?;
            
            if (stressAnalysis != null) {
              print('🔔 Found stress analysis data, generating recommendations...');
              recommendations = _generateRecommendationsFromStressAnalysis(stressAnalysis, farmState);
              print('🔔 Generated ${recommendations.length} recommendations from stress analysis');
            }
          }
        }

        print('🔍 Final Recommendations Count: ${recommendations.length}');
      } else {
        print('🔔 WARNING: Analytics data is NULL - no recommendations will be processed!');
      }

      print('🔔 Recommendations isEmpty: ${recommendations.isEmpty}, Length: ${recommendations.length}');
      
      // CRITICAL: Always show notifications if we have recommendations, regardless of analytics data source
      if (recommendations.isNotEmpty) {
        print('🔔 Found ${recommendations.length} recommendations');
        
        // Always send notifications when we have recommendations (both during splash and live monitoring screen)
        print('🔔 CALLING _showPrescriptionNotifications NOW...');
        await _showPrescriptionNotifications(recommendations);
        print('🔔 _showPrescriptionNotifications COMPLETED');
        
        print('🔍 Processing ${recommendations.length} recommendations for task cards');
        
        // Convert analytics recommendations to task cards
        final Map<String, Map<String, dynamic>> uniqueRecommendations = {};
        
        for (int i = 0; i < recommendations.length; i++) {
          final rec = recommendations[i] as Map<String, dynamic>;
          print('🔍 Processing recommendation $i: ${rec['action']} for field ${rec['field_id']}');
          
          // Create a more unique key that includes timestamp and field info
          final action = rec['action'] as String? ?? S.of(context).unknown_action;
          final fieldId = rec['field_id'] as String? ?? 'unknown';
          final category = rec['category'] as String? ?? 'general';
          final parameter = rec['parameter'] as String? ?? 'general';
          final urgency = rec['urgency'] as String? ?? 'LOW';
          
          // Create unique key that prevents duplicates
          final uniqueKey = '${action}_${fieldId}_${category}_${parameter}_${urgency}';
          
          // Skip if we already processed this exact recommendation
          if (uniqueRecommendations.containsKey(uniqueKey)) {
            print('🔍 Skipping duplicate recommendation: $uniqueKey');
            continue;
          }
          
          // Check if this prescription is deleted
          final deletionStableId = '${action}_${rec['field_name']}_${category}_${parameter}';
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
          
          // Store unique recommendation
          uniqueRecommendations[uniqueKey] = rec;
        }
        
        // Process unique recommendations
        for (final rec in uniqueRecommendations.values) {
          final urgency = rec['urgency'] as String? ?? 'LOW';
          final timeline = rec['timeline'] as String? ?? '1 day';
          final action = rec['action'] as String? ?? 'Check farm';
          String details = rec['details'] as String? ?? '';
          String fieldName = rec['field_name'] as String? ?? S.of(context).unknown_field;
          
          // If details is empty, create specific details based on the action and field
          if (details.isEmpty) {
            details = 'Field $fieldName: ${action.toLowerCase()} required for optimal crop health';
            print('🔍 Generated fallback details: $details');
          }
          final category = rec['category'] as String? ?? 'general';
          // Get step-by-step instructions from translation service
          final instructions = await PrescriptionTranslationService.getTranslatedInstructions(action);
          print('🔍 Retrieved ${instructions.length} instructions for "$action"');
          
      // Extract field-specific information directly from recommendation data
          
      String soilType = rec['soil_type'] as String? ?? 'Loam';
      String growthStage = rec['growth_stage'] as String? ?? 'Unknown';
      String? fieldId = rec['field_id'] as String?;
      
      // If field name is unknown, try to get it from the farm data
      if (fieldName == S.of(context).unknown_field || fieldName.isEmpty) {
        final farmState = context.read<FarmBloc>().state;
        if (farmState is FarmsLoaded && farmState.farms.isNotEmpty) {
          final farm = farmState.farms.first;
          if (farm.fields.isNotEmpty) {
            fieldName = farm.fields.first.fieldName;
            fieldId = farm.fields.first.fieldName;
            print('🔍 Using fallback field name: $fieldName');
          }
        }
      }
      
      print('🔍 Final field name for prescription: $fieldName');
          final parameter = rec['parameter'] as String? ?? 'general';
          
      print('🔍 Using recommendation data directly: $fieldName, $soilType, $growthStage, $fieldId');
          
          print('🔍 Extracted field data - Name: $fieldName, Soil: $soilType, Stage: $growthStage, FieldId: $fieldId');

          // Translate the action and details using prescription translation service
          final translatedAction = await PrescriptionTranslationService.translatePrescriptionTitle(action);
          final translatedDetails = await PrescriptionTranslationService.translatePrescriptionDescription(details);

          // Format the title to show the actual action with better readability
          String formattedTitle = _formatRecommendationTitle(translatedAction, category);

          // Use details for status if available, otherwise use urgency
          String status =
              translatedDetails.isNotEmpty
                  ? _formatDetailsForStatus(translatedDetails, urgency, timeline)
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
          // Include fieldId to make it more unique and prevent duplicates
          final stableId = '${action}_${fieldId ?? fieldName}_${category}_${parameter}';
          final taskId = 'analytics_${stableId.hashCode.abs()}';
          
          // Check for duplicates in current session
          if (addedTaskIds.contains(taskId)) {
            print('🔍 Skipping duplicate task: $taskId');
            continue;
          }
          addedTaskIds.add(taskId);
          
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
            'description': translatedDetails,
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
            'details': translatedDetails,
            'sendTime': sendTime,
            'deadline': deadline,
            'instructions': instructions,
          });
        }
      } else if (monitoringState.isLoading && analyticsData == null && _cachedAnalytics == null && tasks.isEmpty && recommendations.isEmpty) {
        // Only show loading indicator when analytics is being processed AND we don't have any data (cached or fresh) AND no tasks have been generated AND no recommendations
        print('🔍 Showing loading indicator - isLoading: ${monitoringState.isLoading}, analyticsData: ${analyticsData != null}, cachedAnalytics: ${_cachedAnalytics != null}, tasks: ${tasks.length}, recommendations: ${recommendations.length}');
        tasks.add({
          'time':
              '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
          'title': S.of(context).loading_analytics_data,
          'status': S.of(context).processing,
          'color': Colors.grey[300],
          'isActive': false,
          'fieldName': S.of(context).system,
          'sendTime': S.of(context).just_now,
          'deadline': S.of(context).soon,
          'urgency': 'LOW',
          'instructions': [],
          'description': S.of(context).processing_farm_analytics_data,
          'isLoading': true, // Add flag to indicate this is a loading task
        });
      } else if (monitoringState.isLoading && (tasks.isNotEmpty || recommendations.isNotEmpty)) {
        // If we're loading but have tasks or recommendations, don't show loading indicator
        print('🔍 Loading but have ${tasks.length} tasks and ${recommendations.length} recommendations - not showing loading indicator');
      } else {
        // Show proper no-data message instead of fallback tasks
        tasks.add({
          'time':
              '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
          'title': '${S.of(context).no_tasks}\n${S.of(context).for_today}',
          'status': S.of(context).all_clear,
          'color': Colors.green[300],
          'isActive': false,
          'fieldName': S.of(context).all_fields,
          'sendTime': S.of(context).just_now,
          'deadline': 'N/A',
          'urgency': 'LOW',
          'instructions': [],
          'description': S.of(context).all_farm_operations_up_to_date,
        });
      }
    } else {
      // Default tasks when no farm data
      tasks.addAll([
        {
          'time': '${now.hour.toString().padLeft(2, '0')}:30',
          'title': '${S.of(context).setup}\n${S.of(context).farm}',
          'status': S.of(context).required,
          'color': MAIZE_PRIMARY,
          'isActive': true,
          'fieldName': S.of(context).new_farm,
          'sendTime': S.of(context).just_now,
          'deadline': S.of(context).today,
          'urgency': 'HIGH',
          'instructions': [S.of(context).register_farm_details, S.of(context).add_field_information, S.of(context).configure_sensor_settings],
          'description': S.of(context).complete_farm_registration_to_start_monitoring,
        },
        {
          'time': '${(now.hour + 1).toString().padLeft(2, '0')}:00',
          'title': '${S.of(context).add}\n${S.of(context).sensors}',
          'status': S.of(context).pending,
          'color': Colors.white,
          'isActive': false,
          'fieldName': S.of(context).all_fields,
          'sendTime': S.of(context).just_now,
          'deadline': S.of(context).this_week,
          'urgency': 'MEDIUM',
          'instructions': [S.of(context).install_soil_moisture_sensors, S.of(context).set_up_weather_station, S.of(context).connect_to_monitoring_system],
          'description': S.of(context).install_sensors_to_enable_real_time_monitoring,
        },
      ]);
    }

    // Cache tasks for refresh functionality
    _cachedTasks = tasks;
    
    // CRITICAL: Force notifications ONLY for real prescription tasks (not fallback/default tasks)
    if (tasks.isNotEmpty) {
      // Filter out fallback/default tasks - only process real prescription tasks
      final realPrescriptionTasks = tasks.where((task) {
        final taskId = task['id'] as String? ?? '';
        final category = task['category'] as String? ?? '';
        final fieldName = task['fieldName'] as String? ?? '';
        
        // Skip fallback tasks (they have specific IDs or are system tasks)
        if (taskId.startsWith('analytics_') && 
            category != 'general' && 
            fieldName != S.of(context).all_fields &&
            fieldName != S.of(context).system &&
            fieldName != S.of(context).new_farm) {
          return true; // This is a real prescription task
        }
        return false; // This is a fallback/default task
      }).toList();
      
      if (realPrescriptionTasks.isNotEmpty) {
        print('🔔 FORCING NOTIFICATIONS for ${realPrescriptionTasks.length} REAL prescription tasks (filtered from ${tasks.length} total)');
        final taskRecommendations = realPrescriptionTasks.map((task) => {
          'action': task['title'] ?? '',
          'category': task['category'] ?? '',
          'urgency': task['urgency'] ?? 'MEDIUM',
          'field_name': task['fieldName'] ?? '',
          'field_id': task['fieldName'] ?? '',
          'parameter': task['parameter'] ?? 'general',
          'details': task['description'] ?? '',
        }).toList();
        
        // Always send notifications for real prescription tasks (both during splash and live monitoring screen)
        print('🔔 CALLING _showPrescriptionNotifications for REAL prescription tasks NOW...');
        await _showPrescriptionNotifications(taskRecommendations);
        print('🔔 _showPrescriptionNotifications for REAL prescription tasks COMPLETED');
      } else {
        print('🔔 No real prescription tasks found - skipping notifications (${tasks.length} total tasks are fallback/default)');
      }
    }
    
    print('🚀 _generateDynamicTasks COMPLETED - returning ${tasks.length} tasks');
    print('🚀 Final task list: ${tasks.map((t) => t['title']).toList()}');
    return tasks;
  }

  // Generate recommendations from stress analysis when prescriptive data is missing
  List<Map<String, dynamic>> _generateRecommendationsFromStressAnalysis(
    Map<String, dynamic> stressAnalysis,
    FarmState farmState,
  ) {
    final recommendations = <Map<String, dynamic>>[];
    
    if (farmState is! FarmsLoaded || farmState.farms.isEmpty) {
      return recommendations;
    }
    
    final farm = farmState.farms.first;
    final field = farm.fields.isNotEmpty ? farm.fields.first : null;
    
    if (field == null) {
      return recommendations;
    }
    
    // Process each stress factor
    for (final entry in stressAnalysis.entries) {
      final parameter = entry.key;
      final data = entry.value as Map<String, dynamic>?;
      
      if (data == null) continue;
      
      final actualValue = data['actual_value'] as num?;
      final optimalRange = data['optimal_range'] as List<dynamic>?;
      final stressLevel = data['stress_level'] as String? ?? 'low';
      
      if (actualValue == null || optimalRange == null || stressLevel == 'low') {
        continue; // Skip if no issues
      }
      
      // Generate recommendation based on stress level and parameter
      String action = '';
      String category = '';
      String urgency = 'LOW';
      
      switch (parameter.toLowerCase()) {
        case 'temperature':
          if (stressLevel == 'high' || stressLevel == 'moderate') {
            if (actualValue > (optimalRange[1] as num)) {
              action = 'Manage high temperature stress';
              category = 'temperature_management';
              urgency = 'HIGH';
            } else if (actualValue < (optimalRange[0] as num)) {
              action = 'Protect from cold stress';
              category = 'temperature_management';
              urgency = 'MEDIUM';
            }
          }
          break;
          
        case 'humidity':
          if (stressLevel == 'high' || stressLevel == 'moderate') {
            if (actualValue > (optimalRange[1] as num)) {
              action = 'Reduce humidity to prevent disease';
              category = 'humidity_management';
              urgency = 'HIGH';
            } else if (actualValue < (optimalRange[0] as num)) {
              action = 'Increase humidity for optimal plant growth';
              category = 'humidity_management';
              urgency = 'MEDIUM';
            }
          }
          break;
          
        case 'soil moisture':
          if (stressLevel == 'high' || stressLevel == 'moderate') {
            if (actualValue > (optimalRange[1] as num)) {
              action = 'Improve drainage to prevent waterlogging';
              category = 'water_management';
              urgency = 'HIGH';
            } else if (actualValue < (optimalRange[0] as num)) {
              action = 'Increase irrigation frequency';
              category = 'water_management';
              urgency = 'URGENT';
            }
          }
          break;
          
        case 'soil ph':
          if (stressLevel == 'high' || stressLevel == 'moderate') {
            if (actualValue > (optimalRange[1] as num)) {
              action = 'Apply sulfur to decrease soil pH';
              category = 'soil_management';
              urgency = 'MEDIUM';
            } else if (actualValue < (optimalRange[0] as num)) {
              action = 'Apply lime to increase soil pH';
              category = 'soil_management';
              urgency = 'MEDIUM';
            }
          }
          break;
          
        case 'light intensity':
          if (stressLevel == 'high' || stressLevel == 'moderate') {
            if (actualValue < (optimalRange[0] as num)) {
              action = 'Adjust plant spacing for better light penetration';
              category = 'light_management';
              urgency = 'MEDIUM';
            }
          }
          break;
      }
      
      if (action.isNotEmpty) {
        // Create specific details based on the action and parameter
        String specificDetails = '';
        switch (parameter.toLowerCase()) {
          case 'temperature':
            if (actualValue > (optimalRange[1] as num)) {
              specificDetails = 'Temperature is too high (${actualValue}°C). Consider providing shade or improving ventilation.';
            } else if (actualValue < (optimalRange[0] as num)) {
              specificDetails = 'Temperature is too low (${actualValue}°C). Consider using row covers or heating systems.';
            }
            break;
          case 'humidity':
            if (actualValue > (optimalRange[1] as num)) {
              specificDetails = 'Humidity is too high (${actualValue}%). Improve air circulation to prevent disease.';
            } else if (actualValue < (optimalRange[0] as num)) {
              specificDetails = 'Humidity is too low (${actualValue}%). Consider misting or increasing irrigation.';
            }
            break;
          case 'soil moisture':
            if (actualValue > (optimalRange[1] as num)) {
              specificDetails = 'Soil moisture is too high (${actualValue}%). Improve drainage to prevent root rot.';
            } else if (actualValue < (optimalRange[0] as num)) {
              specificDetails = 'Soil moisture is too low (${actualValue}%). Increase irrigation frequency immediately.';
            }
            break;
          case 'soil ph':
            if (actualValue > (optimalRange[1] as num)) {
              specificDetails = 'Soil pH is too high (${actualValue}). Apply sulfur to lower pH.';
            } else if (actualValue < (optimalRange[0] as num)) {
              specificDetails = 'Soil pH is too low (${actualValue}). Apply lime to raise pH.';
            }
            break;
          case 'light intensity':
            if (actualValue < (optimalRange[0] as num)) {
              specificDetails = 'Light intensity is too low (${actualValue} lux). Adjust plant spacing for better light penetration.';
            }
            break;
          default:
            specificDetails = 'Field ${field.fieldName}: ${parameter.toLowerCase()} at ${actualValue}, ${stressLevel} stress level';
        }
        
        recommendations.add({
          'action': action,
          'category': category,
          'urgency': urgency,
          'field_name': field.fieldName,
          'field_id': field.fieldName, // Use field name as ID since Field doesn't have id property
          'parameter': parameter.toLowerCase(),
          'details': specificDetails,
          'timeline': urgency == 'URGENT' ? 'today' : urgency == 'HIGH' ? 'today' : 'this week',
          'soil_type': field.soilType,
          'growth_stage': field.growthStage,
        });
        
        print('🔔 Generated recommendation: $action for ${field.fieldName} (${parameter}: $actualValue, $stressLevel stress)');
      }
    }
    
    return recommendations;
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

  String _getUrgencyText(String urgency) {
    switch (urgency.toUpperCase()) {
      case 'URGENT':
        return S.of(context).urgent;
      case 'HIGH':
        return S.of(context).high;
      case 'MEDIUM':
        return S.of(context).medium;
      case 'LOW':
        return S.of(context).low;
      default:
        return urgency.toUpperCase();
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

  // Global notification tracking to prevent duplicates across multiple calls
  static final Set<String> _globalNotifiedPrescriptions = <String>{};
  static String? _lastNotificationDataHash;
  static bool _isNotificationProcessing = false;
  static DateTime? _lastNotificationTime;

  Future<void> _showPrescriptionNotifications(List<dynamic> recommendations) async {
    // Prevent concurrent processing
    if (_isNotificationProcessing) {
      print('🔔 Skipping notification processing - already in progress');
      return;
    }
    
    // Check if we've processed notifications recently (within 10 seconds)
    final now = DateTime.now();
    if (_lastNotificationTime != null && 
        now.difference(_lastNotificationTime!).inSeconds < 10) {
      print('🔔 Skipping notification processing - too soon after last call (${now.difference(_lastNotificationTime!).inSeconds}s ago)');
      return;
    }
    
    // Create a hash of the recommendations to prevent duplicate processing
    final recommendationsHash = recommendations.map((r) => r.toString()).join('|').hashCode.toString();
    
    if (_lastNotificationDataHash == recommendationsHash) {
      print('🔔 Skipping duplicate notification processing - same data as last call');
      return;
    }
    
    // Set processing lock
    _isNotificationProcessing = true;
    _lastNotificationDataHash = recommendationsHash;
    _lastNotificationTime = now;
    
    print('🔔 ===== NOTIFICATION DEBUG START =====');
    print('🔔 Checking ${recommendations.length} recommendations for notifications');
    print('🔔 Global notified prescriptions: ${_globalNotifiedPrescriptions.length}');
    
    // Force request permissions first
    print('🔔 Requesting notification permissions...');
    final permissionsGranted = await _notificationService.requestPermissions();
    print('🔔 Permission request result: $permissionsGranted');
    
    // Check if notifications are enabled
    final notificationsEnabled = await _notificationService.areNotificationsEnabled();
    print('🔔 Notification settings check: enabled = $notificationsEnabled');
    
    // Additional debug check with SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final prefsEnabled = prefs.getBool('notifications_enabled') ?? true;
    print('🔔 SharedPreferences check: enabled = $prefsEnabled');
    
    // Check if permissions are actually granted
    final hasPermissions = await _notificationService.arePermissionsGranted();
    print('🔔 Permissions granted check: $hasPermissions');
    
    if (!notificationsEnabled || !prefsEnabled || !hasPermissions) {
      print('🔔 Notifications are disabled or permissions not granted, skipping prescription notifications');
      print('🔔 Debug: enabled=$notificationsEnabled, prefs=$prefsEnabled, permissions=$hasPermissions');
      return;
    }
    
    print('🔔 Notifications are enabled and permissions granted, proceeding with notification logic');
    
    // Get user ID for notification tracking
    final authState = context.read<AuthenticationBloc>().state;
    if (authState.status != AuthenticationStatus.authenticated || authState.user == null) {
      print('🔔 User not authenticated, skipping notifications');
      return;
    }
    
    final userId = authState.user!.id;
    final notificationKey = 'notified_prescriptions_$userId';
    
    // Load previously notified prescriptions
    final notifiedPrescriptionsJson = prefs.getString(notificationKey);
    Set<String> previouslyNotified = {};
    if (notifiedPrescriptionsJson != null) {
      try {
        final List<dynamic> notifiedList = jsonDecode(notifiedPrescriptionsJson);
        previouslyNotified = Set<String>.from(notifiedList);
        print('🔔 Loaded ${previouslyNotified.length} previously notified prescriptions');
        print('🔔 Previously notified: ${previouslyNotified.toList()}');
      } catch (e) {
        print('🔔 Error loading notified prescriptions: $e');
      }
    }
    
    // DON'T clear notification cache - let notifications stack up
    print('🔔 Using existing notification cache to allow stacking');
    print('🔔 Previously notified: ${previouslyNotified.length} prescriptions');
    
    final Set<String> newNotifications = {};
    
    for (final rec in recommendations) {
      final recMap = rec as Map<String, dynamic>;
      final action = recMap['action'] as String? ?? S.of(context).farm_task;
      final urgency = recMap['urgency'] as String? ?? 'LOW';
      final details = recMap['details'] as String? ?? '';
      final category = recMap['category'] as String? ?? 'general';
      final fieldId = recMap['field_id'] as String? ?? 'unknown';
      final fieldName = recMap['field_name'] as String? ?? S.of(context).unknown_field;
      final parameter = recMap['parameter'] as String? ?? 'general';
      
      print('🔍 PROCESSING PRESCRIPTION: $action');
      print('🔍 Category: $category, Parameter: $parameter, Urgency: $urgency');
      print('🔍 Field: $fieldName ($fieldId)');
      print('🔍 Details: $details');
      
      // Create unique ID for this prescription including field info
      final prescriptionId = '${action}_${fieldName}_${category}_${parameter}_${urgency}';
      
      print('🔍 Generated prescription ID: $prescriptionId');
      print('🔍 Full prescription data: action=$action, fieldName=$fieldName, category=$category, parameter=$parameter, urgency=$urgency');
      
      // Check if this prescription is deleted
      final notificationStableId = '${action}_${fieldName}_${category}_${parameter}';
      final notificationTaskId = 'analytics_${notificationStableId.hashCode.abs()}';
      
      // Check if this task is deleted
      final deletedKey = 'deleted_${userId}_$notificationTaskId';
        final isDeleted = prefs.getBool(deletedKey) ?? false;
        if (isDeleted) {
          print('🔔 Skipping deleted prescription notification: $notificationTaskId');
          continue;
      }
      
      print('🔔 Checking prescription: $action (${urgency}) for $fieldName - Previously notified: ${previouslyNotified.contains(prescriptionId)}');
      
      // Check if this prescription should show notification (only check persistent cache, not global)
      final shouldNotify = !previouslyNotified.contains(prescriptionId);
      
      print('🔔 Prescription: $action, Priority: $urgency, Should notify: $shouldNotify');
      print('🔔 Previously notified: ${previouslyNotified.contains(prescriptionId)}');
      print('🔔 Session notified: ${_notifiedPrescriptions.contains(prescriptionId)}');
      
      if (shouldNotify) {
        // Allow more notifications to stack up (increased limit)
        if (newNotifications.length < 10) { // Increased limit to allow more notifications to stack
          print('🔔 Showing ${urgency} notification for: $action on $fieldName');
          
          // Translate notification content
          final translatedAction = await PrescriptionTranslationService.translatePrescriptionTitle(action);
          final translatedDetails = await PrescriptionTranslationService.translatePrescriptionDescription(details);
          
          print('🔍 Original action: "$action"');
          print('🔍 Translated action: "$translatedAction"');
          
          // Show background notification
          print('🔔 CALLING showPrescriptionAlertNotificationWithCaching...');
          print('🔔 Title: $translatedAction - $fieldName');
          print('🔔 Message: ${translatedDetails.isNotEmpty ? translatedDetails : S.of(context).farm_task_requires_attention}');
          print('🔔 Priority: $urgency');
          
          await _notificationService.showPrescriptionAlertNotificationWithCaching(
            title: '$translatedAction - $fieldName',
            message: translatedDetails.isNotEmpty ? translatedDetails : S.of(context).farm_task_requires_attention,
          priority: urgency,
          prescriptionId: prescriptionId,
          fieldName: fieldName,
        );
        
          print('🔔 showPrescriptionAlertNotificationWithCaching COMPLETED');
        
        // Mark as notified in persistent storage only (allow stacking)
        newNotifications.add(prescriptionId);
        print('🔔 Marked as notified: $prescriptionId');
        
        // Add small delay between notifications to prevent spam
        if (newNotifications.length < 10) {
          await Future.delayed(Duration(milliseconds: 500)); // Reduced delay for faster stacking
        }
        } else {
          print('🔔 Skipping ${urgency} notification - limit reached (${newNotifications.length})');
        }
      } else {
        print('🔔 Skipping notification for: $action (${urgency}) - already notified or low priority');
      }
    }
    
    // Update persistent storage with new notifications
    if (newNotifications.isNotEmpty) {
      final updatedNotified = {...previouslyNotified, ...newNotifications};
      await prefs.setString(notificationKey, jsonEncode(updatedNotified.toList()));
      
      // Update notification check timestamp
      _lastNotificationCheck = DateTime.now();
      await prefs.setString('last_notification_check', _lastNotificationCheck!.toIso8601String());
      
      print('🔔 Updated persistent notification tracking with ${newNotifications.length} new notifications');
    } else {
      print('🔔 No new notifications to show');
    }
    print('🔔 ===== NOTIFICATION DEBUG END =====');
    
    // Release processing lock
    _isNotificationProcessing = false;
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
        return S.of(context).this_week;
      case 'LOW':
      default:
        return 'Flexible';
    }
  }
}
