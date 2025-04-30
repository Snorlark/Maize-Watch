import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maize_watch/custom/custom_button.dart';
import 'package:maize_watch/custom/custom_font.dart';
import 'package:maize_watch/model/sensor_data_model.dart';
import 'package:maize_watch/screen/detail_screen.dart';
import 'package:maize_watch/services/api_service.dart';
import 'package:maize_watch/services/translation_service.dart';
import 'package:maize_watch/widget/crop_condition_widget.dart';
import 'package:maize_watch/widget/humidity_data_widget.dart';
import 'package:maize_watch/widget/light_data_widget.dart';
import 'package:maize_watch/widget/moisture_data_widget.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key});

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  final ApiService _apiService = ApiService();
  final TranslationService _translationService = TranslationService();
  final ValueNotifier<SensorReading?> _currentDataNotifier = ValueNotifier(null);
  bool _isLoading = true;
  bool _isUpdating = false;
  Timer? _dataRefreshTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startDataPolling();
  }

  void _startDataPolling() {
    _dataRefreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _loadLatestData();
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final latestReadings = await _apiService.getLatestReadings();
      if (latestReadings.isNotEmpty) {
        _currentDataNotifier.value = latestReadings.first;
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadLatestData() async {
    if (_isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final latestReadings = await _apiService.getLatestReadings();
      if (latestReadings.isNotEmpty) {
        _currentDataNotifier.value = latestReadings.first;
      }
    } catch (e) {
      print('Error loading latest data: $e');
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  @override
  void dispose() {
    _currentDataNotifier.dispose();
    _dataRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return ValueListenableBuilder<Map<String, dynamic>>(
      valueListenable: _translationService.translationNotifier,
      builder: (context, translationData, _) {
        return ValueListenableBuilder<SensorReading?>(
          valueListenable: _currentDataNotifier,
          builder: (context, currentData, _) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Temperature display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: CustomFont(
                          key: ValueKey(currentData?.measurements.temperature ?? 0),
                          text: '${currentData?.measurements.temperature.toStringAsFixed(1) ?? '0'}°',
                          color: Colors.white,
                          fontSize: ScreenUtil().setSp(65),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: _isUpdating
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
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                                  ),
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.all(4),
                                child: CustomFont(
                                  text: _translationService.translate("live"),
                                  color: Colors.green,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ],
                  ),

                  // Crop condition
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: CropConditionWidget(
                      key: ValueKey(currentData?.hashCode ?? 0),
                      currentData: currentData,
                      translationService: _translationService,
                    ),
                  ),

                  SizedBox(height: ScreenUtil().setHeight(10)),
                  const Divider(color: Colors.white),
                  SizedBox(height: ScreenUtil().setHeight(10)),

                  // Moisture data
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: _currentDataNotifier.value?.measurements.soilMoisture ?? 0,
                      end: currentData?.measurements.soilMoisture ?? 0,
                    ),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, value, child) {
                      return MoistureDataWidget(
                        moistureData: value,
                        translationService: _translationService,
                      );
                    },
                  ),

                  SizedBox(height: 2),

                  // Humidity and Light row
                  Row(
                    children: [
                      Expanded(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: _currentDataNotifier.value?.measurements.humidity ?? 0,
                            end: currentData?.measurements.humidity ?? 0,
                          ),
                          duration: const Duration(milliseconds: 800),
                          builder: (context, value, child) {
                            return HumidityDataWidget(
                              humidityData: value,
                              translationService: _translationService,
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 2),
                      Expanded(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(
                            begin: _currentDataNotifier.value?.measurements.lightLevel ?? 0,
                            end: currentData?.measurements.lightLevel ?? 0,
                          ),
                          duration: const Duration(milliseconds: 800),
                          builder: (context, value, child) {
                            return LightDataWidget(
                              lightIntensityData: value,
                              translationService: _translationService,
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 1),

                  // View more details button
                  CustomButton(
                    context: context,
                    title: _translationService.translate("view_more_details"),
                    screen: const DetailScreen(),
                    isTransparent: true,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} ${_translationService.translate("seconds_ago")}';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${_translationService.translate("minutes_ago")}';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${_translationService.translate("hours_ago")}';
    } else {
      return '${difference.inDays} ${_translationService.translate("days_ago")}';
    }
  }
}