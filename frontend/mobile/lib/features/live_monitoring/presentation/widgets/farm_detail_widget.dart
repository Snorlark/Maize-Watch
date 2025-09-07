import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'growth_progress_widget.dart';
import '../../../farm/domain/entities/farm.dart';
import '../../domain/entities/sensor_reading.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/colors.dart';

class FarmDetailWidget extends StatefulWidget {
  final Farm farm;
  final List<SensorReading> sensorReadings;
  final VoidCallback onBack;

  const FarmDetailWidget({
    super.key,
    required this.farm,
    required this.sensorReadings,
    required this.onBack,
  });

  @override
  State<FarmDetailWidget> createState() => _FarmDetailWidgetState();
}

class _FarmDetailWidgetState extends State<FarmDetailWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    child: _buildFieldDetailsCard(),
                  ),

                  // Tab navigation
                  _buildTabNavigation(),

                  verticalSpace(20),

                  // Tab content
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: _buildTabContent(),
                  ),

                  SizedBox(height: 40.h), // Bottom padding
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
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      height: 350.h, // Adjusted height for the growth progress widget
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
                  widget.farm.fields.isNotEmpty
                      ? widget.farm.fields.first.growthStage
                      : 'VE',
              plantingDate:
                  widget.farm.fields.isNotEmpty
                      ? widget.farm.fields.first.plantingDate
                      : DateTime.now(),
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
        child: Icon(icon, color: Colors.black87, size: 20.sp),
      ),
    );
  }

  Widget _buildFieldDetailsCard() {
    final firstField =
        widget.farm.fields.isNotEmpty ? widget.farm.fields.first : null;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            firstField?.fieldName ?? widget.farm.farmName,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),

          verticalSpace(8),

          Row(
            children: [
              Text(
                '2.27 acres',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 8.w),
                width: 4.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  shape: BoxShape.circle,
                ),
              ),
              Text(
                '15,000 plants',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          verticalSpace(20),

          Wrap(
            spacing: 24.w,
            runSpacing: 16.h,
            children: [
              SizedBox(
                width: (MediaQuery.of(context).size.width - 72.w) / 2,
                child: _buildQualityIndicator(
                  icon: Icons.eco,
                  value: '6.8',
                  label: 'Soil Quality',
                  unit: 'PH',
                ),
              ),
              SizedBox(
                width: (MediaQuery.of(context).size.width - 72.w) / 2,
                child: _buildQualityIndicator(
                  icon: Icons.water_drop,
                  value: 'Balanced',
                  label: 'Fertilization',
                  unit: '',
                ),
              ),
            ],
          ),

          verticalSpace(20),

          Text(
            'Tomato plants are susceptible to certain diseases and pests. To prevent soil depletion and control these issues, it\'s crucial to practice crop rotation by plating tomatoes in different areas of the field each season.',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),

          verticalSpace(16),

          // Daily Tips section
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 24.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 14.sp,
                  ),
                ),
                horizontalSpace(12),
                Expanded(
                  child: Text(
                    'Daily Tips',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange[800],
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14.sp,
                  color: Colors.orange[600],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityIndicator({
    required IconData icon,
    required String value,
    required String label,
    required String unit,
  }) {
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.h,
          decoration: BoxDecoration(
            color: MAIZE_PRIMARY.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: MAIZE_PRIMARY, size: 18.sp),
        ),
        horizontalSpace(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  if (unit.isNotEmpty) ...[
                    horizontalSpace(4),
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                label,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
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
          _buildTabButton('Analysis', 1),
          _buildTabButton('Notes', 2),
          _buildTabButton('Schedule', 3),
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
            color: isSelected ? Colors.black87 : Colors.transparent,
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
        return _buildAnalysisTab();
      case 2:
        return _buildNotesTab();
      case 3:
        return _buildScheduleTab();
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          // Sensor data grid
          Row(
            children: [
              Expanded(
                child: _buildSensorCard(
                  'Moisture',
                  '30°',
                  Icons.water_drop,
                  MAIZE_PRIMARY,
                ),
              ),
              horizontalSpace(12),
              Expanded(
                child: _buildSensorCard(
                  'Temperature',
                  '25°',
                  Icons.thermostat,
                  Colors.orange,
                ),
              ),
            ],
          ),
          verticalSpace(12),
          Row(
            children: [
              Expanded(
                child: _buildSensorCard(
                  'Acidity',
                  'pH 6.0',
                  Icons.science,
                  Colors.red,
                ),
              ),
              horizontalSpace(12),
              Expanded(
                child: _buildSensorCard(
                  'Nutrients',
                  'High',
                  Icons.eco,
                  Colors.green,
                ),
              ),
            ],
          ),

          verticalSpace(24),

          // Field image and info card
          _buildFieldImageCard(),

          verticalSpace(24),

          // Growth rate section
          _buildGrowthRateSection(),
        ],
      ),
    );
  }

  Widget _buildSensorCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
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
          ),
          verticalSpace(4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldImageCard() {
    final firstField =
        widget.farm.fields.isNotEmpty ? widget.farm.fields.first : null;

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
      child: Row(
        children: [
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: MAIZE_PRIMARY_LIGHT.withOpacity(0.3),
            ),
            child: Icon(Icons.grass, color: MAIZE_PRIMARY, size: 40.sp),
          ),
          horizontalSpace(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${firstField?.fieldName ?? 'Corn field'} ES-VAL-190346',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                verticalSpace(8),
                Text(
                  'Expected harvest:',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
                Text(
                  'December 2024',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: MAIZE_PRIMARY,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_forward, color: Colors.white, size: 20.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthRateSection() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Growth rate',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  verticalSpace(4),
                  Row(
                    children: [
                      Text(
                        '2.5 cm/day',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      horizontalSpace(8),
                      Icon(Icons.trending_up, color: Colors.green, size: 20.sp),
                    ],
                  ),
                ],
              ),
              // Time period selector
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildPeriodButton('W', false),
                    _buildPeriodButton('M', true),
                    _buildPeriodButton('Y', false),
                  ],
                ),
              ),
            ],
          ),
          verticalSpace(20),
          // Chart
          SizedBox(height: 150.h, child: _buildGrowthChart()),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String text, bool isSelected) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black87 : Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildGrowthChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 10,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(15, (index) {
          final height = (index + 1) * 0.6 + (index % 3) * 0.2;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: height,
                color: index < 10 ? Colors.green : MAIZE_PRIMARY,
                width: 12.w,
                borderRadius: BorderRadius.circular(6.r),
              ),
            ],
          );
        }),
        gridData: FlGridData(show: false),
      ),
    );
  }

  Widget _buildAnalysisTab() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
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
            'Field Analysis',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          verticalSpace(16),
          Text(
            'Detailed analytics and insights will be displayed here.',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesTab() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
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
            'Field Notes',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          verticalSpace(16),
          Text(
            'Add and manage your field notes here.',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTab() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
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
            'Schedule',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          verticalSpace(16),
          _buildScheduleItem(
            'Watering',
            '7:30 AM',
            'Daily',
            Icons.water_drop,
            MAIZE_PRIMARY,
          ),
          verticalSpace(12),
          _buildScheduleItem(
            'Fertilizing',
            '2 days',
            'Weekly',
            Icons.eco,
            Colors.orange,
          ),
          verticalSpace(12),
          _buildScheduleItem(
            'Pest Control',
            '5 days',
            'Bi-weekly',
            Icons.bug_report,
            Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(
    String title,
    String time,
    String frequency,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20.sp),
        ),
        horizontalSpace(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                frequency,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
