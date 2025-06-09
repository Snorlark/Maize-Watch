import 'package:flutter/material.dart';
import 'package:maize_watch/screen/detail_screen.dart';

class LotSoilPhWidget extends StatelessWidget {
  final List<dynamic> data;
  final bool isLoading;

  const LotSoilPhWidget({
    super.key,
    required this.data,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ParameterWidget(
      title: 'Soil pH',
      unit: 'pH',
      icon: Icons.science,
      color: Colors.purple,
      data: data,
      parameter: 'soilPh',
      optimalRange: '6.0-7.0',
      isLoading: isLoading,
    );
  }
}
