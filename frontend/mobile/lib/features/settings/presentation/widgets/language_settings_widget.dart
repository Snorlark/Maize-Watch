import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/theme/colors.dart';
import 'package:mobile/generated/l10n.dart';

class LanguageSettingsWidget extends StatelessWidget {
  final String currentLanguage;
  final ValueChanged<String> onLanguageChanged;

  const LanguageSettingsWidget({
    super.key,
    required this.currentLanguage,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(kAppMediumPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.language,
                color: MAIZE_ACCENT,
                size: 20.sp,
              ),
              SizedBox(width: kAppSmallGap),
              Text(
                'Select Language',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: MAIZE_ACCENT,
                ),
              ),
            ],
          ),
          SizedBox(height: kAppMediumPadding),
          
          // Language Options
          ...S.delegate.supportedLocales.map((locale) => _buildLanguageOption(context, locale)).toList(),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, Locale locale) {
    final isSelected = locale.languageCode == currentLanguage;
    final languageName = _getLanguageName(locale.languageCode);
    final flag = _getLanguageFlag(locale.languageCode);
    
    print('🔧 LanguageSettingsWidget: Building option for ${locale.languageCode}, isSelected: $isSelected, currentLanguage: $currentLanguage');
    
    return Container(
      margin: EdgeInsets.only(bottom: kAppSmallGap),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            print('🔧 LanguageSettingsWidget: Language selected: ${locale.languageCode}');
            onLanguageChanged(locale.languageCode);
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: kAppMediumPadding,
              vertical: kAppSmallPadding,
            ),
            decoration: BoxDecoration(
              color: isSelected ? MAIZE_ACCENT.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isSelected ? MAIZE_ACCENT : Colors.grey.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Text(
                  flag,
                  style: TextStyle(fontSize: 20.sp),
                ),
                SizedBox(width: kAppSmallGap),
                Expanded(
                  child: Text(
                    languageName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? MAIZE_ACCENT : Colors.black87,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: MAIZE_ACCENT,
                    size: 18.sp,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'tl':
        return 'Filipino';
      default:
        return languageCode.toUpperCase();
    }
  }

  String _getLanguageFlag(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇺🇸';
      case 'tl':
        return '🇵🇭';
      default:
        return '🌐';
    }
  }
}
