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
    // Use the historical data from ThingSpeak for graphing
    if (widget.data.isNotEmpty && mounted) {
      setState(() {
        // Use the first data point for current value display
        liveData = widget.data.first;
        isLoading = false;
      });
    }
  }

  double? getCurrentValue() {
    if (widget.currentValue != null) return widget.currentValue;

    // Use the most recent (last) data point, not the oldest (first)
    final recentItem = widget.data.isNotEmpty ? widget.data.last : null;
    if (recentItem == null) return null;

    final measurements = recentItem['measurements'];
    if (measurements == null) return null;

    final raw = measurements[widget.parameter];
    if (raw == null) return null;

    final v = raw is num ? raw.toDouble() : double.tryParse(raw.toString());
    if (v == null) return null;

    switch (widget.parameter) {
      case 'soilMoisture':
        return v > 100 ? v / 10 : v;
      case 'lightIntensity':
        return v.clamp(0, 10000);
      default:
        return v;
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
          final rawValue = measurements[widget.parameter];
          if (rawValue == null) continue;
          double value = rawValue is num ? rawValue.toDouble() : double.tryParse(rawValue.toString()) ?? 0.0;

          switch (widget.parameter) {
            case 'soilPh':
              // Skip zero readings — means sensor has no data
              if (value > 0) { sum += value; count++; }
              break;
            case 'soilMoisture':
              double moistureValue = value > 100 ? value / 10 : value;
              sum += moistureValue;
              count++;
              break;
            case 'lightIntensity':
              // Skip zero readings — means sensor has no data
              if (value > 0) { sum += value.clamp(0, 10000); count++; }
              break;
            default:
              sum += value;
              count++;
          }
        }
      }
    }

    return count > 0 ? sum / count : 0.0;
  }

  String getTrend() {
    if (widget.data.length < 2) return 'stable';

    final recentStart = (widget.data.length - 3).clamp(0, widget.data.length);
    final recent = widget.data.sublist(recentStart);
    if (recent.length < 2) return 'stable';

    final rawFirst = recent.first['measurements']?[widget.parameter];
    final rawLast = recent.last['measurements']?[widget.parameter];
    if (rawFirst == null || rawLast == null) return 'stable';

    final firstValue = (rawFirst as num).toDouble();
    final lastValue = (rawLast as num).toDouble();
    if (firstValue == 0) return 'stable';

    final change = ((lastValue - firstValue) / firstValue * 100).abs();
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
    final hasCurrentValue = currentValue != null && currentValue > 0;

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
                  hasCurrentValue ? currentValue : null,
                  widget.unit,
                  widget.color,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildValueCard(
                  '7-Day Avg',
                  averageValue > 0 ? averageValue : null,
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

  Widget _buildValueCard(String label, double? value, String unit, Color valueColor) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: valueColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
          SizedBox(height: 4.h),
          Text(
            value != null ? '${value.toStringAsFixed(1)} $unit' : '— $unit',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: value != null ? valueColor : Colors.grey[400]!,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    final List<dynamic> chartData = widget.data;

    if (chartData.isEmpty) {
      return Container(
        height: 100.h,
        alignment: Alignment.center,
        child: Text('No data available', style: TextStyle(fontSize: 14.sp, color: Colors.grey[500])),
      );
    }

    // Collect valid (non-null) values for this parameter to compute Y-scale
    double minValue = double.infinity;
    double maxValue = double.negativeInfinity;
    int validCount = 0;

    for (var item in chartData) {
      final rawVal = item['measurements']?[widget.parameter];
      if (rawVal == null) continue;
      double value = rawVal is num ? rawVal.toDouble() : double.tryParse(rawVal.toString()) ?? double.nan;
      if (value.isNaN) continue;
      // Apply soilMoisture normalisation for scale purposes
      if (widget.parameter == 'soilMoisture' && value > 100) value /= 10;
      minValue = value < minValue ? value : minValue;
      maxValue = value > maxValue ? value : maxValue;
      validCount++;
    }

    if (validCount == 0) {
      return Container(
        height: 100.h,
        alignment: Alignment.center,
        child: Text('No sensor readings this week',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500])),
      );
    }

    // Smart Y-scale: parameter-aware padding and physical floor
    final double range = maxValue - minValue;
    final double paddingAmount = range == 0 ? _paramPadding() : range * 0.2;
    minValue = (minValue - paddingAmount).clamp(_paramFloor(), double.infinity);
    maxValue = maxValue + paddingAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Weekly Trend',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: MAIZE_ACCENT),
            ),
            SizedBox(width: 6.w),
            Text(
              '($validCount day${validCount != 1 ? 's' : ''})',
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 90.h,
          width: double.infinity,
          child: CustomPaint(
            painter: WeeklyChartPainter(
              values: const [],
              minValue: minValue,
              maxValue: maxValue,
              color: widget.color,
              data: chartData,
              optimalRange: widget.optimalRange,
              showThreshold: showThreshold,
              parameter: widget.parameter,
              weekStart: getWeekStart(),
            ),
          ),
        ),
      ],
    );
  }

  double _paramFloor() {
    switch (widget.parameter) {
      case 'soilPh': return 4.0;
      case 'temperature': return 0.0;
      default: return 0.0;
    }
  }

  double _paramPadding() {
    switch (widget.parameter) {
      case 'temperature': return 2.0;
      case 'soilPh': return 0.5;
      case 'lightIntensity': return 50.0;
      default: return 5.0;
    }
  }

  // Get the start of the calendar week (Sunday) for the current week offset, in local time.
  DateTime getWeekStart() {
    final now = DateTime.now().toLocal();
    int daysFromSunday = now.weekday == 7 ? 0 : now.weekday;
    final currentWeekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysFromSunday));
    return currentWeekStart.add(Duration(days: widget.weekOffset * 7));
  }
}

