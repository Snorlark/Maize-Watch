import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:maize_watch/custom/constants.dart';
import 'package:maize_watch/model/chart_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../custom/custom_dialog.dart';
import '../custom/custom_font.dart';

class SoilPhDataWidget extends StatefulWidget {
  final double soilPhData;
  final AppLocalizations localizedText;

  const SoilPhDataWidget({
    super.key,
    required this.soilPhData,
    required this.localizedText,
  });

  @override
  State<SoilPhDataWidget> createState() => _SoilPhDataWidgetState();
}

class _SoilPhDataWidgetState extends State<SoilPhDataWidget> {
  String getMoistureDescription(double moisture) {
    if (moisture < 20) {
      return widget.localizedText.moisture_too_dry;
    } else if (moisture >= 20 && moisture < 40) {
      return widget.localizedText.moisture_low;
    } else if (moisture >= 40 && moisture < 60) {
      return widget.localizedText.moisture_optimal;
    } else if (moisture >= 60 && moisture < 80) {
      return widget.localizedText.moisture_fairly_moist;
    } else {
      return widget.localizedText.moisture_too_wet;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<ChartData> chartData = [
      ChartData("Soil PH", widget.soilPhData, Colors.green),
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
                  text: widget.localizedText.ph_sensor,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {
                    CustomDialog(
                      context,
                      title: widget.localizedText.ph_sensor,
                      content: getMoistureDescription(widget.soilPhData),
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
                  text: '${widget.soilPhData.toStringAsFixed(2)}%',
                  color: Colors.black,
                ),
                SizedBox(
                  width: ScreenUtil().setWidth(200),
                  height: ScreenUtil().setHeight(50),
                  child: SfCartesianChart(
                    margin: EdgeInsets.zero,
                    primaryXAxis: NumericAxis(isVisible: false),
                    primaryYAxis:
                        NumericAxis(minimum: 0, maximum: 100, interval: 20),
                    series: <CartesianSeries>[
                      BarSeries<ChartData, num>(
                        color: const Color.fromARGB(255, 175, 132, 76).withOpacity(0.8),
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
