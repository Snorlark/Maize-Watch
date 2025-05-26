import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maize_watch/custom/constants.dart';
import 'package:maize_watch/custom/custom_font.dart';
import 'package:maize_watch/model/chart_data.dart';
import 'package:maize_watch/screen/detail_screen.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LotHumidityWidget extends StatelessWidget {
  final List<dynamic> data;
  final bool isLoading;

  const LotHumidityWidget({
    super.key,
    required this.data,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ParameterWidget(
      title: 'Humidity',
      unit: '%',
      icon: Icons.water_drop,
      color: Colors.blue,
      data: data,
      parameter: 'humidity',
      optimalRange: '60-80%',
      isLoading: isLoading,
    );
  }
}