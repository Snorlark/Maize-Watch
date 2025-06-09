import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:maize_watch/custom/custom_button.dart';
import 'package:maize_watch/model/sensor_data_model.dart';
import 'package:maize_watch/screen/detail_screen.dart';
import 'package:maize_watch/services/api_service.dart';
import 'package:maize_watch/services/crop_condition_service.dart';
import 'package:maize_watch/widget/humidity_data_widget.dart';
import 'package:maize_watch/widget/light_data_widget.dart';
import 'package:maize_watch/widget/moisture_data_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:maize_watch/widget/soil_ph_data_widget.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key});

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  final ApiService _apiService = ApiService();
  final CropConditionService _cropConditionService = CropConditionService();
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      // Initialize the service and wait for initial data
      _cropConditionService.initialize();
      
      // Wait for initial data load with timeout
      bool dataLoaded = false;
      int attempts = 0;
      while (!dataLoaded && attempts < 5) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (_cropConditionService.currentDataNotifier.value != null) {
          dataLoaded = true;
        }
        attempts++;
      }

      if (!dataLoaded) {
        throw Exception('Timeout waiting for initial data');
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error initializing dashboard data: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load sensor data. Please try again.';
      });
    }
  }

  Future<void> _retryLoading() async {
    await _initializeData();
  }

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading sensor data...'),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage ?? 'An error occurred'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _retryLoading,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return ValueListenableBuilder<SensorReading?>(
      valueListenable: _cropConditionService.currentDataNotifier,
      builder: (context, currentData, _) {
        if (currentData == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.orange),
                const SizedBox(height: 16),
                const Text('No sensor data available'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _retryLoading,
                  child: const Text('Refresh'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: ScreenUtil().setHeight(10)),

              // Moisture data
              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: _cropConditionService
                          .currentDataNotifier.value?.soilMoisture
                          .toDouble() ??
                      0.0,
                  end: currentData.soilMoisture.toDouble(),
                ),
                duration: const Duration(milliseconds: 800),
                builder: (context, value, child) {
                  return MoistureDataWidget(
                    moistureData: value,
                    localizedText: localize,
                  );
                },
              ),

              const SizedBox(height: 2),

              //Soil PH
              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: _cropConditionService
                          .currentDataNotifier.value?.soilPh
                          .toDouble() ??
                      0.0,
                  end: currentData.soilPh.toDouble(),
                ),
                duration: const Duration(milliseconds: 800),
                builder: (context, value, child) {
                  return SoilPhDataWidget(
                    soilPhData: value,
                    localizedText: localize,
                  );
                },
              ),

              const SizedBox(height: 2),

              // Humidity and Light row
              Row(
                children: [
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: _cropConditionService
                                .currentDataNotifier.value?.humidity ??
                            0,
                        end: currentData.humidity,
                      ),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, value, child) {
                        return HumidityDataWidget(
                          humidityData: value,
                          localizedText: localize,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: _cropConditionService
                                .currentDataNotifier.value?.lightIntensity
                                .toDouble() ??
                            0,
                        end: currentData.lightIntensity.toDouble(),
                      ),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, value, child) {
                        return LightDataWidget(
                          lightIntensityData: value,
                          localizedText: localize,
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 1),

              // View more details button
              Card(
                color: Colors.white,
                child: CustomButton(
                  context: context,
                  title: localize.view_more_details,
                  screen: const DetailScreen(),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
