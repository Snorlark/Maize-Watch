import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:maize_watch/custom/constants.dart';
import 'package:maize_watch/custom/custom_font.dart';
import 'package:maize_watch/model/sensor_data_model.dart';
import 'package:maize_watch/model/corn_field_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:maize_watch/widget/crop_condition_widget.dart';
import 'package:maize_watch/services/api_service.dart'; // Import ApiService

class CornProgressWidget extends StatefulWidget {
  final SensorReading? currentData;
  final List<SensorReading>? historicalData;
  final CornField cornField;

  const CornProgressWidget({
    Key? key,
    required this.currentData,
    this.historicalData,
    required this.cornField,
  }) : super(key: key);

  @override
  State<CornProgressWidget> createState() => _CornProgressWidgetState();
}

class _StageProgressPainter extends CustomPainter {
  final double progress;
  final int stageCount;

  _StageProgressPainter({required this.progress, required this.stageCount});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final stageWidth = size.width / (stageCount - 1);
    final progressWidth = size.width * progress;

    // Draw background track
    paint.color = Colors.green[100]!;
    canvas.drawLine(
        Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);

    // Draw progress track
    paint.color = MAIZE_PRIMARY;
    canvas.drawLine(Offset(0, size.height / 2),
        Offset(progressWidth, size.height / 2), paint);
  }
  

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _CornProgressWidgetState extends State<CornProgressWidget>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  final ApiService _apiService =
      ApiService(); // Create an instance of ApiService
  bool _isLoading = true;
  bool _hasAuthError = false;

  double _currentProgress = 0.0;
  int _currentStageIndex = 0;

  // Growth trend data
  double _growthRate = 0.0;
  int _daysToNextStage = -1;
  String _trendKey = "stable";

  // Stage information
  String _currentStageName = "";
  String _currentStageDescription = "";

  // Define growth stages with progress values
  final List<Map<String, dynamic>> cornStages = [
    {"stage": "VE", "progress": 0.17},
    {"stage": "V3", "progress": 0.25},
    {"stage": "V8", "progress": 0.45},
    {"stage": "VT", "progress": 0.55},
    {"stage": "R1", "progress": 0.60},
    {"stage": "R6", "progress": 1.0},
  ];

@override
void initState() {
  super.initState();
  _controller = AnimationController(vsync: this);
  _controller.addListener(() {
    setState(() {
      _currentProgress = _controller.value;
    });
  });
  
  // Call this after a short delay to ensure everything is properly initialized
  Future.delayed(Duration.zero, () {
    _updateBasedOnFieldData();
  });
}

