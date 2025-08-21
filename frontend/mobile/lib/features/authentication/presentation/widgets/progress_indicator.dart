import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/theme/colors.dart';

class BuildProgressIndicator extends StatelessWidget {
  final int currentPage; // Example current page, replace with actual logic
  const BuildProgressIndicator({super.key, this.currentPage = 0});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: (currentPage + 1) / 2,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(MAIZE_ACCENT),
          ),
        ),
        SizedBox(width: 10.w),
        Text(
          '${currentPage + 1}/2',
          style: TextStyle(color: MAIZE_ACCENT, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