class WeeklyChartPainter extends CustomPainter {
  final List<double> values; // kept for API compatibility, unused in drawing
  final double minValue;
  final double maxValue;
  final Color color;
  final List<dynamic> data;
  final String optimalRange;
  final bool showThreshold;
  final String parameter;
  final DateTime weekStart;

  const WeeklyChartPainter({
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

  // Reserve bottom space for day labels
  static const double _labelAreaHeight = 18.0;
  // Horizontal padding so edge labels don't clip
  static const double _hPad = 16.0;

  double _xForDay(int day, double width) =>
      _hPad + (day / 6.0) * (width - 2 * _hPad);

  double _yForValue(double value, double chartHeight) {
    final range = maxValue - minValue;
    if (range == 0) return chartHeight / 2;
    return chartHeight - ((value - minValue) / range * chartHeight).clamp(0.0, chartHeight);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final chartH = size.height - _labelAreaHeight;
    if (chartH <= 0) return;

    final double valueRange = maxValue - minValue;

    // --- Threshold lines ---
    if (showThreshold) {
      final thresholds = _parseOptimalRange(optimalRange);
      final threshPaint = Paint()
        ..color = Colors.grey.withOpacity(0.35)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      final tp = TextPainter(textDirection: TextDirection.ltr);

      for (int t = 0; t < 2; t++) {
        final tv = thresholds[t];
        if (tv < minValue || tv > maxValue) continue;
        final ty = _yForValue(tv, chartH);
        canvas.drawLine(Offset(_hPad, ty), Offset(size.width - _hPad, ty), threshPaint);

        tp.text = TextSpan(
          text: tv.toStringAsFixed(1),
          style: TextStyle(color: Colors.grey[500], fontSize: 9.5.sp),
        );
        tp.layout();
        double labelY = t == 1 ? ty - tp.height - 1 : ty + 2;
        labelY = labelY.clamp(0, chartH - tp.height);
        tp.paint(canvas, Offset(size.width - _hPad - tp.width - 2, labelY));
      }
    }

    // --- Build day→value map (null = no sensor reading that day) ---
    final Map<int, double> dayValues = {};
    final wsDate = DateTime(weekStart.year, weekStart.month, weekStart.day);

    for (final item in data) {
      final rawTs = item['timestamp'] as String?;
      if (rawTs == null) continue;
      final parsed = DateTime.parse(rawTs.contains('T') ? rawTs : '${rawTs}T00:00:00');
      final ts = parsed.toLocal(); // convert to device local time so day labels match the user's timezone
      final daysDiff = DateTime(ts.year, ts.month, ts.day).difference(wsDate).inDays;
      if (daysDiff < 0 || daysDiff > 6) continue;

      final rawVal = item['measurements']?[parameter];
      if (rawVal == null) continue;
      double v = rawVal is num ? rawVal.toDouble() : double.tryParse(rawVal.toString()) ?? double.nan;
      if (v.isNaN) continue;
      if (parameter == 'soilMoisture' && v > 100) v /= 10;
      dayValues[daysDiff] = v;
    }

    // --- Build ordered screen points for existing days only ---
    final List<Offset> pts = [];
    for (int i = 0; i < 7; i++) {
      if (!dayValues.containsKey(i)) continue;
      final v = dayValues[i]!.clamp(minValue, maxValue);
      pts.add(Offset(_xForDay(i, size.width), _yForValue(v, chartH)));
    }

    if (pts.isEmpty) {
      // Draw "no data" label in chart area
      final tp = TextPainter(textDirection: TextDirection.ltr)
        ..text = TextSpan(
          text: 'No readings',
          style: TextStyle(color: Colors.grey[400], fontSize: 11.sp),
        )
        ..layout();
      tp.paint(canvas, Offset((size.width - tp.width) / 2, (chartH - tp.height) / 2));
    } else if (pts.length == 1) {
      final dotPaint = Paint()..color = color..style = PaintingStyle.fill;
      canvas.drawCircle(pts.first, 4, dotPaint);
      final linePaint = Paint()..color = color..strokeWidth = 2..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(pts.first.dx - 12, pts.first.dy), Offset(pts.first.dx + 12, pts.first.dy), linePaint);
    } else {
      // --- Fill area (smooth, using same control points) ---
      final fillPath = _buildSmoothPath(pts);
      fillPath.lineTo(pts.last.dx, chartH);
      fillPath.lineTo(pts.first.dx, chartH);
      fillPath.close();
      canvas.drawPath(fillPath, Paint()..color = color.withOpacity(0.12)..style = PaintingStyle.fill);

      // --- Smooth line ---
      canvas.drawPath(
        _buildSmoothPath(pts),
        Paint()..color = color..strokeWidth = 2.2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round,
      );

      // --- Data points ---
      final dotPaint = Paint()..color = color..style = PaintingStyle.fill;
      final dotBg = Paint()..color = Colors.white..style = PaintingStyle.fill;
      for (final pt in pts) {
        canvas.drawCircle(pt, 4, dotBg);
        canvas.drawCircle(pt, 3, dotPaint);
      }
    }

    // --- Y-axis scale labels (min/max) ---
    if (valueRange > 0) {
      final tp = TextPainter(textDirection: TextDirection.ltr);
      tp.text = TextSpan(
        text: maxValue.toStringAsFixed(1),
        style: TextStyle(color: Colors.grey[400], fontSize: 9.sp),
      );
      tp.layout();
      tp.paint(canvas, Offset(0, 0));

      tp.text = TextSpan(
        text: minValue.toStringAsFixed(1),
        style: TextStyle(color: Colors.grey[400], fontSize: 9.sp),
      );
      tp.layout();
      tp.paint(canvas, Offset(0, chartH - tp.height));
    }

    // --- Day labels ---
    const dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < 7; i++) {
      final hasData = dayValues.containsKey(i);
      tp.text = TextSpan(
        text: dayNames[i],
        style: TextStyle(
          color: hasData ? color.withOpacity(0.8) : Colors.grey[400],
          fontSize: 9.5.sp,
          fontWeight: hasData ? FontWeight.w600 : FontWeight.normal,
        ),
      );
      tp.layout();
      final x = _xForDay(i, size.width);
      tp.paint(canvas, Offset((x - tp.width / 2).clamp(0, size.width - tp.width), chartH + 4));
    }
  }

  /// Catmull-Rom spline path through [points].
  Path _buildSmoothPath(List<Offset> points) {
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i < points.length - 2 ? points[i + 2] : points[i + 1];
      final cp1 = Offset(p1.dx + (p2.dx - p0.dx) / 6, p1.dy + (p2.dy - p0.dy) / 6);
      final cp2 = Offset(p2.dx - (p3.dx - p1.dx) / 6, p2.dy - (p3.dy - p1.dy) / 6);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }
    return path;
  }

  List<double> _parseOptimalRange(String range) {
    // e.g. "20-30°C", "6.0-7.5", "50-70%"
    final nums = RegExp(r'\d+\.?\d*').allMatches(range).map((m) => double.parse(m.group(0)!)).toList();
    if (nums.length >= 2) return [nums[0], nums[1]];
    return [0.0, 100.0];
  }

  @override
  bool shouldRepaint(WeeklyChartPainter old) =>
      old.minValue != minValue ||
      old.maxValue != maxValue ||
      old.data != data ||
      old.showThreshold != showThreshold ||
      old.weekStart != weekStart;
}
