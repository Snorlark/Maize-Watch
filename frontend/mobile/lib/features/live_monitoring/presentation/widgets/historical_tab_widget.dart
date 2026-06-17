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
  int currentWeekOffset = 0;
  Timer? _timer;
  // Local loading flag: stays true from widget creation until the first BLoC
  // loading cycle completes. This prevents stale weeklyData from a previous
  // week/farm rendering before the fresh load finishes.
  bool _isLoadingLocal = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWeeklyData();
    });
    _timer = Timer.periodic(const Duration(minutes: 30), (timer) {
      _loadWeeklyData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadWeeklyData() {
    print('🔍 Loading weekly data: farmId=${widget.farmId} weekOffset=$currentWeekOffset');
    context.read<MonitoringBloc>().add(
      LoadWeeklyDataEvent(
        farmId: widget.farmId,
        fieldId: widget.fieldId,
        weekOffset: currentWeekOffset,
      ),
    );
  }

  void _navigateWeek(int offset) {
    if (currentWeekOffset + offset > 0) return;
    setState(() {
      currentWeekOffset += offset;
      // Force spinner immediately — BLoC event is still in the queue and the
      // old weeklyData has dates from the wrong week, which would render as
      // "No readings" until the new data arrives.
      _isLoadingLocal = true;
    });
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
    return BlocConsumer<MonitoringBloc, MonitoringState>(
      // Clear the local loading flag as soon as the BLoC finishes a weekly load
      // (isLoadingWeekly transitions true → false).
      listenWhen: (prev, curr) => prev.isLoadingWeekly && !curr.isLoadingWeekly,
      listener: (context, state) {
        if (_isLoadingLocal) {
          setState(() => _isLoadingLocal = false);
        }
      },
      buildWhen: (prev, curr) =>
          prev.isLoadingWeekly != curr.isLoadingWeekly ||
          prev.weeklyData != curr.weeklyData ||
          prev.weeklyError != curr.weeklyError,
      builder: (context, state) {
        print('🔍 HistoricalTab: isLoadingWeekly=${state.isLoadingWeekly} _isLoadingLocal=$_isLoadingLocal weeklyData=${state.weeklyData?.length ?? "null"}');
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
                          currentWeekOffset == 0 ? S.of(context).this_week : S.of(context).weekly_overview,
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

              // _isLoadingLocal guards against stale BLoC weeklyData showing
              // before the first fresh load completes (or during week navigation
              // before the new BLoC event is processed).
              if (state.isLoadingWeekly || _isLoadingLocal)
                _buildLoadingState()
              else if (state.weeklyData != null && state.weeklyData!.isNotEmpty)
                _buildDataContent(state.weeklyData!)
              else if (state.weeklyError != null)
                _buildErrorState(state.weeklyError!)
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
      height: 220.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: Colors.grey, size: 48.sp),
            verticalSpace(16.h),
            Text(
              'No data for this week',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            verticalSpace(8.h),
            Text(
              currentWeekOffset == 0
                  ? 'Sensor readings this week will appear here.\nTry a previous week or pull down to refresh.'
                  : 'No sensor readings found for this week.\nTry navigating to a different week.',
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            verticalSpace(16.h),
            ElevatedButton.icon(
              onPressed: _loadWeeklyData,
              icon: Icon(Icons.refresh, size: 16.sp),
              label: Text('Retry', style: TextStyle(fontSize: 13.sp)),
              style: ElevatedButton.styleFrom(
                backgroundColor: MAIZE_ACCENT,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              ),
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
              
              ParameterWidget(
                title: 'Temperature',
                unit: '°C',
                icon: Icons.thermostat,
                color: Colors.orange,
                data: weeklyData,
                parameter: 'temperature',
                currentValue: widget.currentMetrics?.temperature,
                optimalRange: _getOptimalRange('temperature'),
                weekOffset: currentWeekOffset,
              ),
              
              verticalSpace(20.h),
              
              ParameterWidget(
                title: 'Humidity',
                unit: '%',
                icon: Icons.water_drop,
                color: Colors.blue,
                data: weeklyData,
                parameter: 'humidity',
                currentValue: widget.currentMetrics?.humidity,
                optimalRange: _getOptimalRange('humidity'),
                weekOffset: currentWeekOffset,
              ),
              
              verticalSpace(20.h),
              
              ParameterWidget(
                title: 'Soil Moisture',
                unit: '%',
                icon: Icons.grass,
                color: Colors.green,
                data: weeklyData,
                parameter: 'soilMoisture',
                currentValue: widget.currentMetrics?.soilMoisture,
                optimalRange: _getOptimalRange('soilMoisture'),
                weekOffset: currentWeekOffset,
              ),
              
              verticalSpace(20.h),
              
              ParameterWidget(
                title: 'Soil pH',
                unit: 'pH',
                icon: Icons.science,
                color: Colors.lightBlue,
                data: weeklyData,
                parameter: 'soilPh',
                currentValue: widget.currentMetrics?.soilPh,
                optimalRange: _getOptimalRange('soilPh'),
                weekOffset: currentWeekOffset,
              ),
              
              verticalSpace(20.h),
              
              ParameterWidget(
                title: 'Light Intensity',
                unit: 'lux',
                icon: Icons.wb_sunny,
                color: Colors.amber,
                data: weeklyData,
                parameter: 'lightIntensity',
                currentValue: widget.currentMetrics?.lightIntensity,
                optimalRange: _getOptimalRange('lightIntensity'),
                weekOffset: currentWeekOffset,
              ),
              
              verticalSpace(50.h),
            ],
          ),
      );
  }
}
