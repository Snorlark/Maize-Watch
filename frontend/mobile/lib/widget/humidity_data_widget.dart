import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maize_watch/custom/constants.dart';
import 'package:maize_watch/model/chart_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../custom/custom_dialog.dart';
import '../custom/custom_font.dart';

class HumidityDataWidget extends StatefulWidget {
  final double humidityData;
  final AppLocalizations localizedText;

  const HumidityDataWidget({
    super.key,
    required this.humidityData, required this.localizedText,
  });

  @override
  State<HumidityDataWidget> createState() => _HumidityDataWidgetState();
}

class _HumidityDataWidgetState extends State<HumidityDataWidget> {
  String getHumidityDescription(double humidity) {
    if (humidity < 30) {
      return widget.localizedText.humidity_very_dry;
    } else if (humidity >= 30 && humidity < 60) {
      return widget.localizedText.humidity_moderate;
    } else if (humidity >= 60 && humidity < 80) {
      return widget.localizedText.humidity_quite_humid;
    } else {
      return widget.localizedText.humidity_very_humid;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<ChartData> chartData = [
      ChartData("Humidity", widget.humidityData, Colors.blue),
    ];

    return Flexible(
      child: Card(
        color: MAIZE_PRIMARY_LIGHT,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            ScreenUtil().setSp(15),
            ScreenUtil().setSp(26.5),
            ScreenUtil().setSp(15),
            ScreenUtil().setSp(26.5),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomFont(
                    text: widget.localizedText.humidity,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  GestureDetector(
                    onTap: () {
                      CustomDialog(
                        context,
                        title: widget.localizedText.humidity,
                        content: getHumidityDescription(widget.humidityData),
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
                    text: '${widget.humidityData.toStringAsFixed(2)}%',
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
                            trackColor:
                                const Color.fromARGB(237, 241, 241, 241),
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

