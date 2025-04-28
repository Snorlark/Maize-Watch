import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maize_watch/custom/constants.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../custom/custom_dialog.dart';
import '../custom/custom_font.dart';
import '../model/chart_data.dart';

class HumidityDataWidget extends StatefulWidget {

  final double humidityData;

  const HumidityDataWidget({
    super.key, 
    required this.humidityData
  });

  @override
  State<HumidityDataWidget> createState() => _HumidityDataWidgetState();
}

class _HumidityDataWidgetState extends State<HumidityDataWidget> {
  
  String getHumidityDescription(double humidity) {
    if (humidity < 30) {
      return "The air is very dry, typical of arid environments.";
    } else if (humidity >= 30 && humidity < 60) {
      return "The air has moderate humidity, comfortable for plant transpiration.";
    } else if (humidity >= 60 && humidity < 80) {
      return "The air is quite humid, often associated with moist environments.";
    } else {
      return "The air is very humid, common before rainfall or in tropical climates.";
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
          padding: EdgeInsets.fromLTRB(ScreenUtil().setSp(15), ScreenUtil().setSp(18.5), ScreenUtil().setSp(15), ScreenUtil().setSp(18.5)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CustomFont(text: "Humidity", color: Colors.black, fontWeight: FontWeight.bold,),
                  IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: () {
                      CustomDialog(
                        context, 
                        title: "Humidity", 
                        content: getHumidityDescription(widget.humidityData), // 👈 dynamic description here
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: ScreenUtil().setHeight(10)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomFont(text: '${widget.humidityData.toStringAsFixed(2)}%', color: Colors.black),
                  Flexible(
                    child: Center(
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
