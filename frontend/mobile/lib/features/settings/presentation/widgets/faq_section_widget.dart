import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/theme/colors.dart';

class FAQSectionWidget extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onToggle;

  const FAQSectionWidget({
    super.key,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  State<FAQSectionWidget> createState() => _FAQSectionWidgetState();
}

class _FAQSectionWidgetState extends State<FAQSectionWidget> {
  final List<Map<String, String>> faqs = [
    {
      'question': 'How do I add a new sensor?',
      'answer': 'Go to the Farm Management section and tap "Add Sensor". Follow the setup instructions to connect your sensor to the app.',
    },
    {
      'question': 'Why is my sensor showing as disconnected?',
      'answer': 'Check your internet connection and ensure the sensor is properly powered. Try restarting the sensor and refreshing the app.',
    },
    {
      'question': 'How often should I check my farm data?',
      'answer': 'We recommend checking your farm data at least once daily. The app will send notifications for urgent issues.',
    },
    {
      'question': 'Can I use the app offline?',
      'answer': 'Yes, the app can work offline for viewing cached data. However, real-time updates require an internet connection.',
    },
    {
      'question': 'How do I change my farm settings?',
      'answer': 'Go to Settings > Farm Management to update your farm information, field details, and sensor configurations.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: widget.onToggle,
            child: Container(
              padding: EdgeInsets.all(kAppMediumPadding),
              child: Row(
                children: [
                  Icon(
                    Icons.quiz,
                    color: MAIZE_ACCENT,
                    size: 24.sp,
                  ),
                  SizedBox(width: kAppSmallGap),
                  Text(
                    'Frequently Asked Questions',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: MAIZE_ACCENT,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    widget.isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: MAIZE_ACCENT,
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ),
          if (widget.isExpanded) ...[
            Divider(height: 1, color: Colors.grey[200]),
            Padding(
              padding: EdgeInsets.all(kAppMediumPadding),
              child: Column(
                children: faqs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final faq = entry.value;
                  return _buildFAQItem(faq['question']!, faq['answer']!, index);
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: kAppSmallPadding),
      padding: EdgeInsets.all(kAppSmallPadding),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24.w,
                height: 24.h,
                decoration: BoxDecoration(
                  color: MAIZE_ACCENT,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: kAppSmallGap),
              Expanded(
                child: Text(
                  question,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: kAppSmallPadding),
          Padding(
            padding: EdgeInsets.only(left: 32.w),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
