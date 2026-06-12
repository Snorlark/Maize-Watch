import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/theme/colors.dart';
import 'package:mobile/generated/l10n.dart';

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
      'question': 'faq_add_sensor_question',
      'answer': 'faq_add_sensor_answer',
    },
    {
      'question': 'faq_sensor_disconnected_question',
      'answer': 'faq_sensor_disconnected_answer',
    },
    {
      'question': 'faq_check_farm_data_question',
      'answer': 'faq_check_farm_data_answer',
    },
    {
      'question': 'faq_offline_usage_question',
      'answer': 'faq_offline_usage_answer',
    },
    {
      'question': 'faq_change_farm_settings_question',
      'answer': 'faq_change_farm_settings_answer',
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
                    S.of(context).frequently_asked_questions,
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
                  return _buildFAQItem(context, faq['question']!, faq['answer']!, index);
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String questionKey, String answerKey, int index) {
    final l10n = S.of(context);
    final question = _getTranslatedText(l10n, questionKey);
    final answer = _getTranslatedText(l10n, answerKey);
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

  String _getTranslatedText(S l10n, String key) {
    switch (key) {
      case 'faq_add_sensor_question':
        return l10n.faq_add_sensor_question;
      case 'faq_add_sensor_answer':
        return l10n.faq_add_sensor_answer;
      case 'faq_sensor_disconnected_question':
        return l10n.faq_sensor_disconnected_question;
      case 'faq_sensor_disconnected_answer':
        return l10n.faq_sensor_disconnected_answer;
      case 'faq_check_farm_data_question':
        return l10n.faq_check_farm_data_question;
      case 'faq_check_farm_data_answer':
        return l10n.faq_check_farm_data_answer;
      case 'faq_offline_usage_question':
        return l10n.faq_offline_usage_question;
      case 'faq_offline_usage_answer':
        return l10n.faq_offline_usage_answer;
      case 'faq_change_farm_settings_question':
        return l10n.faq_change_farm_settings_question;
      case 'faq_change_farm_settings_answer':
        return l10n.faq_change_farm_settings_answer;
      default:
        return key;
    }
  }
}
