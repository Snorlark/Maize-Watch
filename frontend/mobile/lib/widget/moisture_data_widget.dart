import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maize_watch/custom/constants.dart';
import 'package:maize_watch/model/chart_data.dart';
import 'package:maize_watch/services/translation_service.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../custom/custom_dialog.dart';
import '../custom/custom_font.dart';

class MoistureDataWidget extends StatefulWidget {
  final double moistureData;
  final TranslationService translationService;

  const MoistureDataWidget({
    super.key, 
    required this.moistureData, 
    required this.translationService
  });

  @override
  State<MoistureDataWidget> createState() => _MoistureDataWidgetState();
}

class _MoistureDataWidgetState extends State<MoistureDataWidget> {
  
  String getMoistureDescriptionKey(double moisture) {
    if (moisture < 20) {
      return "moisture_too_dry";
    } else if (moisture >= 20 && moisture < 40) {
      return "moisture_low";
    } else if (moisture >= 40 && moisture < 60) {
      return "moisture_optimal";
    } else if (moisture >= 60 && moisture < 80) {
      return "moisture_fairly_moist";
    } else {
      return "moisture_too_wet";
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
                CustomFont(
                  text: widget.translationService.translate("soil_moisture"), 
                  color: Colors.black, 
                  fontWeight: FontWeight.bold,
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {
                    CustomDialog(
                      context, 
                      title: widget.translationService.translate("soil_moisture"), 
                      content: widget.translationService.translate(
                        getMoistureDescriptionKey(widget.moistureData)
                      ),
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
                  text: '${widget.moistureData.toStringAsFixed(2)}%', 
                  color: Colors.black
                ),
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