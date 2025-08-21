import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:mobile/features/authentication/domain/usecases/register_user.dart';

// Features
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/authentication/presentation/bloc/authentication_bloc.dart';
import 'features/authentication/domain/usecases/login_user.dart';
import 'features/authentication/data/datasources/authentication_remote_data_source.dart';
import 'features/authentication/data/repositories/authentication_repository_impl.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Dependencies
  final dioClient = Dio();
  final remoteDataSource = AuthenticationRemoteDataSourceImpl(
    client: dioClient,
  );
  final authRepository = AuthenticationRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
  final loginUseCase = LoginUser(repository: authRepository);
  final registerUseCase = RegisterUser(repository: authRepository);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SettingsBloc()),
        BlocProvider(
          create:
              (_) => AuthenticationBloc(
                loginUseCase: loginUseCase,
                registerUseCase: registerUseCase,
              ),
        ),
      ],
      child: const MaizeWatchApp(),
    ),
  );
}
