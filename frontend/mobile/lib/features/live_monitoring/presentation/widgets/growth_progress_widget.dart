import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/sensor_reading.dart';

class GrowthProgressWidget extends StatefulWidget {
  final String currentGrowthStage;
  final List<SensorReading>? historicalData;
  final DateTime plantingDate;
  final VoidCallback? onStageChange;
  final void Function(int days)? onDaysCalculated;

  const GrowthProgressWidget({
    super.key,
    required this.currentGrowthStage,
    this.historicalData,
    required this.plantingDate,
    this.onStageChange,
    this.onDaysCalculated,
  });

  @override
  State<GrowthProgressWidget> createState() => _GrowthProgressWidgetState();
}

class _StageProgressPainter extends CustomPainter {
  final double progress;
  final int stageCount;

  _StageProgressPainter({required this.progress, required this.stageCount});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final progressWidth = size.width * progress;

    // Background track
    paint.color = Colors.white.withOpacity(0.3);
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    // Progress track
    paint.color = Colors.white;
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(progressWidth, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _GrowthProgressWidgetState extends State<GrowthProgressWidget>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isLoading = true;

  double _currentProgress = 0.0;
  int _currentStageIndex = 0;

  final List<Map<String, dynamic>> cornStages = [
    {"stage": "VE",  "progress": 0.10, "name": "Emergence"},
    {"stage": "V3",  "progress": 0.25, "name": "3rd Leaf"},
    {"stage": "V6",  "progress": 0.40, "name": "6th Leaf"},
    {"stage": "V8",  "progress": 0.55, "name": "8th Leaf"},
    {"stage": "V12", "progress": 0.70, "name": "12th Leaf"},
    {"stage": "VT",  "progress": 0.80, "name": "Tasseling"},
    {"stage": "R1",  "progress": 0.85, "name": "Silking"},
    {"stage": "R3",  "progress": 0.90, "name": "Milk Stage"},
    {"stage": "R6",  "progress": 1.0,  "name": "Maturity"},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addListener(() {
      setState(() => _currentProgress = _controller.value);
    });
    Future.delayed(Duration.zero, _updateBasedOnGrowthStage);
  }

  void _onLottieLoaded(LottieComposition composition) {
    _controller.duration = composition.duration;
    if (!_isLoading) {
      _controller.animateTo(
        cornStages[_currentStageIndex]["progress"] as double,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  void _updateBasedOnGrowthStage() {
    setState(() => _isLoading = true);
    final stageCode = widget.currentGrowthStage.trim().toUpperCase();

    int stageIndex = 0;
    double targetProgress = 0.0;

    for (int i = 0; i < cornStages.length; i++) {
      if (cornStages[i]["stage"].toString().toUpperCase() == stageCode) {
        stageIndex = i;
        targetProgress = cornStages[i]["progress"] as double;
        break;
      }
    }

    setState(() {
      _currentStageIndex = stageIndex;
      _isLoading = false;
      _controller.reset();
      _controller.animateTo(
        targetProgress,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });

    if (widget.historicalData?.isNotEmpty ?? false) {
      _calculateGrowthTrend();
    } else {
      final days = _calculateDaysToNextStage();
      widget.onDaysCalculated?.call(days);
    }
    widget.onStageChange?.call();
  }

  void _calculateGrowthTrend() {
    for (int i = 1; i < widget.historicalData!.length; i++) {
      // trend calculation reserved for future use
    }
    final days = _calculateDaysToNextStage();
    widget.onDaysCalculated?.call(days);
  }

  int _calculateDaysToNextStage() {
    final daysFromPlanting =
        DateTime.now().difference(widget.plantingDate).inDays;
    final stageDurations = [7, 14, 21, 14, 7, 30, 14, 14, 30];
    int totalDays = 0;
    for (int i = 0; i <= _currentStageIndex && i < stageDurations.length; i++) {
      totalDays += stageDurations[i];
    }
    final nextDurationIndex = _currentStageIndex + 1;
    if (nextDurationIndex >= stageDurations.length) return -1;
    final remaining =
        (totalDays + stageDurations[nextDurationIndex]) - daysFromPlanting;
    return remaining > 0 ? remaining : 1;
  }

  String _getDaysSincePlanting() =>
      DateTime.now().difference(widget.plantingDate).inDays.toString();

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        height: 220.h,
        child: Center(
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20.w,
        vertical: 12.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Corn Lottie animation at the top
          SizedBox(
            height: 130.h,
            width: 130.w,
            child: Lottie.asset(
              'assets/lottie/corn_growth.json',
              controller: _controller,
              fit: BoxFit.contain,
              onLoaded: _onLottieLoaded,
            ),
          ),

          verticalSpace(8),

          // 2. Stage badge + Day counter
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'Stage: ${widget.currentGrowthStage}',
                  style: TextStyle(
                    color: MAIZE_PRIMARY,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'Day ${_getDaysSincePlanting()}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          verticalSpace(12),

          // 3. Stage progress bar
          SizedBox(
            height: 50.h,
            child: Stack(
              children: [
                Positioned(
                  top: 24.h,
                  left: 0,
                  right: 0,
                  child: CustomPaint(
                    painter: _StageProgressPainter(
                      progress: _currentProgress,
                      stageCount: cornStages.length,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(cornStages.length, (i) {
                    final isActive = i == _currentStageIndex;
                    final isPassed = i < _currentStageIndex;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: isActive ? 18.w : 14.w,
                          height: isActive ? 18.h : 14.h,
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.white
                                : isPassed
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                            border: isActive
                                ? Border.all(
                                    color: Colors.white.withOpacity(0.5),
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: isActive || isPassed
                              ? Icon(
                                  isPassed ? Icons.check : Icons.circle,
                                  color: isActive
                                      ? MAIZE_PRIMARY
                                      : Colors.white.withOpacity(0.7),
                                  size: 8.sp,
                                )
                              : null,
                        ),
                        verticalSpace(8),
                        Text(
                          cornStages[i]["stage"],
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: isActive
                                ? Colors.white
                                : Colors.white.withOpacity(0.7),
                            fontWeight: isActive
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  @override
  void didUpdateWidget(GrowthProgressWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentGrowthStage != widget.currentGrowthStage ||
        oldWidget.historicalData != widget.historicalData) {
      _updateBasedOnGrowthStage();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
