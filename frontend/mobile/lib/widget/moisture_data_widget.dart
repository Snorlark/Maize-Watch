import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maize_watch/custom/constants.dart';
import 'package:maize_watch/model/chart_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../custom/custom_dialog.dart';
import '../custom/custom_font.dart';

class MoistureDataWidget extends StatefulWidget {

  final double moistureData;

  const MoistureDataWidget({
    super.key, 
    required this.moistureData
  });

  @override
  State<MoistureDataWidget> createState() => _MoistureDataWidgetState();
}

class _MoistureDataWidgetState extends State<MoistureDataWidget> {
  
  String getMoistureDescription(double moisture) {
    if (moisture < 20) {
      return "The soil is too dry. Irrigation is highly recommended to prevent plant stress.";
    } else if (moisture >= 20 && moisture < 40) {
      return "The soil moisture is low. Consider watering soon to maintain healthy growth.";
    } else if (moisture >= 40 && moisture < 60) {
      return "The soil moisture is at an optimal level. Plants are in good condition.";
    } else if (moisture >= 60 && moisture < 80) {
      return "The soil is fairly moist. Monitor for potential overwatering.";
    } else {
      return "The soil is too wet. Risk of root rot and fungal diseases is high.";
    }
  }

  @override
  Widget build(BuildContext context) {

    List<ChartData> chartData = [
      ChartData("Moisture", widget.moistureData, Colors.green),
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
                const CustomFont(text: "Soil Moisture", color: Colors.black, fontWeight: FontWeight.bold,),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {
                    CustomDialog(
                      context, 
                      title: "Soil Moisture", 
                      content: getMoistureDescription(widget.moistureData), // <<== dynamic description here
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: ScreenUtil().setHeight(10)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CustomFont(text: '${widget.moistureData.toStringAsFixed(2)}%', color: Colors.black),
                SizedBox(
                  width: ScreenUtil().setWidth(200),
                  height: ScreenUtil().setHeight(50),
                  child: SfCartesianChart(
                    margin: EdgeInsets.zero,
                    primaryXAxis: NumericAxis(isVisible: false),
                    primaryYAxis: NumericAxis(
                        minimum: 0, maximum: 100, interval: 20),
                    series: <CartesianSeries>[
                      BarSeries<ChartData, num>(
                        color: Colors.green.withOpacity(0.8),
                        dataSource: chartData,
                        xValueMapper: (data, _) => data.value,
                        yValueMapper: (data, _) => data.value,
                        pointColorMapper: (data, _) => data.color,
                      )               
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}