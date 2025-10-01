import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import '../../../../core/theme/colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../generated/l10n.dart';
import '../bloc/monitoring_bloc.dart';
import 'parameter_widget.dart';
import '../../domain/entities/analytics_entities.dart';

class HistoricalTabWidget extends StatefulWidget {
  final String farmId;
  final String? fieldId;
  final VoidCallback? onBack;
  final MetricsModel? currentMetrics; // Add current metrics parameter
  final Map<String, dynamic>? analyticsData; // Add analytics data parameter

  const HistoricalTabWidget({
    super.key,
    required this.farmId,
    this.fieldId,
    this.onBack,
    this.currentMetrics, // Add current metrics parameter
    this.analyticsData, // Add analytics data parameter
  });

  @override
  State<HistoricalTabWidget> createState() => _HistoricalTabWidgetState();
}

class _HistoricalTabWidgetState extends State<HistoricalTabWidget> {
  int currentWeekOffset = 0; // 0 for current week, -1 for previous week, etc.
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Load data after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWeeklyData();
    });
    // Set up periodic refresh every 15 minutes (reduced frequency for cached data)
    _timer = Timer.periodic(const Duration(minutes: 15), (timer) {
      _loadWeeklyData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadWeeklyData() {
    // Only load if not already loading and no data exists for this week
    final state = context.read<MonitoringBloc>().state;
    if (!state.isLoading && (state.weeklyData == null || state.weeklyData!.isEmpty)) {
      print('🔍 Loading weekly data for farm: ${widget.farmId}, field: ${widget.fieldId}');
      context.read<MonitoringBloc>().add(
        LoadWeeklyDataEvent(
          farmId: widget.farmId,
          fieldId: widget.fieldId,
          weekOffset: currentWeekOffset,
        ),
      );
      
      // Set a timeout to show fallback data if server is too slow
      Timer(const Duration(seconds: 3), () {
        if (mounted && state.isLoading) {
          print('⚠️ Server timeout - showing fallback data');
          context.read<MonitoringBloc>().add(ClearErrorEvent());
        }
      });
    } else {
      print('⚠️ Weekly data already loaded or loading, skipping request');
    }
  }

  void _navigateWeek(int offset) {
    // Don't allow navigation to future weeks
    if (currentWeekOffset + offset > 0) {
      return; // Cannot go to future weeks
    }
    
    setState(() {
      currentWeekOffset += offset;
    });
    
    // Load data for the new week (this will load fresh data for different weeks)
    print('🔍 Navigating to week offset: $currentWeekOffset');
    context.read<MonitoringBloc>().add(
      LoadWeeklyDataEvent(
        farmId: widget.farmId,
        fieldId: widget.fieldId,
        weekOffset: currentWeekOffset,
      ),
    );
  }

  String _getOptimalRange(String parameter) {
    // Get optimal ranges from analytics data if available
    if (widget.analyticsData != null) {
      // Try different possible locations for optimal ranges
      final stressAnalysis = widget.analyticsData!['stress_analysis'] as Map<String, dynamic>?;
      final recommendations = widget.analyticsData!['recommendations'] as List<dynamic>?;
      final prescriptive = widget.analyticsData!['prescriptive'] as Map<String, dynamic>?;
      
      // Check stress analysis first
      if (stressAnalysis != null) {
        final paramData = stressAnalysis[parameter] as Map<String, dynamic>?;
        if (paramData != null) {
          final optimalRange = paramData['optimal_range'] as List<dynamic>?;
          if (optimalRange != null && optimalRange.length >= 2) {
            final min = optimalRange[0];
            final max = optimalRange[1];
            if (min != null && max != null) {
              return '${min.toStringAsFixed(1)}-${max.toStringAsFixed(1)}';
            }
          }
        }
      }
      
      // Check prescriptive data for optimal ranges
      if (prescriptive != null) {
        final optimalRanges = prescriptive['optimal_ranges'] as Map<String, dynamic>?;
        if (optimalRanges != null) {
          final range = optimalRanges[parameter] as Map<String, dynamic>?;
          if (range != null) {
            final min = range['min'] as num?;
            final max = range['max'] as num?;
            if (min != null && max != null) {
              return '${min.toStringAsFixed(1)}-${max.toStringAsFixed(1)}';
            }
          }
        }
      }
      
      // Check recommendations for parameter-specific optimal ranges
      if (recommendations != null) {
        for (final rec in recommendations) {
          if (rec is Map<String, dynamic>) {
            final recParam = rec['parameter'] as String?;
            if (recParam == parameter) {
              final optimalRange = rec['optimal_range'] as Map<String, dynamic>?;
              if (optimalRange != null) {
                final min = optimalRange['min'] as num?;
                final max = optimalRange['max'] as num?;
                if (min != null && max != null) {
                  return '${min.toStringAsFixed(1)}-${max.toStringAsFixed(1)}';
                }
              }
            }
          }
        }
      }
    }
    
    // Fallback to default ranges
    switch (parameter) {
      case 'temperature':
        return '20-30°C';
      case 'humidity':
        return '40-80%';
      case 'soilMoisture':
        return '30-70%';
      case 'soilPh':
        return '6.0-7.5';
      case 'lightIntensity':
        return '400-800';
      default:
        return 'N/A';
    }
  }

  bool _canNavigateNext() {
    return currentWeekOffset < 0; // Can only navigate forward if we're in past weeks
  }

  // Get the start of the calendar week (Sunday)
  DateTime getStartOfWeek(DateTime date) {
    // Convert to Sunday = 0, Monday = 1, ..., Saturday = 6
    int daysFromSunday = date.weekday == 7 ? 0 : date.weekday;
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: daysFromSunday));
  }

  // Get the end of the calendar week (Saturday at 23:59:59)
  DateTime getEndOfWeek(DateTime date) {
    DateTime startOfWeek = getStartOfWeek(date);
    return startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
  }

  // Get the current calendar week's start date
  DateTime getCurrentWeekStart() {
    final now = DateTime.now();
    return getStartOfWeek(now);
  }

  String getDateRange() {
    final currentWeekStart = getCurrentWeekStart();
    final targetWeekStart = currentWeekStart.add(Duration(days: currentWeekOffset * 7));
    final startDate = targetWeekStart;
    final endDate = getEndOfWeek(targetWeekStart);

    return '${_formatDate(startDate)} - ${_formatDate(endDate)}';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]}. ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MonitoringBloc, MonitoringState>(
      builder: (context, state) {
        print('🔍 HistoricalTab: State - isLoading: ${state.isLoading}, error: ${state.error}, weeklyData: ${state.weeklyData?.length ?? 0}');
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Weekly navigation header
              Container(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.chevron_left, color: MAIZE_ACCENT, size: 24.sp),
                      onPressed: () => _navigateWeek(-1),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    SizedBox(width: 16.w),
                    Column(
                      children: [
                        Text(
                          currentWeekOffset == 0 ? 'This Week' : 'Weekly Overview',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16.sp,
                            color: MAIZE_ACCENT,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          getDateRange(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 16.w),
                    IconButton(
                      icon: Icon(
                        Icons.chevron_right, 
                        color: _canNavigateNext() ? MAIZE_ACCENT : Colors.grey[400],
                        size: 24.sp,
                      ),
                      onPressed: _canNavigateNext() ? () => _navigateWeek(1) : null,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              
              verticalSpace(20.h),
              
              // Content based on state
              if (state.isLoading)
                _buildLoadingState()
              else if (state.weeklyData != null && state.weeklyData!.isNotEmpty)
                _buildDataContent(state.weeklyData!)
              else if (state.error != null)
                _buildErrorState(state.error!)
              else
                _buildNoDataState(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(MAIZE_ACCENT),
            ),
            verticalSpace(16.h),
            Text(
              'Loading historical data...',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      height: 200.h,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              Icon(Icons.error_outline, color: Colors.red, size: 40.sp),
              verticalSpace(12.h),
              Text(
                'Failed to load data',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
              verticalSpace(6.h),
              Text(
                error.contains('timeout') ? 'Request timeout. Please check your connection.' : error,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              verticalSpace(12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _loadWeeklyData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MAIZE_ACCENT,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    ),
                    child: Text(S.current.retry, style: TextStyle(fontSize: 12.sp)),
                  ),
                  SizedBox(width: 12.w),
                  OutlinedButton(
                    onPressed: () {
                      // Clear error and show no data state
                      context.read<MonitoringBloc>().add(ClearErrorEvent());
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    ),
                    child: Text(S.current.cancel, style: TextStyle(fontSize: 12.sp)),
                  ),
                ],
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildNoDataState() {
    return Container(
      height: 200.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: Colors.grey, size: 48.sp),
            verticalSpace(16.h),
            Text(
              'No historical data available',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            verticalSpace(8.h),
            Text(
              'Historical data will appear here once available',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataContent(List<Map<String, dynamic>> weeklyData) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadWeeklyData();
      },
      child: Column(
        children: [
              // Debug info (remove in production)
              Container(
                margin: EdgeInsets.only(bottom: 20.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: MAIZE_ACCENT.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Data points: ${weeklyData.length}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              
              ParameterWidget(
                title: 'Temperature',
                unit: '°C',
                icon: Icons.thermostat,
                color: Colors.orange,
                data: weeklyData,
                parameter: 'temperature',
                optimalRange: _getOptimalRange('temperature'),
                weekOffset: currentWeekOffset,
                currentValue: widget.currentMetrics?.temperature,
              ),
              
              verticalSpace(20.h),
              
              ParameterWidget(
                title: 'Humidity',
                unit: '%',
                icon: Icons.water_drop,
                color: Colors.blue,
                data: weeklyData,
                parameter: 'humidity',
                optimalRange: _getOptimalRange('humidity'),
                weekOffset: currentWeekOffset,
                currentValue: widget.currentMetrics?.humidity,
              ),
              
              verticalSpace(20.h),
              
              ParameterWidget(
                title: 'Soil Moisture',
                unit: '%',
                icon: Icons.grass,
                color: Colors.green,
                data: weeklyData,
                parameter: 'soilMoisture',
                optimalRange: _getOptimalRange('soilMoisture'),
                weekOffset: currentWeekOffset,
                currentValue: widget.currentMetrics?.soilMoisture,
              ),
              
              verticalSpace(20.h),
              
              ParameterWidget(
                title: 'Soil pH',
                unit: 'pH',
                icon: Icons.science,
                color: Colors.lightBlue,
                data: weeklyData,
                parameter: 'soilPh',
                optimalRange: _getOptimalRange('soilPh'),
                weekOffset: currentWeekOffset,
                currentValue: widget.currentMetrics?.soilPh,
              ),
              
              verticalSpace(20.h),
              
              ParameterWidget(
                title: 'Light Intensity',
                unit: 'lux',
                icon: Icons.wb_sunny,
                color: Colors.amber,
                data: weeklyData,
                parameter: 'lightIntensity',
                optimalRange: _getOptimalRange('lightIntensity'),
                weekOffset: currentWeekOffset,
                currentValue: widget.currentMetrics?.lightIntensity,
              ),
              
              verticalSpace(50.h),
            ],
          ),
      );
  }
}
