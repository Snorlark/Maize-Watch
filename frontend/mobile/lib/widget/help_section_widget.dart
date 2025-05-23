import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HelpSectionWidget extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;

  const HelpSectionWidget({
    Key? key,
    required this.isExpanded,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

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
                  loc.helpTitle,
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
                child: Text(
                  loc.helpDescription,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Montserrat',
                    color: Colors.black87,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
