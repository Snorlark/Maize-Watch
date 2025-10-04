// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/services/language_notifier.dart';

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
        // OPTIMIZED: Removed debug prints for better performance
        
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
                  print("🌐 LanguageToggle: User selected language: ${newLocale.languageCode}");
                  
                  // Update settings
                  context.read<SettingsBloc>().add(UpdateLanguage(newLocale.languageCode));
                  
                  // Notify language change
                  languageNotifier.changeLanguage(newLocale);
                }
              },
              items: S.delegate.supportedLocales.map((locale) {
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
    // OPTIMIZED: Removed debug prints for better performance
    
    String currentLanguage = 'en'; // Default language
    
    if (state is SettingsLoaded) {
      currentLanguage = state.settings.language;
    } else if (state is SettingsUpdated) {
      currentLanguage = state.settings.language;
    }
    
    // Find matching locale from supported locales
    final matchingLocale = S.delegate.supportedLocales.firstWhere(
      (locale) => locale.languageCode == currentLanguage,
      orElse: () => S.delegate.supportedLocales.first,
    );
    
    return matchingLocale;
  }
}
