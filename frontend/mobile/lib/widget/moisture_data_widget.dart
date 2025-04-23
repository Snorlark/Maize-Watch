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
                      content: "Ornare tortor sagittis quis pretium sit elit eu consequat. Adipiscing fringilla penatibus pellentesque eget nisi purus. Nec enim dolor vestibulum tempor quam dui ipsum adipiscing. Neque tristique ullamcorper egestas nulla venenatis facilisis non eleifend nulla. Tempus imperdiet amet fringilla risus aliquam ipsum ultrices."
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: ScreenUtil().setHeight(10)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CustomFont(text: '${widget.moistureData}%', color: Colors.black),
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
                        xValueMapper: (data, _) => data.value,  // Label (e.g., "Moisture", "Humidity")
                        yValueMapper: (data, _) => data.value,  // Corresponding value
                        pointColorMapper: (data, _) => data.color, // Assign color
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