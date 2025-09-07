import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/settings_bloc.dart';
import '../../../authentication/presentation/bloc/authentication_bloc.dart';
import 'package:mobile/generated/l10n.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state.status == AuthenticationStatus.unauthenticated) {
          // Navigate to landing screen when logged out
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/landing', (route) => false);
        }
      },
      child: Scaffold(
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
                      context.read<SettingsBloc>().add(
                        ChangeLanguage(newLocale),
                      );
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

              const Divider(),

              // Logout button
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  // Show confirmation dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Logout'),
                        content: const Text('Are you sure you want to logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              // Trigger logout event
                              context.read<AuthenticationBloc>().add(
                                LogoutEvent(),
                              );
                            },
                            child: const Text(
                              'Logout',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
