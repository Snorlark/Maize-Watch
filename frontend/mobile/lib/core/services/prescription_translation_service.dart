import 'package:mobile/core/storage/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PrescriptionTranslationService {
  static final Map<String, Map<String, String>> _titleTranslations = {
    'Manage high temperature stress': {
      'en': 'Manage high temperature stress',
      'tl': 'Pamahalaan ang stress sa mataas na temperatura',
    },
    'Adjust irrigation schedule': {
      'en': 'Adjust irrigation schedule',
      'tl': 'Ayusin ang iskedyul ng irigasyon',
    },
    'Apply soil treatment': {
      'en': 'Apply soil treatment',
      'tl': 'Maglagay ng paggamot sa lupa',
    },
    'Monitor humidity levels': {
      'en': 'Monitor humidity levels',
      'tl': 'Subaybayan ang antas ng halumigmig',
    },
    'Adjust light exposure': {
      'en': 'Adjust light exposure',
      'tl': 'Ayusin ang pagkakalantad sa liwanag',
    },
    'Field Durant': {
      'en': 'Field Durant',
      'tl': 'Field Durant',
    },
    '02 PROTO': {
      'en': '02 PROTO',
      'tl': '02 PROTO',
    },
  };

  static final Map<String, Map<String, String>> _descriptionTranslations = {
    'Implement shading or increase watering frequency during peak heat hours.': {
      'en': 'Implement shading or increase watering frequency during peak heat hours.',
      'tl': 'Maglagay ng lilim o dagdagan ang dalas ng pagdidilig sa mga oras ng matinding init.',
    },
    'Increase watering frequency to prevent drought stress.': {
      'en': 'Increase watering frequency to prevent drought stress.',
      'tl': 'Dagdagan ang dalas ng pagdidilig upang maiwasan ang stress sa tagtuyot.',
    },
    'Apply organic fertilizer to improve soil quality.': {
      'en': 'Apply organic fertilizer to improve soil quality.',
      'tl': 'Maglagay ng organikong pataba upang mapabuti ang kalidad ng lupa.',
    },
    'Use humidifiers or misting systems to maintain optimal humidity.': {
      'en': 'Use humidifiers or misting systems to maintain optimal humidity.',
      'tl': 'Gumamit ng humidifier o misting system upang mapanatili ang optimal na halumigmig.',
    },
    'Adjust artificial lighting or natural light exposure.': {
      'en': 'Adjust artificial lighting or natural light exposure.',
      'tl': 'Ayusin ang artipisyal na ilaw o natural na pagkakalantad sa liwanag.',
    },
    // Field-specific translations
    'Field Durant: humidity at': {
      'en': 'Field Durant: humidity at',
      'tl': 'Field Durant: halumigmig sa',
    },
    '02 PROTO: humidity at': {
      'en': '02 PROTO: humidity at',
      'tl': '02 PROTO: halumigmig sa',
    },
    'Field Durant: temperature at': {
      'en': 'Field Durant: temperature at',
      'tl': 'Field Durant: temperatura sa',
    },
    '02 PROTO: temperature at': {
      'en': '02 PROTO: temperature at',
      'tl': '02 PROTO: temperatura sa',
    },
    'Field Durant: soil moisture at': {
      'en': 'Field Durant: soil moisture at',
      'tl': 'Field Durant: kahalumigmigan ng lupa sa',
    },
    '02 PROTO: soil moisture at': {
      'en': '02 PROTO: soil moisture at',
      'tl': '02 PROTO: kahalumigmigan ng lupa sa',
    },
    'Field Durant: light intensity at': {
      'en': 'Field Durant: light intensity at',
      'tl': 'Field Durant: intensity ng liwanag sa',
    },
    '02 PROTO: light intensity at': {
      'en': '02 PROTO: light intensity at',
      'tl': '02 PROTO: intensity ng liwanag sa',
    },
  };

  // Get current language from SecureStorage (same as settings system) with SharedPreferences fallback
  static Future<String> _getCurrentLanguage() async {
    try {
      // First try to get from SecureStorage (settings system)
      final settingsJson = await SecureStorage.read(key: 'settings');
      if (settingsJson != null) {
        final settingsData = Map<String, dynamic>.from(jsonDecode(settingsJson));
        final language = settingsData['language'] ?? 'en';
        // Also store in SharedPreferences for immediate access
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('selected_language_code', language);
        return language;
      }
      
      // Fallback to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('selected_language_code') ?? 'en';
    } catch (e) {
      // Final fallback
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('selected_language_code') ?? 'en';
    }
  }

  // Translate prescription title
  static Future<String> translatePrescriptionTitle(String originalTitle) async {
    final language = await _getCurrentLanguage();
    final lowerTitle = originalTitle.toLowerCase();

    // Try exact match first
    for (final entry in _titleTranslations.entries) {
      if (entry.key.toLowerCase() == lowerTitle) {
        return entry.value[language] ?? originalTitle;
      }
    }

    // Try partial matching for more flexibility
    for (final entry in _titleTranslations.entries) {
      if (lowerTitle.contains(entry.key.toLowerCase()) || 
          entry.key.toLowerCase().contains(lowerTitle)) {
        return entry.value[language] ?? originalTitle;
      }
    }

    return originalTitle; // Fallback to original if no translation found
  }

  // Translate prescription description
  static Future<String> translatePrescriptionDescription(String originalDescription) async {
    final language = await _getCurrentLanguage();
    final lowerDescription = originalDescription.toLowerCase();

    // Try exact match first
    for (final entry in _descriptionTranslations.entries) {
      if (entry.key.toLowerCase() == lowerDescription) {
        return entry.value[language] ?? originalDescription;
      }
    }

    // Try partial matching for more flexibility
    for (final entry in _descriptionTranslations.entries) {
      if (lowerDescription.contains(entry.key.toLowerCase()) || 
          entry.key.toLowerCase().contains(lowerDescription)) {
        return entry.value[language] ?? originalDescription;
      }
    }

    return originalDescription; // Fallback to original if no translation found
  }
}