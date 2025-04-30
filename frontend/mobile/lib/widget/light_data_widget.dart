import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maize_watch/custom/constants.dart';
import 'package:maize_watch/model/chart_data.dart';
import 'package:maize_watch/services/translation_service.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../custom/custom_dialog.dart';
import '../custom/custom_font.dart';

class LightDataWidget extends StatefulWidget {
  final double lightIntensityData;
  final TranslationService translationService;

  const LightDataWidget({
    super.key,
    required this.lightIntensityData, required this.translationService,
  });

  @override
  State<LightDataWidget> createState() => _LightDataWidgetState();
}

class _LightDataWidgetState extends State<LightDataWidget> {
  String getLightIntensityDescription(double intensity, TranslationService translationService) {
    if (intensity < 20) {
      return translationService.translate("light_intensity_very_low");
    } else if (intensity >= 20 && intensity < 50) {
      return translationService.translate("light_intensity_moderate");
    } else if (intensity >= 50 && intensity < 80) {
      return translationService.translate("light_intensity_bright");
    } else {
      return translationService.translate("light_intensity_very_strong");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<ChartData> chartData = [
      ChartData(
        "Light Intensity",
        widget.lightIntensityData,
        const Color.fromARGB(255, 225, 207, 48),
      )
    ];

    return Flexible(
      child: Card(
        color: MAIZE_PRIMARY_LIGHT,
        child: Padding(
          padding: EdgeInsets.all(ScreenUtil().setSp(15)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: CustomFont(
                      text: widget.translationService.translate("light_intensity_title"),
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      CustomDialog(
                        context,
                        title: widget.translationService.translate("light_intensity_title"),
                        content: getLightIntensityDescription(widget.lightIntensityData, widget.translationService),
                      );
                    },
                    child: const Icon(Icons.more_horiz),
                  ),
                ],
              ),
              SizedBox(height: ScreenUtil().setHeight(10)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomFont(
                    text: '${widget.lightIntensityData.toStringAsFixed(2)}%',
                    color: Colors.black,
                  ),
                  Flexible(
                    child: SizedBox(
                      width: ScreenUtil().setWidth(200),
                      height: ScreenUtil().setHeight(70),
                      child: SfCircularChart(
                        margin: EdgeInsets.zero,
                        series: <CircularSeries>[
                          RadialBarSeries<ChartData, String>(
                            dataSource: chartData,
                            xValueMapper: (ChartData data, _) => data.label,
                            yValueMapper: (ChartData data, _) => data.value,
                            pointColorMapper: (data, _) => data.color,
                            trackColor: const Color.fromARGB(237, 241, 241, 241),
                            maximumValue: 100,
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
