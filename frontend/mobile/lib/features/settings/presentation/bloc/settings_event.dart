part of 'settings_bloc.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

final class ChangeLanguage extends SettingsEvent {
  const ChangeLanguage(this.locale);
  final Locale locale;

  @override
  List<Object> get props => [locale];
}
