import 'package:flutter/material.dart';
import 'package:maize_watch/services/translation_service.dart';

class LanguageToggle extends StatefulWidget {
  const LanguageToggle({Key? key}) : super(key: key);

  @override
  _LanguageToggleState createState() => _LanguageToggleState();
}

class _LanguageToggleState extends State<LanguageToggle> {
  final TranslationService _translationService = TranslationService();
  bool _isEnglish = true;

  @override
  void initState() {
    super.initState();
    // Set initial value to English
    _isEnglish = true;

    // Listen for language changes
    _translationService.translationNotifier.addListener(() {
      if (mounted) {
        setState(() {
          _isEnglish = _translationService.isEnglish;
        });
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              _translationService.translate('language'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Switch(
                    value: _isEnglish,
                    onChanged: (value) {
                      // Toggle between English and Tagalog
                      _translationService.changeLanguage(value ? 'en' : 'tl');
                    },
                    activeColor: Colors.white,
                    activeTrackColor: const Color(0xFF418036),
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: const Color(0xFFC9C9C9),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "${_isEnglish ? 'English' : 'Tagalog'} (${_translationService.translate('language')})",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}