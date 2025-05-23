import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maize_watch/custom/constants.dart';
import 'package:maize_watch/model/chart_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../custom/custom_dialog.dart';
import '../custom/custom_font.dart';

class LightDataWidget extends StatefulWidget {
  final double lightIntensityData;
  final AppLocalizations localizedText;

  const LightDataWidget({
    super.key,
    required this.lightIntensityData,
    required this.localizedText,
  });

  @override
  State<LightDataWidget> createState() => _LightDataWidgetState();
}

class _LightDataWidgetState extends State<LightDataWidget> {
  String getLightIntensityDescriptionKey(double intensity) {
    if (intensity < 20) {
      return widget.localizedText.light_intensity_very_low;
    } else if (intensity < 50) {
      return widget.localizedText.light_intensity_moderate;
    } else if (intensity < 80) {
      return widget.localizedText.light_intensity_bright;
    } else {
      return widget.localizedText.light_intensity_very_strong;
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

    return Card(
      color: MAIZE_PRIMARY_LIGHT,
      child: Padding(
        padding: EdgeInsets.all(ScreenUtil().setSp(15)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomFont(
                    text: widget.localizedText.light_intensity,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {
                    CustomDialog(
                      context,
                      title: widget.localizedText.light_intensity,
                      content: getLightIntensityDescriptionKey(widget.lightIntensityData),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: ScreenUtil().setHeight(10)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CustomFont(
                  text: '${widget.lightIntensityData.toStringAsFixed(2)}%',
                  color: Colors.black,
                ),
                Expanded(
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
