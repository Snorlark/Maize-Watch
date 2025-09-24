import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/live_monitoring/presentation/bloc/monitoring_bloc.dart';
import 'package:mobile/features/live_monitoring/presentation/bloc/analytics_bloc.dart';
import 'package:mobile/features/prescriptions/presentation/bloc/prescription_bloc.dart';

// Core
import 'core/di/injection_container.dart' as di;
import 'core/widgets/connectivity_indicator.dart';

// Features
import 'features/farm/presentation/bloc/farm_bloc.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/bloc/sensor_status_bloc.dart';
import 'features/authentication/presentation/bloc/authentication_bloc.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await di.init();

  runApp(
    ConnectivityIndicator(
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => di.sl<SettingsBloc>()),
          BlocProvider(create: (_) => di.sl<SensorStatusBloc>()),
          BlocProvider(create: (_) => di.sl<AuthenticationBloc>()),
          BlocProvider(create: (_) => di.sl<FarmBloc>()),
          BlocProvider<MonitoringBloc>(create: (_) => di.sl<MonitoringBloc>()),
          BlocProvider<AnalyticsBloc>(create: (_) => di.sl<AnalyticsBloc>()),
          BlocProvider<PrescriptionBloc>(create: (_) => di.sl<PrescriptionBloc>()),
        ],
        child: const MaizeWatchApp(),
      ),
    ),
  );
}
