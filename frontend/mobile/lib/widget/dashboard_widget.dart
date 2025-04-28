import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maize_watch/custom/custom_button.dart';
import 'package:maize_watch/custom/custom_font.dart';
import 'package:maize_watch/model/sensor_data_model.dart';
import 'package:maize_watch/screen/detail_screen.dart';
import 'package:maize_watch/services/api_service.dart';
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
  List<String> _fields = [];
  String _selectedField = '';
  final ValueNotifier<SensorReading?> _currentDataNotifier = ValueNotifier(null);
  bool _isLoading = true;
  Timer? _dataRefreshTimer;  // Timer for periodic data fetch

  @override
  void initState() {
    super.initState();
    _loadData(); // Initial data load
    // Start listening to live data updates
    _startDataPolling();
  }

  void _startDataPolling() {
    // Set a timer to fetch data at regular intervals
    _dataRefreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _loadLatestData();  // This will trigger the data fetch
    });
  }

  Future<void> _loadData() async {
    try {
      final fields = await _apiService.getFields();
      if (fields.isNotEmpty) {
        final latestReadings = await _apiService.getLatestReadings();
        _fields = fields;
        _selectedField = fields.first;
        _isLoading = false;
        _updateCurrentData(latestReadings);
        _loadHistoricalData();
      }
      setState(() {});
    } catch (e) {
      _isLoading = false;
      setState(() {});
      print('Error loading data: $e');
    }
  }

  Future<void> _loadLatestData() async {
    try {
      final latestReadings = await _apiService.getLatestReadings();
      _updateCurrentData(latestReadings); // Immediately update the UI
    } catch (e) {
      print('Error loading latest data: $e');
    }
  }

  Future<void> _loadHistoricalData() async {
    if (_selectedField.isEmpty) return;
    try {
      final historicalData = await _apiService.getHistoricalData(_selectedField, 6);
    } catch (e) {
      print('Error loading historical data: $e');
    }
  }

  void _updateCurrentData(List<SensorReading> readings) {
    try {
      final current = readings.firstWhere((reading) => reading.fieldId == _selectedField);
      _currentDataNotifier.value = current;  // Update live data immediately
    } catch (e) {
      _currentDataNotifier.value = null;
    }
  }

  @override
  void dispose() {
    _currentDataNotifier.dispose();
    _dataRefreshTimer?.cancel();  // Cancel the polling when widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : ValueListenableBuilder<SensorReading?>(
            valueListenable: _currentDataNotifier,
            builder: (context, currentData, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomFont(
                    text: '${currentData?.measurements.temperature.toStringAsFixed(1) ?? '0'}°',
                    color: Colors.white,
                    fontSize: ScreenUtil().setSp(65),
                    fontWeight: FontWeight.bold,
                  ),
                  CropConditionWidget(currentData: currentData),
                  SizedBox(height: ScreenUtil().setHeight(10)),
                  const Divider(color: Colors.white),
                  SizedBox(height: ScreenUtil().setHeight(10)),
                  MoistureDataWidget(moistureData: currentData?.measurements.soilMoisture ?? 0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      HumidityDataWidget(humidityData: currentData?.measurements.humidity ?? 0),
                      LightDataWidget(lightIntensityData: currentData?.measurements.lightLevel ?? 0),
                    ],
                  ),
                  SizedBox(height: ScreenUtil().setHeight(5)),
                  CustomButton(
                    context: context,
                    title: 'View more details',
                    screen: DetailScreen(),
                    isTransparent: true,
                  ),
                ],
              );
            },
          );
  }
}