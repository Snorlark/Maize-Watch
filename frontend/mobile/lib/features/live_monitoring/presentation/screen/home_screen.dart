import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/live_monitoring/presentation/widgets/secure_auth_example.dart';
import '../../../authentication/presentation/bloc/authentication_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state.status == AuthenticationStatus.unauthenticated) {
          // Navigate to landing screen when logged out
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/landing',
            (route) => false,
          );
        }
      },
      child: SecureAuthExample(),
    );
  }
}
