import 'package:flutter/material.dart';

import 'package:mobile/generated/l10n.dart';

String GetLocalizedGreeting(BuildContext context) {
  final hour = DateTime.now().hour;
  if (hour < 12) {
    return S.of(context).greeting_morning;
  } else if (hour < 17) {
    return S.of(context).greeting_afternoon;
  } else {
    return S.of(context).greeting_evening;
  }
}
