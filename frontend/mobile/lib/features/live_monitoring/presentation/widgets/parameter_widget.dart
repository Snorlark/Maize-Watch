import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';

import 'package:mobile/core/theme/colors.dart';

class ParameterWidget extends StatefulWidget {
  final String title;
  final String unit;
  final IconData icon;
  final Color color;
  final List<dynamic> data;
  final String parameter;
  final String optimalRange;
  final bool isLoading;
  final int weekOffset;
  final double? currentValue; // Add current value parameter

  const ParameterWidget({
    super.key,
    required this.title,
    required this.unit,
    required this.icon,
    required this.color,
    required this.data,
    required this.parameter,
    required this.optimalRange,
    this.isLoading = false,
    this.weekOffset = 0,
    this.currentValue, // Add current value parameter
  });

  @override
  State<ParameterWidget> createState() => _ParameterWidgetState();
}

class _ParameterWidgetState extends State<ParameterWidget> {
  bool showThreshold = true;
  Map<String, dynamic>? liveData;
  bool isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchLiveData();
    // Set up periodic refresh every 2 minutes (reduced frequency)
    _timer = Timer.periodic(const Duration(minutes: 2), (timer) {
      fetchLiveData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchLiveData() async {
    // This would typically fetch from the backend
    // For now, we'll use the latest data from the weekly data
    if (widget.data.isNotEmpty && mounted) {
      setState(() {
        liveData = widget.data.last;
        isLoading = false;
      });
    }
  }

  double getCurrentValue() {
    // Use provided currentValue if available, otherwise fall back to liveData
    if (widget.currentValue != null) {
      return widget.currentValue!;
    }
    
    if (liveData == null) return 0.0;
    
    // Handle both direct measurements and nested measurements structure
    Map<String, dynamic> measurements;
    
    if (liveData!.containsKey('measurements')) {
      measurements = liveData!['measurements'] ?? {};
    } else {
      measurements = liveData!;
    }
    
    // Map the parameter names to match the API response
    String apiParameter = widget.parameter;
    if (widget.parameter == 'soilMoisture') {
      apiParameter = 'soilMoisture';
    } else if (widget.parameter == 'lightIntensity') {
      apiParameter = 'lightIntensity';
    } else if (widget.parameter == 'soilPh') {
      apiParameter = 'soilPh';
    }
    
    final value = measurements[apiParameter];
    
    if (value == null) {
      print('No value found for parameter: $apiParameter in measurements: $measurements');
      return 0.0;
    }
    
    print('Raw value for ${widget.parameter}: $value (type: ${value.runtimeType})');
    
    // Convert to double with better error handling
    double parsedValue = 0.0;
    try {
      if (value is num) {
        parsedValue = value.toDouble();
      } else if (value is String) {
        parsedValue = double.tryParse(value) ?? 0.0;
      }
    } catch (e) {
      print('Error parsing value for ${widget.parameter}: $e');
      parsedValue = 0.0;
    }
    
    print('Parsed value for ${widget.parameter}: $parsedValue');
    
    // Special handling for different parameters
    switch (widget.parameter) {
      case 'soilPh':
        // Return 0.0 if soil pH is 0 or null
        return parsedValue == 0 ? 0.0 : parsedValue;
      case 'soilMoisture':
        // Convert soil moisture to percentage if needed
        return parsedValue > 100 ? parsedValue / 10 : parsedValue;
      case 'lightIntensity':
        // Ensure light intensity is within reasonable range
        return parsedValue.clamp(0, 10000);
      default:
        return parsedValue;
    }
  }

  double getAverageValue() {
    if (widget.data.isEmpty) return 0.0;
    double sum = 0.0;
    int count = 0;

    for (var item in widget.data) {
      if (item['hasData'] == true) {
        final measurements = item['measurements'];
        if (measurements != null) {
          final value = measurements[widget.parameter];
          if (value != null) {
            // Special handling for different parameters
            switch (widget.parameter) {
              case 'soilPh':
                if (value != 0) {
                  sum += value.toDouble();
                  count++;
                }
                break;
              case 'soilMoisture':
                double moistureValue = value.toDouble();
                // Convert to percentage if needed
                if (moistureValue > 100) {
                  moistureValue = moistureValue / 10;
                }
                sum += moistureValue;
                count++;
                break;
              case 'lightIntensity':
                sum += value.toDouble().clamp(0, 10000);
                count++;
                break;
              default:
                sum += value.toDouble();
                count++;
            }
          }
        }
      }
    }

    return count > 0 ? sum / count : 0.0;
  }

  String getTrend() {
    if (widget.data.length < 2) return 'stable';

    final recent = widget.data.sublist(widget.data.length - 3);
    if (recent.length < 2) return 'stable';

    double firstValue = (recent.first['measurements'][widget.parameter] ?? 0.0).toDouble();
    double lastValue = (recent.last['measurements'][widget.parameter] ?? 0.0).toDouble();

    double change = ((lastValue - firstValue) / firstValue * 100).abs();

    if (change < 5) return 'stable';
    return lastValue > firstValue ? 'increasing' : 'decreasing';
  }

  IconData getTrendIcon() {
    String trend = getTrend();
    switch (trend) {
      case 'increasing':
        return Icons.trending_up;
      case 'decreasing':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }

  Color getTrendColor() {
    String trend = getTrend();
    switch (trend) {
      case 'increasing':
        return Colors.green;
      case 'decreasing':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentValue = getCurrentValue();
    final averageValue = getAverageValue();

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: Colors.white),
       
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.color,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: MAIZE_ACCENT,
                      ),
                    ),
                    Text(
                      'Optimal: ${widget.optimalRange}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  showThreshold ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey[600],
                ),
                onPressed: () {
                  setState(() {
                    showThreshold = !showThreshold;
                  });
                },
              ),
              Icon(
                getTrendIcon(),
                color: getTrendColor(),
                size: 20.sp,
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Current and Average Values
          Row(
            children: [
              Expanded(
                child: _buildValueCard(
                  'Current',
                  currentValue,
                  widget.unit,
                  widget.color,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildValueCard(
                  '7-Day Avg',
                  averageValue,
                  widget.unit,
                  MAIZE_ACCENT,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Weekly Chart
          _buildWeeklyChart(),
        ],
      ),
    );
  }

  Widget _buildValueCard(
      String label, double value, String unit, Color valueColor) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: valueColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),        
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '${value.toStringAsFixed(1)} $unit',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    if (widget.data.isEmpty) {
      return Container(
        height: 100.h,
        alignment: Alignment.center,
        child: Text(
          'No data available',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    // Find min and max values for scaling
    double minValue = double.infinity;
    double maxValue = double.negativeInfinity;

    List<double> values = [];
    for (var item in widget.data) {
      final value = (item['measurements'][widget.parameter] ?? 0.0).toDouble();
      values.add(value);
      if (value < minValue) minValue = value;
      if (value > maxValue) maxValue = value;
    }

    // Add padding to the range
    double range = maxValue - minValue;
    if (range == 0) range = 1; // Avoid division by zero
    minValue -= range * 0.1;
    maxValue += range * 0.1;

    return Container(
      height: 120.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Trend',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: MAIZE_ACCENT,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            height: 80.h,
            width: double.infinity,
            child: CustomPaint(
              painter: WeeklyChartPainter(
                values: values,
                minValue: minValue,
                  maxValue: maxValue,
                  color: widget.color,
                  data: widget.data,
                  optimalRange: widget.optimalRange,
                  showThreshold: showThreshold,
                  parameter: widget.parameter,
                  weekStart: getWeekStart(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Get the start of the calendar week (Sunday) for the current week offset
  DateTime getWeekStart() {
    final now = DateTime.now();
    // Get current week's Sunday
    int daysFromSunday = now.weekday == 7 ? 0 : now.weekday;
    final currentWeekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysFromSunday));
    // Apply week offset
    return currentWeekStart.add(Duration(days: widget.weekOffset * 7));
  }
}

class WeeklyChartPainter extends CustomPainter {
  final List<double> values;
  final double minValue;
  final double maxValue;
  final Color color;
  final List<dynamic> data;
  final String optimalRange;
  final bool showThreshold;
  final String parameter;
  final DateTime weekStart;

  WeeklyChartPainter({
    required this.values,
    required this.minValue,
    required this.maxValue,
    required this.color,
    required this.data,
    required this.optimalRange,
    required this.showThreshold,
    required this.parameter,
    required this.weekStart,
  });

  String _getDayLabel(int dayIndex) {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return days[dayIndex];
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    // Calculate the actual range of values
    double actualMin = minValue;
    double actualMax = maxValue;
    
    // For light intensity, ensure the range is appropriate
    if (parameter == 'lightIntensity') {
      actualMin = 0;
      actualMax = 10000;
    }

    if (showThreshold) {
      // Parse optimal range and draw threshold lines
      List<double> thresholds = _parseOptimalRange(optimalRange);
      double lowerThreshold = thresholds[0];
      double upperThreshold = thresholds[1];

      // Ensure thresholds are within the visible range
      if (parameter == 'lightIntensity') {
        lowerThreshold = lowerThreshold.clamp(0, 10000);
        upperThreshold = upperThreshold.clamp(0, 10000);
      }

      final thresholdPaint = Paint()
        ..color = Colors.grey.withOpacity(0.3)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      // Draw threshold lines and labels
      double upperY = size.height - ((upperThreshold - actualMin) / (actualMax - actualMin)) * size.height;
      double lowerY = size.height - ((lowerThreshold - actualMin) / (actualMax - actualMin)) * size.height;
      
      // Ensure Y coordinates are within bounds
      upperY = upperY.clamp(0, size.height);
      lowerY = lowerY.clamp(0, size.height);
      
      canvas.drawLine(Offset(0, upperY), Offset(size.width, upperY), thresholdPaint);
      canvas.drawLine(Offset(0, lowerY), Offset(size.width, lowerY), thresholdPaint);

      // Draw threshold labels with better positioning
      final textPainter = TextPainter(textDirection: TextDirection.ltr);
      
      // Upper threshold label
      textPainter.text = TextSpan(
        text: upperThreshold.toStringAsFixed(1),
        style: TextStyle(color: Colors.grey[600], fontSize: 10.sp),
      );
      textPainter.layout();
      
      // Position upper label above the line if there's space, otherwise below
      double upperLabelY = upperY - textPainter.height - 2;
      if (upperLabelY < 0) {
        upperLabelY = upperY + 2;
      }
      textPainter.paint(canvas, Offset(size.width - textPainter.width - 4, upperLabelY));

      // Lower threshold label
      textPainter.text = TextSpan(
        text: lowerThreshold.toStringAsFixed(1),
        style: TextStyle(color: Colors.grey[600], fontSize: 10.sp),
      );
      textPainter.layout();
      
      // Position lower label below the line if there's space, otherwise above
      double lowerLabelY = lowerY + 2;
      if (lowerLabelY + textPainter.height > size.height) {
        lowerLabelY = lowerY - textPainter.height - 2;
      }
      textPainter.paint(canvas, Offset(size.width - textPainter.width - 4, lowerLabelY));
    }

    // Create a map to store values for each day (Sunday = 0, Saturday = 6)
    Map<int, double> dayValues = {};
    
    // Process data points and map them to days of the week
    for (var item in data) {
      final timestamp = DateTime.parse(item['timestamp']);
      final value = (item['measurements'][parameter] ?? 0.0).toDouble();
      
      // Calculate which day of the week this timestamp falls on within our target week
      final daysDiff = timestamp.difference(weekStart).inDays;
      if (daysDiff >= 0 && daysDiff < 7) {
        dayValues[daysDiff] = value;
      }
    }

    // Draw the chart
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    double range = actualMax - actualMin;
    if (range == 0) range = 1;

    // Create line path for each day (Sunday to Saturday)
    for (int i = 0; i < 7; i++) {
      double x = (i / 6) * size.width;
      double y = size.height;
      
      if (dayValues.containsKey(i)) {
        double value = dayValues[i]!.clamp(actualMin, actualMax);
        y = size.height - ((value - actualMin) / range) * size.height;
      }

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Complete the fill path
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Draw the filled area and line
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw points for days with data
    for (int i = 0; i < 7; i++) {
      if (dayValues.containsKey(i)) {
        double x = (i / 6) * size.width;
        double value = dayValues[i]!.clamp(actualMin, actualMax);
        double y = size.height - ((value - actualMin) / range) * size.height;
        canvas.drawCircle(Offset(x, y), 3, pointPaint);
      }
    }

    // Draw day labels (Sun, Mon, Tue, Wed, Thu, Fri, Sat)
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    
    for (int i = 0; i < 7; i++) {
      double x = (i / 6) * size.width;
      
      textPainter.text = TextSpan(
        text: _getDayLabel(i),
        style: TextStyle(color: Colors.grey[600], fontSize: 10.sp),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height + 4));
    }
  }

  List<double> _parseOptimalRange(String range) {
    String cleanRange = range.replaceAll(RegExp(r'[^0-9.-]'), '');
    List<String> parts = cleanRange.split('-');
    
    if (parts.length == 2) {
      return [double.parse(parts[0].trim()), double.parse(parts[1].trim())];
    }
    
    return [0.0, 100.0];
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
