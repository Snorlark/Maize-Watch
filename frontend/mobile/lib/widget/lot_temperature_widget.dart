// widget/lot_temperature_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maize_watch/screen/detail_screen.dart';
import '../custom/custom_font.dart';

class LotTemperatureWidget extends StatelessWidget {
  final List<dynamic> data;
  final bool isLoading;

  const LotTemperatureWidget({
    super.key,
    required this.data,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ParameterWidget(
      title: 'Temperature',
      unit: '°C',
      icon: Icons.thermostat,
      color: Colors.orange,
      data: data,
      parameter: 'temperature',
      optimalRange: '20-30°C',
      isLoading: isLoading,
    );
  }
}
