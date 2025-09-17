import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class GrowthStageLottie extends StatefulWidget {
  final String growthStage;
  final double width;
  final double height;
  final BoxFit fit;

  const GrowthStageLottie({
    super.key,
    required this.growthStage,
    this.width = 200,
    this.height = 200,
    this.fit = BoxFit.contain,
  });

  @override
  State<GrowthStageLottie> createState() => _GrowthStageLottieState();
}

class _GrowthStageLottieState extends State<GrowthStageLottie>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  // Map growth stages to animation progress (0.0 to 1.0)
  final Map<String, double> _growthStageProgress = {
    'VE': 0.1,   // Emergence - just starting
    'V1': 0.15,  // First leaf
    'V2': 0.2,   // Second leaf
    'V3': 0.25,  // Third leaf
    'V4': 0.3,   // Fourth leaf
    'V5': 0.35,  // Fifth leaf
    'V6': 0.4,   // Sixth leaf
    'V7': 0.45,  // Seventh leaf
    'V8': 0.5,   // Eighth leaf
    'V9': 0.55,  // Ninth leaf
    'V10': 0.6,  // Tenth leaf
    'V11': 0.65, // Eleventh leaf
    'V12': 0.7,  // Twelfth leaf
    'VT': 0.75,  // Tasseling
    'R1': 0.8,   // Silking
    'R2': 0.85,  // Blister
    'R3': 0.9,   // Milk
    'R4': 0.95,  // Dough
    'R5': 0.98,  // Dent
    'R6': 1.0,   // Maturity
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _updateAnimationProgress();
  }

  void _updateAnimationProgress() {
    final progress = _growthStageProgress[widget.growthStage] ?? 0.1;
    
    // Animate to the target progress
    _controller.animateTo(
      progress,
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(GrowthStageLottie oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.growthStage != widget.growthStage) {
      _updateAnimationProgress();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width.w,
      height: widget.height.h,
      child: Lottie.asset(
        'assets/lottie/corn_growth.json',
        controller: _controller,
        fit: widget.fit,
        repeat: false,
        animate: true,
        onLoaded: (composition) {
          _controller.duration = composition.duration;
          _updateAnimationProgress();
        },
      ),
    );
  }
}
