import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mobile/features/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:mobile/features/farm/presentation/bloc/farm_bloc.dart';
import 'growth_progress_widget.dart';
import '../../../farm/domain/entities/farm.dart';
import '../../domain/entities/sensor_reading.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/colors.dart';
import '../bloc/monitoring_bloc.dart';
import '../bloc/analytics_bloc.dart';
import '../../domain/entities/analytics_entities.dart';
import '../../../../core/di/injection_container.dart';

class FarmDetailWidget extends StatefulWidget {
  final Farm farm;
  final List<Sensor> sensors;
  final List<SensorReading> sensorReadings;
  final VoidCallback onBack;
  final Field? selectedField; // Add selected field parameter

  const FarmDetailWidget({
    super.key,
    required this.farm,
    required this.sensorReadings,
    required this.onBack,
    this.selectedField,
    required this.sensors,
  });

  @override
  State<FarmDetailWidget> createState() => _FarmDetailWidgetState();
}

class _FarmDetailWidgetState extends State<FarmDetailWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  late final AnalyticsBloc _analyticsBloc;

  // Analytics data
  CropConditionModel? _cropCondition;
  MetricsModel? _currentMetrics;
  WeeklyDataModel? _weeklyData;
  GrowthStageAnalysisModel? _growthStageAnalysis;
  bool _isLoadingAnalytics = false;
  String? _analyticsError;

  @override
  void initState() {
    super.initState();
    _analyticsBloc = sl<AnalyticsBloc>();
    _tabController = TabController(length: 3, vsync: this); // Changed to 3 tabs
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });

    // Load field-specific data when widget initializes
    _loadFieldData();
    // Defer analytics load until after first build so BlocProvider is in the tree
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnalyticsData();
    });
  }

  void _loadFieldData() {
    // Load sensor readings for the selected field
    if (widget.selectedField != null && widget.farm.id != null) {
      context.read<MonitoringBloc>().add(
        LoadHistoricalReadingsEvent(farmId: widget.farm.id!, days: 7),
      );
    }
  }

  void _loadAnalyticsData() {
    if (widget.farm.id == null) return;

    _analyticsBloc.add(LoadAnalyticsData(
      farmId: widget.farm.id!,
      fieldId: widget.selectedField?.fieldName,
    ));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _analyticsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _analyticsBloc,
      child: BlocListener<AnalyticsBloc, AnalyticsState>(
        listener: (context, state) {
          if (state is AnalyticsLoaded) {
            setState(() {
              _cropCondition = state.cropCondition;
              _currentMetrics = state.currentMetrics;
              _weeklyData = state.weeklyData;
              _growthStageAnalysis = state.growthStageAnalysis;
              _isLoadingAnalytics = false;
              _analyticsError = null;
            });
          } else if (state is AnalyticsError) {
            setState(() {
              _isLoadingAnalytics = false;
              _analyticsError = state.message;
            });
          } else if (state is AnalyticsLoading) {
            setState(() {
              _isLoadingAnalytics = true;
              _analyticsError = null;
            });
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              // Main scrollable content
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Hero section with growth progress
                      _buildHeroSection(),

                      // Overlaid field details card
                      Transform.translate(
                        offset: Offset(
                          0,
                          -90.h,
                        ), // Adjust this value to control the overlap
                        child: Column(
                          children: [
                            _buildFieldDetailsCard(),

                            verticalSpace(kAppMediumGap),
                            // Tab navigation
                            _buildTabNavigation(),

                            verticalSpace(kAppMediumGap),

                            // Tab content
                            _buildTabContent(),

                            SizedBox(height: 40.h), // Bottom padding
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Header with back button
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: kAppSmallPadding,
                      vertical: 8.h,
                    ),
                    child: Row(
                      children: [
                        _buildCircleIconButton(
                          icon: Icons.arrow_back,
                          onTap: widget.onBack,
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      height: 370.h, // Adjusted height for the growth progress widget
      padding: EdgeInsets.only(bottom: 24.h),
      decoration: BoxDecoration(
        color: MAIZE_PRIMARY,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
        ),
      ),
      child: Stack(
        children: [
          // Growth progress widget
          Center(
            child: GrowthProgressWidget(
              currentGrowthStage:
                  widget.selectedField?.growthStage ??
                  (widget.farm.fields.isNotEmpty
                      ? widget.farm.fields.first.growthStage
                      : 'VE'),
              plantingDate:
                  widget.selectedField?.plantingDate ??
                  (widget.farm.fields.isNotEmpty
                      ? widget.farm.fields.first.plantingDate
                      : DateTime.now()),
              historicalData: widget.sensorReadings,
              onStageChange: () {
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: MAIZE_ACCENT, size: 20.sp),
      ),
    );
  }

  Widget _buildFieldDetailsCard() {
    final selectedField =
        widget.selectedField ??
        (widget.farm.fields.isNotEmpty ? widget.farm.fields.first : null);

    return BlocBuilder<FarmBloc, FarmState>(
      builder: (context, farmState) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(kAppMediumPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r), //
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selectedField?.fieldName ?? widget.farm.farmName,
                style: TextTheme.of(context).headlineMedium?.copyWith(
                  fontWeight: FontWeight.w300,
                  fontSize: 30.sp,
                ),
              ),

              verticalSpace(5),

              BlocBuilder<AuthenticationBloc, AuthenticationState>(
                builder: (context, state) {
                  return Text(
                    '${state.user?.address['municipality']}, ${state.user?.address['province']}', // Or add a location property to your farm model
                    style: TextTheme.of(
                      context,
                    ).bodySmall?.copyWith(color: MAIZE_ACCENT.withOpacity(0.7)),
                  );
                },
              ),

              verticalSpace(12),

              Column(
                children: [
                  Wrap(
                    spacing: 12.w, // horizontal spacing between items
                    runSpacing: 8.h, // vertical spacing when wrapping
                    children: [
                      if (selectedField != null) ...[
                        // Soil type
                        if (selectedField.sensors.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: kAppSmallGap,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: MAIZE_ACCENT.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: MAIZE_ACCENT,
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.grass,
                                  color: MAIZE_ACCENT.withOpacity(0.8),
                                  size: 18.sp,
                                ),
                                SizedBox(width: 8.w),
                                Flexible(
                                  child: Text(
                                    selectedField.sensors.first.soilType,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.copyWith(
                                      color: MAIZE_ACCENT.withOpacity(0.8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: kAppSmallGap,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: MAIZE_ACCENT.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: MAIZE_ACCENT, width: 0.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.date_range,
                                color: MAIZE_ACCENT.withOpacity(0.8),
                                size: 18.sp,
                              ),
                              SizedBox(width: 8.w),
                              Flexible(
                                child: Text(
                                  '${selectedField.plantingDate.day}/${selectedField.plantingDate.month}/${selectedField.plantingDate.year}',
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(
                                    color: MAIZE_ACCENT.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Sensor count (if any)
                        if (selectedField.sensors.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: kAppSmallGap,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: MAIZE_ACCENT.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: MAIZE_ACCENT,
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.sensors,
                                  color: MAIZE_ACCENT.withOpacity(0.8),
                                  size: 18.sp,
                                ),
                                SizedBox(width: 8.w),
                                Flexible(
                                  child: Text(
                                    'Devices: ${selectedField.sensors.length}',
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.copyWith(
                                      color: MAIZE_ACCENT.withOpacity(0.8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ] else if (widget.farm.fields.isNotEmpty) ...[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.sensors,
                              color: MAIZE_PRIMARY,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Flexible(
                              child: Text(
                                'Total Sensors: ${widget.farm.fields.fold<int>(0, (sum, field) => sum + field.sensors.length)}',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),

                  SizedBox(height: 16.h), // Space between sections
                  // Crop Condition Section
                  if (_isLoadingAnalytics)
                    _buildLoadingIndicator()
                  else if (_analyticsError != null)
                    _buildErrorIndicator()
                  else if (_cropCondition != null)
                    _buildCropConditionCard()
                  else
                    _buildNoDataIndicator(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20.w,
            height: 20.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(MAIZE_PRIMARY),
            ),
          ),
          horizontalSpace(12),
          Text(
            'Loading crop condition...',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorIndicator() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600], size: 20.sp),
          horizontalSpace(12),
          Expanded(
            child: Text(
              _analyticsError ?? 'Failed to load crop condition',
              style: TextStyle(fontSize: 14.sp, color: Colors.red[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataIndicator() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey[600], size: 20.sp),
          horizontalSpace(12),
          Text(
            'No analytics data available',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildCropConditionCard() {
    if (_cropCondition == null) return SizedBox.shrink();

    final condition = _cropCondition!;
    final color = Color(int.parse(condition.color.replaceFirst('#', '0xFF')));

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(
                  _getConditionIcon(condition.icon),
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
              horizontalSpace(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Corn Condition',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    Text(
                      condition.status,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          verticalSpace(12),
          Text(
            condition.message,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getConditionIcon(String icon) {
    switch (icon) {
      case 'excellent':
        return Icons.eco;
      case 'good':
        return Icons.thumb_up;
      case 'normal':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'critical':
        return Icons.error;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildTabNavigation() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: kAppMediumPadding),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25.r),
      ),
      child: Row(
        children: [
          _buildTabButton('Overview', 0),
          _buildTabButton('Historical', 1),
          _buildTabButton('Growth Stage', 2),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
            _tabController.animateTo(index);
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? MAIZE_ACCENT : Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildHistoricalTab();
      case 2:
        return _buildGrowthStageTab();
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    if (_isLoadingAnalytics) {
      return _buildLoadingState();
    }

    if (_analyticsError != null) {
      return _buildErrorState();
    }

    if (_currentMetrics == null) {
      return _buildNoDataState();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          verticalSpace(kAppMediumGap),
          // 5 Key Metrics Grid
          _buildKeyMetricsGrid(),

          verticalSpace(24),
        ],
      ),
    );
  }

  Widget _buildKeyMetricsGrid() {
    final metrics = _currentMetrics!;

    return Column(
      children: [
        // First row - Soil pH and Soil Moisture
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Soil pH',
                '${metrics.soilPh.toStringAsFixed(1)}',
                'pH',
                Icons.science,
                _getSoilPhColor(metrics.soilPh),
              ),
            ),
            horizontalSpace(12),
            Expanded(
              child: _buildMetricCard(
                'Soil Moisture',
                '${metrics.soilMoisture.toStringAsFixed(0)}%',
                '',
                Icons.water_drop,
                _getSoilMoistureColor(metrics.soilMoisture),
              ),
            ),
          ],
        ),
        verticalSpace(12),
        // Second row - Temperature and Humidity
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Temperature',
                '${metrics.temperature.toStringAsFixed(0)}°C',
                '',
                Icons.thermostat,
                _getTemperatureColor(metrics.temperature),
              ),
            ),
            horizontalSpace(12),
            Expanded(
              child: _buildMetricCard(
                'Humidity',
                '${metrics.humidity.toStringAsFixed(0)}%',
                '',
                Icons.eco,
                _getHumidityColor(metrics.humidity),
              ),
            ),
          ],
        ),
        verticalSpace(12),
        // Third row - Light Intensity (full width)
        _buildMetricCard(
          'Light Intensity',
          '${metrics.lightIntensity.toStringAsFixed(0)} lux',
          '',
          Icons.light_mode,
          _getLightIntensityColor(metrics.lightIntensity),
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String unit,
    IconData icon,
    Color color, {
    bool isFullWidth = false,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          verticalSpace(12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          verticalSpace(4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: MAIZE_ACCENT,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: EdgeInsets.all(40.w),
      child: Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(MAIZE_PRIMARY),
          ),
          verticalSpace(16),
          Text(
            'Loading metrics...',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: EdgeInsets.all(40.w),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 48.sp),
          verticalSpace(16),
          Text(
            'Failed to load metrics',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          verticalSpace(8),
          Text(
            _analyticsError ?? 'Unknown error',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState() {
    return Container(
      padding: EdgeInsets.all(40.w),
      child: Column(
        children: [
          Icon(Icons.info_outline, color: Colors.grey, size: 48.sp),
          verticalSpace(16),
          Text(
            'No metrics available',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          verticalSpace(8),
          Text(
            'Analytics data will appear here once available',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoricalTab() {
    if (_isLoadingAnalytics) {
      return _buildLoadingState();
    }

    if (_analyticsError != null) {
      return _buildErrorState();
    }

    if (_weeklyData == null) {
      return _buildNoDataState();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          // Weekly data charts for each metric
          _buildWeeklyCharts(),
          verticalSpace(20),
          // Summary statistics
          _buildWeeklySummary(),
        ],
      ),
    );
  }

  Widget _buildWeeklyCharts() {
    return Column(
      children: [
        _buildMetricChart(
          'Soil pH',
          _weeklyData!.dailyData.map((d) => d.soilPh).toList(),
          Colors.red,
        ),
        verticalSpace(16),
        _buildMetricChart(
          'Soil Moisture (%)',
          _weeklyData!.dailyData.map((d) => d.soilMoisture).toList(),
          Colors.blue,
        ),
        verticalSpace(16),
        _buildMetricChart(
          'Temperature (°C)',
          _weeklyData!.dailyData.map((d) => d.temperature).toList(),
          Colors.orange,
        ),
        verticalSpace(16),
        _buildMetricChart(
          'Humidity (%)',
          _weeklyData!.dailyData.map((d) => d.humidity).toList(),
          Colors.green,
        ),
        verticalSpace(16),
        _buildMetricChart(
          'Light Intensity (lux)',
          _weeklyData!.dailyData.map((d) => d.lightIntensity).toList(),
          Colors.amber,
        ),
      ],
    );
  }

  Widget _buildMetricChart(String title, List<double> values, Color color) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: MAIZE_ACCENT,
            ),
          ),
          verticalSpace(12),
          SizedBox(
            height: 120.h,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY:
                    values.isNotEmpty
                        ? values.reduce((a, b) => a > b ? a : b) + 2
                        : 10,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final days = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun',
                        ];
                        return Text(
                          days[value.toInt() % 7],
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups:
                    values.asMap().entries.map((entry) {
                      final index = entry.key;
                      final value = entry.value;
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: value,
                            color: color,
                            width: 16.w,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ],
                      );
                    }).toList(),
                gridData: FlGridData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySummary() {
    if (_weeklyData?.summary.isEmpty != false) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Summary',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: MAIZE_ACCENT,
            ),
          ),
          verticalSpace(12),
          Text(
            'Data collected over the past 7 days',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthStageTab() {
    if (_isLoadingAnalytics) {
      return _buildLoadingState();
    }

    if (_analyticsError != null) {
      return _buildErrorState();
    }

    if (_growthStageAnalysis == null) {
      return _buildNoDataState();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          // Current growth stage info
          _buildCurrentGrowthStage(),
          verticalSpace(20),
          // Growth stage progress table
          _buildGrowthStageTable(),
          verticalSpace(20),
          // Expected harvest info
          _buildHarvestInfo(),
        ],
      ),
    );
  }

  Widget _buildCurrentGrowthStage() {
    final analysis = _growthStageAnalysis!;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  color: MAIZE_PRIMARY.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.eco, color: MAIZE_PRIMARY, size: 30.sp),
              ),
              horizontalSpace(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Stage',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      analysis.currentStage,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: MAIZE_ACCENT,
                      ),
                    ),
                    Text(
                      '${analysis.progressPercentage}% Complete',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: MAIZE_PRIMARY,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          verticalSpace(16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              value: analysis.progressPercentage / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(MAIZE_PRIMARY),
              minHeight: 8.h,
            ),
          ),
          verticalSpace(16),
          Text(
            analysis.stageDescription,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthStageTable() {
    final analysis = _growthStageAnalysis!;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Growth Stage Progress',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: MAIZE_ACCENT,
            ),
          ),
          verticalSpace(16),
          ...analysis.stageInfo.map(
            (stage) => _buildStageRow(stage, analysis.currentStage),
          ),
        ],
      ),
    );
  }

  Widget _buildStageRow(GrowthStageInfo stage, String currentStage) {
    final isCurrentStage =
        stage.stage == currentStage ||
        (stage.stage.contains('-') &&
            stage.stage.split('-').any((s) => s == currentStage));
    final isCompleted = _isStageCompleted(stage.stage, currentStage);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color:
            isCurrentStage
                ? MAIZE_PRIMARY.withOpacity(0.1)
                : isCompleted
                ? Colors.green.withOpacity(0.1)
                : Colors.grey[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color:
              isCurrentStage
                  ? MAIZE_PRIMARY
                  : isCompleted
                  ? Colors.green
                  : Colors.grey[300]!,
          width: isCurrentStage || isCompleted ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.h,
            decoration: BoxDecoration(
              color:
                  isCurrentStage
                      ? MAIZE_PRIMARY
                      : isCompleted
                      ? Colors.green
                      : Colors.grey[400],
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCurrentStage
                  ? Icons.play_arrow
                  : isCompleted
                  ? Icons.check
                  : Icons.radio_button_unchecked,
              color: Colors.white,
              size: 16.sp,
            ),
          ),
          horizontalSpace(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stage.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color:
                        isCurrentStage || isCompleted
                            ? MAIZE_ACCENT
                            : Colors.grey[600],
                  ),
                ),
                Text(
                  stage.description,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (stage.days > 0)
            Text(
              '${stage.days} days',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  bool _isStageCompleted(String stageRange, String currentStage) {
    if (stageRange.contains('-')) {
      final parts = stageRange.split('-');
      if (parts.length == 2) {
        // This is a simplified comparison - in reality you'd need proper stage ordering
        return false; // For now, only show current stage as active
      }
    }
    return false;
  }

  Widget _buildHarvestInfo() {
    final analysis = _growthStageAnalysis!;
    final daysToHarvest =
        analysis.expectedHarvest.difference(DateTime.now()).inDays;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: MAIZE_PRIMARY, size: 24.sp),
              horizontalSpace(12),
              Text(
                'Expected Harvest',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: MAIZE_ACCENT,
                ),
              ),
            ],
          ),
          verticalSpace(12),
          Text(
            '${analysis.expectedHarvest.day}/${analysis.expectedHarvest.month}/${analysis.expectedHarvest.year}',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: MAIZE_PRIMARY,
            ),
          ),
          verticalSpace(8),
          Text(
            daysToHarvest > 0
                ? '$daysToHarvest days remaining'
                : 'Harvest time!',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // Color helper methods for metrics
  Color _getSoilPhColor(double ph) {
    if (ph < 6.0) return Colors.red;
    if (ph < 6.5) return Colors.orange;
    if (ph <= 7.5) return Colors.green;
    if (ph <= 8.0) return Colors.orange;
    return Colors.red;
  }

  Color _getSoilMoistureColor(double moisture) {
    if (moisture < 30) return Colors.red;
    if (moisture < 50) return Colors.orange;
    if (moisture <= 70) return Colors.green;
    if (moisture <= 85) return Colors.orange;
    return Colors.red;
  }

  Color _getTemperatureColor(double temp) {
    if (temp < 15) return Colors.blue;
    if (temp < 20) return Colors.cyan;
    if (temp <= 30) return Colors.green;
    if (temp <= 35) return Colors.orange;
    return Colors.red;
  }

  Color _getHumidityColor(double humidity) {
    if (humidity < 30) return Colors.red;
    if (humidity < 50) return Colors.orange;
    if (humidity <= 80) return Colors.green;
    if (humidity <= 90) return Colors.orange;
    return Colors.red;
  }

  Color _getLightIntensityColor(double intensity) {
    if (intensity < 200) return Colors.red;
    if (intensity < 400) return Colors.orange;
    if (intensity <= 800) return Colors.green;
    if (intensity <= 1200) return Colors.orange;
    return Colors.red;
  }
}
