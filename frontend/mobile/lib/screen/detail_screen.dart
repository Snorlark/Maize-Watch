import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:maize_watch/custom/constants.dart';
import 'dart:convert';
import '../custom/custom_font.dart';
import 'dart:async';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isLoading = true;
  Map<String, dynamic> weeklyData = {};
  String errorMessage = '';
  int currentWeekOffset = 0; // 0 for current week, -1 for previous week, etc.

  @override
  void initState() {
    super.initState();
    fetchWeeklyData();
  }

  // Get the start of the calendar week (Sunday)
  DateTime getStartOfWeek(DateTime date) {
    // Convert to Sunday = 0, Monday = 1, ..., Saturday = 6
    int daysFromSunday = date.weekday == 7 ? 0 : date.weekday;
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: daysFromSunday));
  }

  // Get the end of the calendar week (Saturday at 23:59:59)
  DateTime getEndOfWeek(DateTime date) {
    DateTime startOfWeek = getStartOfWeek(date);
    return startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
  }

  // Get the current calendar week's start date
  DateTime getCurrentWeekStart() {
    final now = DateTime.now();
    return getStartOfWeek(now);
  }

  Future<void> fetchWeeklyData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      // Calculate the date range for the selected week based on current calendar week
      final currentWeekStart = getCurrentWeekStart();
      final targetWeekStart = currentWeekStart.add(Duration(days: currentWeekOffset * 7));
      final startDate = targetWeekStart;
      final endDate = getEndOfWeek(targetWeekStart);

      print('Fetching data for week: ${startDate.toIso8601String()} to ${endDate.toIso8601String()}');

      // Replace with your actual backend URL
      final String backendUrl = 'https://maize-watch.onrender.com'; // Updated to cloud backend
      
      final uri = Uri.parse('$backendUrl/api/sensors/weekly-overview')
          .replace(queryParameters: {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      });

      print('Request URL: $uri');

      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            weeklyData = data;
            isLoading = false;
          });
          print('Data loaded successfully: ${data['data']?.length ?? 0} data points');
        } else {
          throw Exception('API returned error: ${data['error']}');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load data: ${e.toString()}';
        isLoading = false;
      });
      print('Error fetching weekly data: $e');
    }
  }

  String getDateRange() {
    final currentWeekStart = getCurrentWeekStart();
    final targetWeekStart = currentWeekStart.add(Duration(days: currentWeekOffset * 7));
    final startDate = targetWeekStart;
    final endDate = getEndOfWeek(targetWeekStart);

    return '${_formatDate(startDate)} - ${_formatDate(endDate)}';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]}. ${date.day}';
  }

  void _navigateWeek(int offset) {
    // Don't allow navigation to future weeks
    if (currentWeekOffset + offset > 0) {
      return; // Cannot go to future weeks
    }
    
    setState(() {
      currentWeekOffset += offset;
    });
    fetchWeeklyData();
  }

  bool _canNavigateNext() {
    return currentWeekOffset < 0; // Can only navigate forward if we're in past weeks
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: MAIZE_ACCENT,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                ScreenUtil().setSp(30),
                ScreenUtil().setSp(50),
                ScreenUtil().setSp(30),
                ScreenUtil().setSp(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        CustomFont(
                          text: 'Maize Field 1',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Weekly navigation in calendar style
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: Colors.white),
                        onPressed: () => _navigateWeek(-1),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        children: [
                          CustomFont(
                            text: currentWeekOffset == 0 ? 'This Week' : 'Weekly Overview',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 4),
                          CustomFont(
                            text: getDateRange(),
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: Icon(
                          Icons.chevron_right, 
                          color: _canNavigateNext() ? Colors.white : Colors.white30,
                        ),
                        onPressed: _canNavigateNext() ? () => _navigateWeek(1) : null,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                else if (errorMessage.isNotEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          CustomFont(
                            text: errorMessage,
                            fontSize: 16,
                            color: Colors.white,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: fetchWeeklyData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: fetchWeeklyData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            // Debug info (remove in production)
                            if (weeklyData['data'] != null)
                              Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: CustomFont(
                                  text: 'Data points: ${weeklyData['data'].length}',
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ParameterWidget(
                              title: 'Temperature',
                              unit: '°C',
                              icon: Icons.thermostat,
                              color: Colors.orange,
                              data: weeklyData['data'] ?? [],
                              parameter: 'temperature',
                              optimalRange: '20-30°C',
                              weekOffset: currentWeekOffset,
                            ),
                            const SizedBox(height: 50),
                            ParameterWidget(
                              title: 'Humidity',
                              unit: '%',
                              icon: Icons.water_drop,
                              color: Colors.blue,
                              data: weeklyData['data'] ?? [],
                              parameter: 'humidity',
                              optimalRange: '60-80%',
                              weekOffset: currentWeekOffset,
                            ),
                            const SizedBox(height: 50),
                            ParameterWidget(
                              title: 'Soil Moisture',
                              unit: '%',
                              icon: Icons.grass,
                              color: Colors.green,
                              data: weeklyData['data'] ?? [],
                              parameter: 'soil_moisture',
                              optimalRange: '40-70%',
                              weekOffset: currentWeekOffset,
                            ),
                            const SizedBox(height: 50),
                            ParameterWidget(
                              title: 'Soil pH',
                              unit: 'pH',
                              icon: Icons.science,
                              color: Colors.lightBlue,
                              data: weeklyData['data'] ?? [],
                              parameter: 'soil_ph',
                              optimalRange: '6.0-7.0',
                              weekOffset: currentWeekOffset,
                            ),
                            const SizedBox(height: 50),
                            ParameterWidget(
                              title: 'Light Intensity',
                              unit: 'lux',
                              icon: Icons.wb_sunny,
                              color: Colors.amber,
                              data: weeklyData['data'] ?? [],
                              parameter: 'light_intensity',
                              optimalRange: '5000-10000',
                              weekOffset: currentWeekOffset,
                            ),
                            const SizedBox(height: 50),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
    // Set up periodic refresh every 15 seconds
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      fetchLiveData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchLiveData() async {
    try {
      final response = await http.get(
        Uri.parse('https://maize-watch.onrender.com/api/sensors/latest'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          setState(() {
            liveData = data['data'];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching live data: $e');
    }
  }

  double getCurrentValue() {
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
    if (widget.parameter == 'soil_moisture') {
      apiParameter = 'soilMoisture';
    } else if (widget.parameter == 'light_intensity') {
      apiParameter = 'lightIntensity';
    } else if (widget.parameter == 'soil_ph') {
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
      case 'soil_ph':
        // Return 0.0 if soil pH is 0 or null
        return parsedValue == 0 ? 0.0 : parsedValue;
      case 'soil_moisture':
        // Convert soil moisture to percentage if needed
        return parsedValue > 100 ? parsedValue / 10 : parsedValue;
      case 'light_intensity':
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
              case 'soil_ph':
                if (value != 0) {
                  sum += value.toDouble();
                  count++;
                }
                break;
              case 'soil_moisture':
                double moistureValue = value.toDouble();
                // Convert to percentage if needed
                if (moistureValue > 100) {
                  moistureValue = moistureValue / 10;
                }
                sum += moistureValue;
                count++;
                break;
              case 'light_intensity':
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomFont(
                      text: widget.title,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    CustomFont(
                      text: 'Optimal: ${widget.optimalRange}',
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  showThreshold ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white70,
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
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 20),

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
              const SizedBox(width: 16),
              Expanded(
                child: _buildValueCard(
                  '7-Day Avg',
                  averageValue,
                  widget.unit,
                  Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Weekly Chart
          _buildWeeklyChart(),
        ],
      ),
    );
  }

  Widget _buildValueCard(
      String label, double value, String unit, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomFont(
            text: label,
            fontSize: 12,
            color: Colors.white70,
          ),
          const SizedBox(height: 4),
          CustomFont(
            text: '${value.toStringAsFixed(1)} $unit',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    if (widget.data.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        child: CustomFont(
          text: 'No data available',
          fontSize: 14,
          color: Colors.white70,
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
      height: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomFont(
            text: 'Weekly Trend',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
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
    if (parameter == 'light_intensity') {
      actualMin = 0;
      actualMax = 10000;
    }

    if (showThreshold) {
      // Parse optimal range and draw threshold lines
      List<double> thresholds = _parseOptimalRange(optimalRange);
      double lowerThreshold = thresholds[0];
      double upperThreshold = thresholds[1];

      // Ensure thresholds are within the visible range
      if (parameter == 'light_intensity') {
        lowerThreshold = lowerThreshold.clamp(0, 10000);
        upperThreshold = upperThreshold.clamp(0, 10000);
      }

      final thresholdPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
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
        style: TextStyle(color: Colors.white70, fontSize: 10),
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
        style: TextStyle(color: Colors.white70, fontSize: 10),
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
        style: TextStyle(color: Colors.white70, fontSize: 10),
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