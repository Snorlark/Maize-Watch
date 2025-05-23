import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import 'package:maize_watch/custom/constants.dart';
import 'package:maize_watch/custom/custom_font.dart';
import 'package:maize_watch/services/api_service.dart';
import 'package:maize_watch/services/corn_growth_service.dart';
import 'package:maize_watch/services/crop_condition_service.dart';
import 'package:maize_watch/model/sensor_data_model.dart';
import 'package:maize_watch/model/corn_field_model.dart';
import 'package:maize_watch/widget/corn_progress_widget.dart';
import 'package:maize_watch/widget/dashboard_widget.dart';
import 'package:maize_watch/widget/crop_condition_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CropConditionScreen extends StatefulWidget {
  const CropConditionScreen({super.key});

  @override
  State<CropConditionScreen> createState() => _CropConditionScreenState();
}

String _getLocalizedGreeting(BuildContext context) {
  final hour = DateTime.now().hour;
  if (hour < 12) {
    return AppLocalizations.of(context)!.greeting_morning;
  } else if (hour < 17) {
    return AppLocalizations.of(context)!.greeting_afternoon;
  } else {
    return AppLocalizations.of(context)!.greeting_evening;
  }
}

class _CropConditionScreenState extends State<CropConditionScreen>
    with SingleTickerProviderStateMixin {
  bool _showSensorData = false;
  bool _isLoading = true;
  bool _isUpdating = false;

  final ApiService _apiService = ApiService();
  final CornGrowthService _cornGrowthService = CornGrowthService();
  final CropConditionService _cropConditionService = CropConditionService();

  final GlobalKey<State<CornProgressWidget>> _cornProgressKey = GlobalKey();
  final GlobalKey<State<DashboardWidget>> _dashboardKey = GlobalKey();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String _greeting = 'Good Morning';
  String _userName = 'farmer';

  // Changed from Map to CornField
  CornField? _cornField;
  List<SensorReading>? _historicalData;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    // Initialize the crop condition service
    _cropConditionService.initialize();

    _loadUserGreeting();
    _loadData();
  }

  Future<void> _loadUserGreeting() async {
    final userData = await _apiService.getUserData();
    if (userData != null) {
      final name = userData['fullName'] ??
          userData['name'] ??
          userData['username'] ??
          'farmer';
      final firstName = name.contains(' ') ? name.split(' ')[0] : name;

      setState(() {
        _greeting = _getLocalizedGreeting(context);
        _userName = firstName;
      });
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get corn field data and convert to CornField object
      final fieldData = await _apiService.getCropData(context);
      if (fieldData != null) {
        // Convert Map to CornField object
        _cornField = CornField(
          fieldName: fieldData['fieldName'] ?? 'Unknown Field',
          cornVariety: fieldData['cornVariety'] ?? 'Unknown Variety',
          growthStage: fieldData['growthStage'] ??
              'VE', // Default to 'VE' if not available
          plantingDate: fieldData['plantingDate'] != null
              ? DateTime.parse(fieldData['plantingDate'])
              : DateTime.now().subtract(const Duration(days: 30)),
          soilType: fieldData['soilType'] ?? 'Loam',
          location: fieldData['location'], id: '',
// or another fallback
        );
      }

      // Get latest sensor readings (handled by CropConditionService)
      await _cropConditionService.refreshData();



      // Process the sensor data with the corn growth service
      if (_cropConditionService.currentDataNotifier.value != null) {
        _cornGrowthService
            .processSensorData(_cropConditionService.currentDataNotifier.value);
      }
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cropConditionService.dispose();
    super.dispose();
  }

  void _toggleView() {
    _animationController.reverse().then((_) {
      setState(() {
        _showSensorData = !_showSensorData;
      });
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: SizedBox.expand(),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                ScreenUtil().setSp(30),
                ScreenUtil().setSp(30),
                ScreenUtil().setSp(30),
                ScreenUtil().setSp(30),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting and user name
                  Row(
                    children: [
                      CustomFont(
                        text: '$_greeting, ',
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      CustomFont(
                        text: _userName,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),

                  // Temperature display
                  ValueListenableBuilder<SensorReading?>(
                    valueListenable: _cropConditionService.currentDataNotifier,
                    builder: (context, currentData, _) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CustomFont(
                                  key: ValueKey(
                                      currentData?.temperature ??
                                          0),
                                  text:
                                      '${currentData?.temperature.toStringAsFixed(1) ?? '0'}°',
                                  color: Colors.white,
                                  fontSize: 55.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                CustomFont(
                                  text: 'C',
                                  color: Colors.white,
                                  fontSize: 30.sp,
                                  fontWeight: FontWeight.bold,
                                )
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: _cropConditionService.isUpdating
                                ? Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black26,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white70),
                                      ),
                                    ),
                                  )
                                : Container(
                                    padding: EdgeInsets.all(4),
                                    child: CustomFont(
                                      text: AppLocalizations.of(context)!.live,
                                      color: MAIZE_PRIMARY_LIGHT,
                                      fontWeight: FontWeight.w300,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ],
                      );
                    },
                  ),

                  SizedBox(height: ScreenUtil().setHeight(10)),

                  // Crop condition
                  ValueListenableBuilder<SensorReading?>(
                    valueListenable: _cropConditionService.currentDataNotifier,
                    builder: (context, currentData, _) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: CropConditionWidget(
                          key: ValueKey(currentData?.hashCode ?? 0),
                          currentData: currentData,
                          includeUpdated: false,
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 20.h),

                  // Toggle view buttons (centered)
                  Center(
                    child: _buildViewToggle(),
                  ),

                  SizedBox(height: 15.h),

                  // Main content area
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Expanded(
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: _showSensorData
                                ? DashboardWidget(key: _dashboardKey)
                                : _cornField != null
                                    ? CornProgressWidget(
                                        key: _cornProgressKey,
                                        cornField: _cornField!,
                                        currentData: _cropConditionService
                                            .currentDataNotifier.value,
                                        historicalData: _historicalData,
                                      )
                                    : const Center(
                                        child: Text('No field data available'),
                                      ),
                          ),
                        )
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadData,
        child: const Icon(Icons.refresh),
        tooltip: 'Refresh data',
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Corn progress button
          _buildToggleButton(
            icon: Icons.eco,
            text: AppLocalizations.of(context)!.corn,
            isSelected: !_showSensorData,
            onTap: () {
              if (_showSensorData) _toggleView();
            },
          ),
          // Sensor data button
          _buildToggleButton(
            icon: Icons.sensors,
            text: 'Sensor',
            isSelected: _showSensorData,
            onTap: () {
              if (!_showSensorData) _toggleView();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? MAIZE_PRIMARY : Colors.white,
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : MAIZE_PRIMARY,
              size: 18.sp,
            ),
            SizedBox(width: 4.w),
            CustomFont(
              text: text,
              color: isSelected ? Colors.white : MAIZE_PRIMARY,
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ],
        ),
      ),
    );
  }
}
