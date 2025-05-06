import 'package:flutter/material.dart';
import 'package:maize_watch/custom/constants.dart';
import 'package:maize_watch/custom/custom_font.dart';
import 'package:maize_watch/main.dart';

class LanguageToggleLocale extends StatelessWidget {
  
  final Color color_toggle;

  const LanguageToggleLocale({
    super.key,
    required this.color_toggle
  });

  @override
  Widget build(BuildContext context) {

    final dropdownBackgroundColor = color_toggle == MAIZE_PRIMARY_LIGHT ? MAIZE_PRIMARY : MAIZE_PRIMARY_LIGHT;

    return Theme(
      data: Theme.of(context).copyWith(      
        canvasColor: dropdownBackgroundColor
      ),
      child: DropdownButton<Locale>(
        borderRadius: BorderRadius.circular(10),
        value: localeNotifier.value,
        elevation: 0,
        underline: SizedBox.shrink(), 
        dropdownColor: dropdownBackgroundColor, // Optional: Some themes also support this
        icon: Icon(Icons.arrow_drop_down, color: color_toggle),
        onChanged: (Locale? newLocale) {
          if (newLocale != null) {
            localeNotifier.value = newLocale;
          }
        },
        items: [
          DropdownMenuItem(
            value: const Locale('en'),
            child: CustomFont(
              text: 'English',
              color: color_toggle,
            ),
          ),
          DropdownMenuItem(
            value: Locale('tl'),
            child: CustomFont(
              text: 'Tagalog',
              color: color_toggle,
            ),
          ),
        ],
      ),
    );
  }
}
