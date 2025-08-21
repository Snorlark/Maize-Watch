import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final LoginUser loginUseCase;
  final RegisterUser registerUseCase;

  AuthenticationBloc({
    required this.loginUseCase,
    required this.registerUseCase,
  }) : super(const AuthenticationState()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(state.copyWith(status: AuthenticationStatus.loading));

    final result = await loginUseCase(event.username, event.password);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthenticationStatus.failure,
          message: _mapFailureToString(failure),
        ),
      ),
      (user) => emit(
        state.copyWith(status: AuthenticationStatus.authenticated, user: user),
      ),
    );
  }

  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(state.copyWith(status: AuthenticationStatus.loading));

    final result = await registerUseCase(
      event.username,
      event.password,
      event.fullName,
      event.contactNumber,
      event.address,
      event.role, // Use the passed role instead of hardcoded 'user'
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthenticationStatus.failure,
          message: _mapFailureToString(failure),
        ),
      ),
      (user) => emit(
        state.copyWith(
          status: AuthenticationStatus.registrationSuccess,
          user: user,
        ),
      ),
    );
  }

  String _mapFailureToString(Failure failure) {
    if (failure is ServerFailure) {
      return 'Server error. Please try again later.';
    } else if (failure is CacheFailure) {
      return 'Authentication failed due to a caching issue.';
    }
    return 'An unexpected error occurred.';
  }
}
