import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/secure_storage.dart';
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
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    print("🔐 AuthBloc: Starting login process for ${event.username}");
    emit(state.copyWith(status: AuthenticationStatus.loading));

    final result = await loginUseCase(
      username: event.username,
      password: event.password,
    );

    print("🔐 AuthBloc: Login use case completed, processing result...");

    await result.fold(
      (failure) async {
        print("🚨 AuthBloc: Login failed with failure: ${failure.toString()}");
        emit(
          state.copyWith(
            status: AuthenticationStatus.failure,
            message: _mapFailureToString(failure),
          ),
        );
      },
      (user) async {
        print("🔐 AuthBloc: Login successful for ${user.username}");
        try {
          // Store user session data
          await SecureStorage.storeUserData(jsonEncode({
            'id': user.id,
            'username': user.username,
            'fullName': user.fullName,
            'contactNumber': user.contactNumber,
            'address': user.address,
            'role': user.role,
          }));
          
          print("🔐 AuthBloc: Session data stored, emitting authenticated state");
          emit(state.copyWith(status: AuthenticationStatus.authenticated, user: user));
          print("🔐 AuthBloc: Authenticated state emitted successfully");
        } catch (e) {
          print("🚨 AuthBloc: Error storing session data: $e");
          emit(state.copyWith(
            status: AuthenticationStatus.failure,
            message: "Failed to store session data: $e",
          ));
        }
      },
    );
  }

  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    emit(state.copyWith(status: AuthenticationStatus.loading));

    final result = await registerUseCase(
      username: event.username,
      password: event.password,
      fullName: event.fullName,
      contactNumber: event.contactNumber,
      address: event.address,
      role: event.role,
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

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    print("🔐 AuthBloc: Starting logout process");
    
    // Clear stored session data
    await SecureStorage.clearUserSession();
    print("🔐 AuthBloc: Session data cleared");
    
    // Emit unauthenticated state to trigger navigation
    emit(state.copyWith(
      status: AuthenticationStatus.unauthenticated,
      user: null,
      message: null,
    ));
    print("🔐 AuthBloc: Logout complete, emitted unauthenticated state");
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    print("🔐 AuthBloc: Checking authentication status");
    
    try {
      final isLoggedIn = await SecureStorage.isLoggedIn();
      final hasToken = await SecureStorage.getToken();
      final userData = await SecureStorage.getUserData();
      
      print("🔐 AuthBloc: isLoggedIn=$isLoggedIn, hasToken=${hasToken != null}, userData=${userData != null}");
      
      if (isLoggedIn && hasToken != null && userData != null) {
        // Parse user data and emit authenticated state
        final userJson = jsonDecode(userData);
        final user = User(
          id: userJson['id'],
          username: userJson['username'],
          fullName: userJson['fullName'],
          contactNumber: userJson['contactNumber'],
          address: userJson['address'],
          role: userJson['role'],
        );
        
        emit(state.copyWith(
          status: AuthenticationStatus.authenticated,
          user: user,
        ));
        print("🔐 AuthBloc: User is authenticated, emitted authenticated state");
      } else {
        // Clear any stale data and emit unauthenticated state
        await SecureStorage.clearUserSession();
        emit(state.copyWith(
          status: AuthenticationStatus.unauthenticated,
          user: null,
        ));
        print("🔐 AuthBloc: User is not authenticated, emitted unauthenticated state");
      }
    } catch (e) {
      print("🚨 AuthBloc: Error checking auth status: $e");
      // Clear data on error and emit unauthenticated state
      await SecureStorage.clearUserSession();
      emit(state.copyWith(
        status: AuthenticationStatus.unauthenticated,
        user: null,
      ));
    }
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
