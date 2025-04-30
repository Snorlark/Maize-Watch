import 'package:flutter/material.dart';
import 'package:maize_watch/services/translation_service.dart';

class FAQSectionWidget extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final TranslationService translationService;

  const FAQSectionWidget({
    Key? key,
    required this.isExpanded,
    required this.onToggle,
    required this.translationService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            ListTile(
              title: Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Text(
                  translationService.translate("faq_title"),
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              trailing: Icon(
                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 18,
                color: Colors.black54,
              ),
              onTap: onToggle,
            ),
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "1. ${translationService.translate("faq_q1")}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      translationService.translate("faq_a1"),
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "2. ${translationService.translate("faq_q2")}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      translationService.translate("faq_a2"),
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
