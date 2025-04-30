import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TranslationService {
  // Singleton pattern
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  // Translation data
  Map<String, dynamic> _translations = {};
  String _currentLanguage = 'en'; // Default to English

  // Notifier for both language and content updates
  final ValueNotifier<Map<String, dynamic>> translationNotifier =
      ValueNotifier<Map<String, dynamic>>({
    'currentLanguage': 'en',
    'translations': {},
  });
  
  // Force UI update
  void notifyListeners() {
    translationNotifier.value = {
      'currentLanguage': _currentLanguage,
      'translations': Map.from(_translations),
      'timestamp': DateTime.now().millisecondsSinceEpoch, // Add timestamp to force UI updates
    };
  }

  // Initialize the service
  Future<void> init() async {
    await _loadSavedLanguage();
    translationNotifier.value = {
      'currentLanguage': _currentLanguage,
      'translations': _translations,
      'timestamp': DateTime.now().millisecondsSinceEpoch, // Add timestamp to force UI updates
    };
  }

  // Load saved language preference from SharedPreferences
  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('language');
    
    if (savedLanguage != null) {
      _currentLanguage = savedLanguage;
      await loadTranslations(savedLanguage);
    } else {
      await loadTranslations('en');
    }
  }

  // Load translations from JSON file
  Future<void> loadTranslations(String languageCode) async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/lang/$languageCode.json');
      _translations = json.decode(jsonString);
      _currentLanguage = languageCode;
    } catch (e) {
      print('Error loading translations: $e');
      if (languageCode != 'en') {
        await loadTranslations('en');
      } else {
        _translations = {};
      }
    }
  }

  // Change language and notify listeners
  Future<void> changeLanguage(String languageCode) async {
    if (_currentLanguage == languageCode) return;

    await loadTranslations(languageCode);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);

    // Update the notifier with both language and translations
    translationNotifier.value = {
      'currentLanguage': languageCode,
      'translations': Map.from(_translations),
      'timestamp': DateTime.now().millisecondsSinceEpoch, // Add timestamp to force UI updates
    };
    
    print('Language changed to: $languageCode');
    
    // Ensure the UI gets rebuilt immediately
    notifyListeners();
  }

  // Reset to English
  Future<void> resetToEnglish() async {
    await changeLanguage('en');
  }

  // Get translated text
  String translate(String key) {
    if (_translations.containsKey(key)) {
      return _translations[key];
    } else {
      print('Missing translation for key: $key in language: $_currentLanguage');
      return key;
    }
  }
  
  // Get all translations
  Map<String, dynamic> get translations => _translations;

  // Current language code
  String get currentLanguage => _currentLanguage;

  // Check if English
  bool get isEnglish => _currentLanguage == 'en';

   Future<void> persistLanguagePreference(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
    print('Language preference saved: $languageCode');
  }

  // Get language from SharedPreferences
  Future<String> getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('language') ?? 'en';
  }

  // Clear all app preferences (for logout)
  Future<void> clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    // Keep language preference but clear everything else
    final String currentLang = prefs.getString('language') ?? 'en';
    await prefs.clear();
    await prefs.setString('language', currentLang);
  }
}