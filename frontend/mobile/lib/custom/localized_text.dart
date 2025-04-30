import 'package:flutter/material.dart';
import 'package:maize_watch/services/translation_service.dart';

class LocalizedText extends StatelessWidget {
  final String translationKey;
  final TextStyle? style;
  final TextAlign? textAlign;

  const LocalizedText(
    this.translationKey, {
    Key? key,
    this.style,
    this.textAlign,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translationService = TranslationService();

    return ValueListenableBuilder<Map<String, dynamic>>(
      valueListenable: translationService.translationNotifier,
      builder: (context, translations, _) {
        final translated = translationService.translate(translationKey);
        return Text(
          translated,
          style: style,
          textAlign: textAlign,
        );
      },
    );
  }
}
