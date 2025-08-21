import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/constants/app_spacing.dart';

import '../../features/settings/presentation/bloc/settings_bloc.dart';
import 'package:mobile/generated/l10n.dart';
import '../theme/colors.dart';

class LanguageToggle extends StatelessWidget {
  final Color color_toggle;

  const LanguageToggle({super.key, required this.color_toggle});

  @override
  Widget build(BuildContext context) {
    final dropdownBackgroundColor =
        color_toggle == MAIZE_PRIMARY_LIGHT ? MAIZE_PRIMARY : Colors.white;

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
                  child: Text(
                    locale.languageCode.toUpperCase(),
                    style: TextStyle(color: color_toggle),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }
}
