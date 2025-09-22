import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/theme/colors.dart';

class LanguageSettingsWidget extends StatefulWidget {
  final String currentLanguage;
  final ValueChanged<String> onLanguageChanged;

  const LanguageSettingsWidget({
    super.key,
    required this.currentLanguage,
    required this.onLanguageChanged,
  });

  @override
  State<LanguageSettingsWidget> createState() => _LanguageSettingsWidgetState();
}

class _LanguageSettingsWidgetState extends State<LanguageSettingsWidget> {
  final List<Map<String, String>> languages = [
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(kAppMediumPadding),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.language,
                color: MAIZE_ACCENT,
                size: 24.sp,
              ),
              SizedBox(width: kAppSmallGap),
              Text(
                'Language',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: MAIZE_ACCENT,
                ),
              ),
            ],
          ),
          SizedBox(height: kAppMediumPadding),
          ...languages.map((language) => _buildLanguageTile(language)).toList(),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(Map<String, String> language) {
    final isSelected = language['code'] == widget.currentLanguage;
    
    return GestureDetector(
      onTap: () {
        widget.onLanguageChanged(language['code']!);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: kAppSmallPadding),
        child: Row(
          children: [
            Text(
              language['flag']!,
              style: TextStyle(fontSize: 24.sp),
            ),
            SizedBox(width: kAppSmallGap),
            Expanded(
              child: Text(
                language['name']!,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: MAIZE_ACCENT,
                size: 20.sp,
              )
            else
              Icon(
                Icons.radio_button_unchecked,
                color: Colors.grey,
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }
}
