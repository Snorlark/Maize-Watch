import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/live_monitoring/presentation/bloc/monitoring_bloc.dart';

// Core
import 'core/di/injection_container.dart' as di;

// Features
import 'features/farm/presentation/bloc/farm_bloc.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/authentication/presentation/bloc/authentication_bloc.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await di.init();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SettingsBloc()),
        BlocProvider(create: (_) => di.sl<AuthenticationBloc>()),
        BlocProvider(create: (_) => di.sl<FarmBloc>()),
        BlocProvider<MonitoringBloc>(create: (_) => di.sl<MonitoringBloc>()),
      ],
      child: const MaizeWatchApp(),
    ),
  );
}
