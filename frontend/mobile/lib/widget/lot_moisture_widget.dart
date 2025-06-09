import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maize_watch/custom/constants.dart';
import 'package:maize_watch/custom/custom_font.dart';
import 'package:maize_watch/model/chart_data.dart';
import 'package:maize_watch/screen/detail_screen.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LotMoistureWidget extends StatelessWidget {
  final List<dynamic> data;
  final bool isLoading;

  const LotMoistureWidget({
    super.key,
    required this.data,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ParameterWidget(
      title: 'Soil Moisture',
      unit: '%',
      icon: Icons.grass,
      color: Colors.green,
      data: data,
      parameter: 'soilMoisture',
      optimalRange: '40-70%',
      isLoading: isLoading,
    );
  }
}