void _onLottieLoaded(composition) {
  _controller.duration = composition.duration;
  // Don't call _updateBasedOnFieldData() here as it's already called in initState
  
  // If the data is already loaded, animate directly to the right position
  if (!_isLoading) {
    final stageIndex = _currentStageIndex;
    final targetProgress = cornStages[stageIndex]["progress"] as double;
    _controller.animateTo(
      targetProgress,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
    );
  }
}

  void _updateBasedOnFieldData() {
    setState(() {
      _isLoading = true;
    });

    // Debug logs to understand what's happening
    print("DEBUG - CornField data:");
    print("Field Name: ${widget.cornField.fieldName}");
    print("Growth Stage from cornField: '${widget.cornField.growthStage}'");

    // Find stage index based on growthStage from cornField
    final stageCode = widget.cornField.growthStage.trim().toUpperCase();
    print("Current growth stage from data: $stageCode"); // Debug print

    int stageIndex = 0;
    double targetProgress = 0.0;
    bool stageFound = false;

    // First try exact match
    for (int i = 0; i < cornStages.length; i++) {
      String currentStageCode =
          cornStages[i]["stage"].toString().trim().toUpperCase();
      print(
          "Comparing with stage: $currentStageCode"); // Debug exactly what we're comparing

      if (currentStageCode == stageCode) {
        stageIndex = i;
        targetProgress = cornStages[i]["progress"] as double;
        stageFound = true;
        print(
            "Stage found: ${cornStages[i]["stage"]} at index $i with progress $targetProgress");
        break;
      }
    }

    // If the exact stage wasn't found, try to find a close match
    if (!stageFound) {
      print("Stage not found. Looking for partial matches..."); // Debug print
      for (int i = 0; i < cornStages.length; i++) {
        if (stageCode.contains(
                cornStages[i]["stage"].toString().trim().toUpperCase()) ||
            cornStages[i]["stage"]
                .toString()
                .trim()
                .toUpperCase()
                .contains(stageCode)) {
          stageIndex = i;
          targetProgress = cornStages[i]["progress"] as double;
          stageFound = true;
          print(
              "Partial match found: ${cornStages[i]["stage"]} at index $i"); // Debug print
          break;
        }
      }

      // If still not found, use a default based on the string value
      if (!stageFound) {
        // Try to match the first character of the stage code
        if (stageCode.startsWith("V")) {
          // It's a vegetative stage - find the highest possible match
          if (stageCode.contains("T")) {
            stageIndex = 3; // VT stage
            targetProgress = cornStages[3]["progress"] as double;
            print("Defaulting to VT stage based on code");
          } else if (stageCode.contains("8") || stageCode.contains("9")) {
            stageIndex = 2; // V8 stage
            targetProgress = cornStages[2]["progress"] as double;
            print("Defaulting to V8 stage based on code");
          } else if (stageCode.contains("3") ||
              stageCode.contains("4") ||
              stageCode.contains("5")) {
            stageIndex = 1; // V3 stage
            targetProgress = cornStages[1]["progress"] as double;
            print("Defaulting to V3 stage based on code");
          } else {
            stageIndex = 0; // VE stage
            targetProgress = cornStages[0]["progress"] as double;
            print("Defaulting to VE stage based on code");
          }
        } else if (stageCode.startsWith("R")) {
          // It's a reproductive stage
          if (stageCode.contains("6")) {
            stageIndex = 5; // R6 stage
            targetProgress = cornStages[5]["progress"] as double;
            print("Defaulting to R6 stage based on code");
          } else {
            stageIndex = 4; // R1 stage
            targetProgress = cornStages[4]["progress"] as double;
            print("Defaulting to R1 stage based on code");
          }
        }
      }
    }

    // Update stage information from the localizations
    _updateStageInformation(stageIndex);

    print(
        "Setting stage index to: $stageIndex with progress: $targetProgress"); // Debug print

    setState(() {
      _currentStageIndex = stageIndex;
      _isLoading = false;

      // Reset controller before animating to ensure it starts fresh
      _controller.reset();

      // Animate to the appropriate progress
      _controller.animateTo(
        targetProgress,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
      );
    });

    // Calculate growth trend if historical data is available
    if (widget.historicalData != null && widget.historicalData!.isNotEmpty) {
      _calculateGrowthTrend();
    }
  }

  // Get localized stage name and description from AppLocalizations
  void _updateStageInformation(int stageIndex) {
    final localizations = AppLocalizations.of(context)!;
    final stageCode = cornStages[stageIndex]["stage"].toString();

    setState(() {
      switch (stageCode) {
        case "VE":
          _currentStageName = localizations.growth_stage_ve;
          _currentStageDescription = localizations.growth_stage_ve_desc;
          break;
        case "V3":
          _currentStageName = localizations.growth_stage_v3;
          _currentStageDescription = localizations.growth_stage_v3_desc;
          break;
        case "V8":
          _currentStageName = localizations.growth_stage_v8;
          _currentStageDescription = localizations.growth_stage_v8_desc;
          break;
        case "VT":
          _currentStageName = localizations.growth_stage_vt;
          _currentStageDescription = localizations.growth_stage_vt_desc;
          break;
        case "R1":
          _currentStageName = localizations.growth_stage_r1;
          _currentStageDescription = localizations.growth_stage_r1_desc;
          break;
        case "R6":
          _currentStageName = localizations.growth_stage_r6;
          _currentStageDescription = localizations.growth_stage_r6_desc;
          break;
        default:
          _currentStageName = stageCode;
          _currentStageDescription = "";
      }
    });
  }

  void _calculateGrowthTrend() {
    if (widget.historicalData == null || widget.historicalData!.length <= 1)
      return;

    double sumOfChanges = 0.0;
    int count = 0;

    for (int i = 1; i < widget.historicalData!.length; i++) {
      final prev = widget.historicalData![i - 1];
      final curr = widget.historicalData![i];

      final prevAvg = (prev.temperature +
              prev.soilMoisture +
              prev.humidity +
              prev.lightIntensity) /
          4;

      final currAvg = (curr.temperature +
              curr.soilMoisture +
              curr.humidity +
              curr.lightIntensity) /
          4;

      sumOfChanges += currAvg - prevAvg;
      count++;
    }

    final rate = count > 0 ? sumOfChanges / count : 0.0;
    String trend;
    if (rate > 0.5) {
      trend = "increasing";
    } else if (rate < -0.5) {
      trend = "decreasing";
    } else {
      trend = "stable";
    }

    setState(() {
      _growthRate = rate;
      _trendKey = trend;
      _daysToNextStage = 5; // Hardcoded for now
    });
  }

  @override
  void didUpdateWidget(CornProgressWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentData != widget.currentData ||
        oldWidget.historicalData != widget.historicalData ||
        oldWidget.cornField.growthStage != widget.cornField.growthStage) {
      _updateBasedOnFieldData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Verify authentication when dependencies change (like when coming back to the screen)
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatGrowthRate() {
    final percentage = (_growthRate * 100).toStringAsFixed(1);
    return "$percentage%";
  }

  String _getDaysSincePlanting() {
    final now = DateTime.now();
    final plantingDate = widget.cornField.plantingDate;
    final difference = now.difference(plantingDate);
    return difference.inDays.toString();
  }

  // Show a login prompt if needed
  Widget _buildAuthErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Session expired',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Please log in again to view your corn data',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to login screen
              // Navigator.of(context).pushReplacementNamed('/login');
            },
            child: Text('Log In'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // If we have an auth error, show login prompt
    if (_hasAuthError) {
      return _buildAuthErrorWidget();
    }

    // If data is loading, show a loading indicator
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    final currentStage = cornStages[_currentStageIndex]["stage"];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 8.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Field info and condition icon - Keep this outside scrollable area
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomFont(
                      text: widget.cornField.fieldName,
                      fontWeight: FontWeight.bold,
                      fontSize: 25.sp,
                    ),
                    CustomFont(
                      text: widget.cornField.location,
                      fontSize: 14,
                      color: MAIZE_ACCENT,
                    ),
                  ],
                ),
              ),
              // Days since planting overlay
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, size: 15.r, color: MAIZE_ACCENT),
                    SizedBox(width: 5.w),
                    CustomFont(
                      text: "${_getDaysSincePlanting()} ${localizations.days}",
                      color: MAIZE_ACCENT,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),

          // Wrap everything else in Expanded + SingleChildScrollView
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(
                    // Wrap the Stack with a SizedBox to give it a height
                    height: MediaQuery.of(context).size.height *
                        0.35, // Adjust as needed
                    child: Stack(
                      children: [
                        // Lottie on the right side
                        Positioned(
                          top: 0,
                          bottom: 0,
                          right: 0,
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Lottie.asset(
                            'assets/lottie/corn_growth.json',
                            controller: _controller,
                            fit: BoxFit.cover,
                            onLoaded: (composition) {
                              _controller.duration = composition.duration;
                              _controller.reset();
                              _updateBasedOnFieldData();
                            },
                          ),
                        ),

                        // Overlay text on the left side
                        Positioned(
                          top: 20.h,
                          left: 1.w,
                          child: Column(
                            children: [
                              Container(
                                width: 130.w,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 12.h),
                                decoration: BoxDecoration(
                                  color: MAIZE_LOGO_ICON,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize
                                        .min, // Important for adaptability
                                    children: [
                                      CustomFont(
                                        text:
                                            "Stage: ${widget.cornField.growthStage}",
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ]),
                              ),
                              SizedBox(height: 10.h),
                              Container(
                                width: 130.w,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 12.h),
                                decoration: BoxDecoration(
                                  color: MAIZE_LOGO_ICON,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize
                                        .min, // Important for adaptability
                                    children: [
                                      CustomFont(
                                        text: _currentStageName,
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      SizedBox(
                                          height: 8
                                              .h), // Optional spacing between text
                                      CustomFont(
                                        text: _currentStageDescription,
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                      ),
                                    ]),
                              ),
                              SizedBox(height: 10.h),
                              Container(
                                width: 130.w,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 12.h),
                                decoration: BoxDecoration(
                                  color: MAIZE_LOGO_ICON,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize
                                        .min, // Important for adaptability
                                    children: [
                                      CustomFont(
                                        text: localizations.soil_type,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                      SizedBox(height: 2.h),
                                      CustomFont(
                                        text: widget.cornField.soilType,
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // Custom progress bar with stage indicators
                  Container(
                    height: 60.h,
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Stack(
                      children: [
                        // Background progress line
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _StageProgressPainter(
                              progress: _currentProgress,
                              stageCount: cornStages.length,
                            ),
                          ),
                        ),

                        // Stage markers and labels
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(cornStages.length, (index) {
                            final stage = cornStages[index]["stage"];
                            final isActive = index == _currentStageIndex;
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  width: isActive ? 20.r : 14.r,
                                  height: isActive ? 20.r : 14.r,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? MAIZE_ACCENT
                                        : MAIZE_LOGO_ICON,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                CustomFont(
                                  text: stage,
                                  fontSize: 12,
                                  color:
                                      isActive ? MAIZE_ACCENT : MAIZE_LOGO_ICON,
                                ),
                              ],
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  // // Growth trend info
                  // if (_daysToNextStage > 0)
                  //   Padding(
                  //     padding: const EdgeInsets.symmetric(vertical: 12),
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Text(
                  //           "Growth Trend: ${_trendKey.toUpperCase()}",
                  //           style: TextStyle(
                  //             fontWeight: FontWeight.bold,
                  //             fontSize: 16.sp,
                  //             color: Colors.black87,
                  //           ),
                  //         ),
                  //         Text(
                  //           "Avg. Rate of Change: ${_growthRate.toStringAsFixed(2)}",
                  //           style: TextStyle(
                  //             fontSize: 14.sp,
                  //             color: Colors.grey[800],
                  //           ),
                  //         ),
                  //         if (_daysToNextStage > -1)
                  //           Text(
                  //             "Est. Days to Next Stage: $_daysToNextStage",
                  //             style: TextStyle(
                  //               fontSize: 14.sp,
                  //               color: Colors.grey[700],
                  //             ),
                  //           ),
                  //         Icon(
                  //           _trendKey == "increasing"
                  //               ? Icons.trending_up
                  //               : _trendKey == "decreasing"
                  //                   ? Icons.trending_down
                  //                   : Icons.trending_flat,
                  //           color: _trendKey == "increasing"
                  //               ? Colors.green
                  //               : _trendKey == "decreasing"
                  //                   ? Colors.red
                  //                   : Colors.grey,
                  //         )
                  //       ],
                  //     ),
                  //   ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
