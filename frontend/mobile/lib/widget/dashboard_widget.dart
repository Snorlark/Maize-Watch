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

  @override
  void initState() {
    super.initState();
    _cropConditionService.initialize();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ValueListenableBuilder<SensorReading?>(
      valueListenable: _cropConditionService.currentDataNotifier,
      builder: (context, currentData, _) {
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
                  end: currentData?.soilMoisture.toDouble() ?? 0,
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
                  end: currentData?.soilPh.toDouble() ?? 0,
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
                        end: currentData?.humidity ?? 0,
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
                        end: currentData?.lightIntensity.toDouble() ?? 0,
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
