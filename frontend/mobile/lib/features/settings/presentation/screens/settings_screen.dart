import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/settings_bloc.dart';
import 'package:mobile/generated/l10n.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).settings)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Language selection
            ListTile(
              title: Text(S.of(context).language),
              trailing: DropdownButton<Locale>(
                value: context.watch<SettingsBloc>().state.locale,
                onChanged: (Locale? newLocale) {
                  if (newLocale != null) {
                    context.read<SettingsBloc>().add(ChangeLanguage(newLocale));
                  }
                },
                items:
                    S.delegate.supportedLocales.map((locale) {
                      return DropdownMenuItem<Locale>(
                        value: locale,
                        child: Text(locale.languageCode.toUpperCase()),
                      );
                    }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
