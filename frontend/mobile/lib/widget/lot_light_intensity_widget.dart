// widget/lot_light_intensity_widget.dart
import 'package:flutter/material.dart';
import 'package:maize_watch/screen/detail_screen.dart';

class LotLightIntensityWidget extends StatelessWidget {
  final List<dynamic> data;
  final bool isLoading;

  const LotLightIntensityWidget({
    super.key,
    required this.data,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ParameterWidget(
      title: 'Light Intensity',
      unit: 'lux',
      icon: Icons.wb_sunny,
      color: Colors.amber,
      data: data,
      parameter: 'lightIntensity',
      optimalRange: '20k-50k lux',
      isLoading: isLoading,
    );
  }
}
