import 'package:flutter/material.dart';

class LanguageNotifier extends ValueNotifier<Locale> {
  LanguageNotifier() : super(const Locale('en', 'US'));

  void changeLanguage(Locale newLocale) {
    if (value != newLocale) {
      print("🌐 LanguageNotifier: Changing language from ${value.languageCode} to ${newLocale.languageCode}");
      value = newLocale;
      print("🌐 LanguageNotifier: Language changed to ${value.languageCode}");
    }
  }
}

// Global instance
final LanguageNotifier languageNotifier = LanguageNotifier();
