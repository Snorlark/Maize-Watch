// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../features/settings/presentation/bloc/settings_event.dart';
import '../../features/settings/presentation/bloc/settings_state.dart';
import 'package:mobile/generated/l10n.dart';
import '../theme/colors.dart';

class LanguageToggle extends StatelessWidget {
  final Color color_toggle;

  const LanguageToggle({super.key, required this.color_toggle});

  @override
  Widget build(BuildContext context) {
    final dropdownBackgroundColor =
        color_toggle == MAIZE_PRIMARY_LIGHT ? MAIZE_PRIMARY : Colors.white;

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        print('🔧 LanguageToggle: Settings state: ${state.runtimeType}');
        
        return Theme(
          data: Theme.of(context).copyWith(canvasColor: dropdownBackgroundColor),
          child: Padding(
            padding: EdgeInsets.all(kAppMediumPadding),
            child: DropdownButton<Locale>(
              borderRadius: BorderRadius.circular(10),
              elevation: 0,
              underline: SizedBox.shrink(),
              dropdownColor: dropdownBackgroundColor,
              icon: Icon(Icons.arrow_drop_down, color: color_toggle),
              value: _getCurrentLocale(state),
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  print('🔧 LanguageToggle: Language changed to: ${newLocale.languageCode}');
                  
                  // Store in SharedPreferences for immediate access
                  _updateLanguagePreference(newLocale.languageCode);
                  
                  // Update settings system
                  context.read<SettingsBloc>().add(UpdateLanguage(newLocale.languageCode));
                }
              },
              items: S.delegate.supportedLocales.map((locale) {
                print('🔧 LanguageToggle: Creating dropdown item for locale: ${locale.languageCode}');
                return DropdownMenuItem<Locale>(
                  value: locale,
                  child: Text(
                    locale.languageCode.toUpperCase(),
                    style: TextStyle(color: color_toggle),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Locale _getCurrentLocale(SettingsState state) {
    print('🔧 LanguageToggle: Getting current locale for state: ${state.runtimeType}');
    print('🔧 LanguageToggle: Available locales: ${S.delegate.supportedLocales}');
    
    String currentLanguage = 'en'; // Default language
    
    if (state is SettingsLoaded) {
      currentLanguage = state.settings.language;
      print('🔧 LanguageToggle: Current language from settings: $currentLanguage');
    } else if (state is SettingsUpdated) {
      currentLanguage = state.settings.language;
      print('🔧 LanguageToggle: Current language from updated settings: $currentLanguage');
    } else {
      print('🔧 LanguageToggle: Using default language: $currentLanguage');
    }
    
    // Find matching locale from supported locales
    final matchingLocale = S.delegate.supportedLocales.firstWhere(
      (locale) => locale.languageCode == currentLanguage,
      orElse: () => S.delegate.supportedLocales.first,
    );
    
    print('🔧 LanguageToggle: Matching locale: ${matchingLocale.languageCode}');
    return matchingLocale;
  }

  void _updateLanguagePreference(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_language_code', languageCode);
    } catch (e) {
      print('🔧 LanguageToggle: Failed to update language preference: $e');
    }
  }
}
