import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maize_watch/custom/constants.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../custom/custom_dialog.dart';
import '../custom/custom_font.dart';
import '../model/chart_data.dart';

class LightDataWidget extends StatefulWidget {

  final double lightIntensityData;

  const LightDataWidget({
    super.key, 
    required this.lightIntensityData
  });

  @override
  State<LightDataWidget> createState() => _LightDataWidgetState();
}

class _LightDataWidgetState extends State<LightDataWidget> {
  
  String getLightIntensityDescription(double intensity) {
    if (intensity < 20) {
      return "The light intensity is very low, resembling evening or dense shade.";
    } else if (intensity >= 20 && intensity < 50) {
      return "The light intensity is moderate, similar to cloudy daylight.";
    } else if (intensity >= 50 && intensity < 80) {
      return "The light intensity is bright, close to clear daytime conditions.";
    } else {
      return "The light intensity is very strong, similar to direct midday sunlight.";
    }
  }

  @override
  Widget build(BuildContext context) {

    List<ChartData> chartData = [
      ChartData("Light Intensity", widget.lightIntensityData, const Color.fromARGB(255, 225, 207, 48)),
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
                  const Flexible(child: CustomFont(text: "Light Intensity", color: Colors.black, fontWeight: FontWeight.bold,)),
                  IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: () {
                      CustomDialog(
                        context, 
                        title: "Light Intensity", 
                        content: getLightIntensityDescription(widget.lightIntensityData), // 👈 dynamic description here
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: ScreenUtil().setHeight(10)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomFont(text: '${widget.lightIntensityData.toStringAsFixed(2)}%', color: Colors.black),
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
