import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maize_watch/custom/constants.dart';
import 'package:maize_watch/custom/custom_font.dart';
import 'package:maize_watch/model/chart_data.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LotHumidityWidget extends StatefulWidget {
  const LotHumidityWidget({super.key});

  @override
  State<LotHumidityWidget> createState() => _LotHumidityWidgetState();
}

class _LotHumidityWidgetState extends State<LotHumidityWidget> {
  late List<ChartData> data;

  @override
  void initState() {
    super.initState();

    data = [
      ChartData('MON', 50, MAIZE_PRIMARY),
      ChartData('TUE', 70, MAIZE_PRIMARY),
      ChartData('WED', 60, MAIZE_ACCENT),
      ChartData('THU', 45, MAIZE_PRIMARY),
      ChartData('FRI', 70, MAIZE_PRIMARY),
      ChartData('SAT', 0, MAIZE_PRIMARY),
      ChartData('SUN', 0, MAIZE_PRIMARY),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Background color
        borderRadius: BorderRadius.circular(20.r), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Soft shadow
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4), // Shadow position
          ),
        ],
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: ScreenUtil().setHeight(10),
          ),
          CustomFont(
            text: 'Humidity',
            color: MAIZE_ACCENT,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.left,
          ),
          SizedBox(
            height: ScreenUtil().setHeight(10),
          ),
          SfCartesianChart(
            backgroundColor: Colors.white, // White background for the chart
            primaryXAxis: CategoryAxis(
              labelStyle: const TextStyle(
                  color: Colors.black), // White text for category labels
              majorGridLines:
                  const MajorGridLines(width: 0), // Removes vertical grid lines
            ),
            primaryYAxis: NumericAxis(
              minimum: 0,
              maximum: 100,
              interval: 50,
              // Removes horizontal grid lines
            ),
            series: <CartesianSeries<ChartData, String>>[
              ColumnSeries<ChartData, String>(
                  dataSource: data,
                  xValueMapper: (ChartData data, _) => data.label,
                  yValueMapper: (ChartData data, _) => data.value,
                  pointColorMapper: (ChartData data, _) => data.color,
                  name: 'Temperature',
                  borderRadius: BorderRadius.circular(50))
            ],
          ),
        ],
      ),
    );
  }
}
