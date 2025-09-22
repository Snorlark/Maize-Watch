import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/services/session_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final LoginUser loginUseCase;
  final RegisterUser registerUseCase;
  final SessionService _sessionService = SessionService();

  AuthenticationBloc({
    required this.loginUseCase,
    required this.registerUseCase,
  }) : super(const AuthenticationState()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<InitializeSessionEvent>(_onInitializeSession);
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
          // Get tokens from secure storage (they were stored by the data source)
          print("🔐 AuthBloc: Retrieving tokens from storage...");
          final accessToken = await SecureStorage.getToken();
          final refreshToken = await SecureStorage.getRefreshToken();
          
          print("🔐 AuthBloc: Retrieved tokens - accessToken: ${accessToken != null ? "exists" : "null"}, refreshToken: ${refreshToken != null ? "exists" : "null"}");
          
          if (accessToken != null && refreshToken != null) {
            print("🔐 AuthBloc: Tokens found, starting session...");
            // Start session with tokens
            await _sessionService.startSession(accessToken, refreshToken, user);
            
            print("🔐 AuthBloc: Session started, emitting authenticated state");
            emit(
              state.copyWith(
                status: AuthenticationStatus.authenticated,
                user: user,
              ),
            );
            print("🔐 AuthBloc: Authenticated state emitted successfully");
          } else {
            print("🚨 AuthBloc: Tokens not found after successful login - this indicates a storage issue");
            throw Exception("Tokens not found after successful login - accessToken: ${accessToken != null}, refreshToken: ${refreshToken != null}");
          }
        } catch (e) {
          print("🚨 AuthBloc: Error starting session: $e");
          emit(
            state.copyWith(
              status: AuthenticationStatus.failure,
              message: "Failed to start session: $e",
            ),
          );
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
      (user) {
        // Just emit registration success - let the UI handle navigation
        print(
          "🔐 AuthBloc: Registration successful for user: ${user.username}",
        );
        emit(
          state.copyWith(
            status: AuthenticationStatus.registrationSuccess,
            user: user,
          ),
        );
      },
    );
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    print("🔐 AuthBloc: Starting logout process");

    // Clear session using SessionService
    await _sessionService.logout();
    print("🔐 AuthBloc: Session cleared");

    // Emit unauthenticated state to trigger navigation
    emit(
      state.copyWith(
        status: AuthenticationStatus.unauthenticated,
        user: null,
        message: null,
      ),
    );
    print("🔐 AuthBloc: Logout complete, emitted unauthenticated state");
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    print("🔐 AuthBloc: Checking authentication status");

    try {
      // Initialize session service
      await _sessionService.initialize();
      
      print("🔐 AuthBloc: Session service initialized. isSessionActive: ${_sessionService.isSessionActive}");
      
      // Check if we have tokens stored
      final hasToken = await SecureStorage.getToken();
      final hasRefreshToken = await SecureStorage.getRefreshToken();
      final isLoggedIn = await SecureStorage.isLoggedIn();
      
      print("🔐 AuthBloc: Token check - hasToken: ${hasToken != null}, hasRefreshToken: ${hasRefreshToken != null}, isLoggedIn: $isLoggedIn");
      
      if (hasToken != null && isLoggedIn) {
        // We have tokens, check if session is valid
        final isValid = await _sessionService.isSessionValid();
        print("🔐 AuthBloc: Session validity check result: $isValid");
        
        if (isValid) {
          // Get user data from secure storage
          final userData = await SecureStorage.getUserData();
          print("🔐 AuthBloc: User data from storage: ${userData != null ? "Found" : "Not found"}");
          
          if (userData != null) {
            try {
              final userJson = jsonDecode(userData);
              final user = User(
                id: userJson['id'],
                username: userJson['username'],
                fullName: userJson['fullName'],
                contactNumber: userJson['contactNumber'],
                address: userJson['address'],
                role: userJson['role'],
              );

              emit(
                state.copyWith(
                  status: AuthenticationStatus.authenticated,
                  user: user,
                ),
              );
              print("🔐 AuthBloc: User is authenticated, emitted authenticated state");
              return;
            } catch (e) {
              print("🚨 AuthBloc: Error parsing user data: $e");
            }
          } else {
            print("🔐 AuthBloc: No user data found in storage");
          }
        } else {
          print("🔐 AuthBloc: Session is not valid, attempting token refresh");
          // Try to refresh the token
          final refreshSuccess = await _sessionService.refreshAccessToken();
          if (refreshSuccess) {
            print("🔐 AuthBloc: Token refreshed successfully, retrying authentication");
            // Retry the authentication check
            return await _onCheckAuthStatus(event, emit);
          } else {
            print("🔐 AuthBloc: Token refresh failed");
          }
        }
      } else {
        print("🔐 AuthBloc: No tokens found or not logged in");
      }

      // Session invalid or no user data
      print("🔐 AuthBloc: Clearing session and emitting unauthenticated state");
      await _sessionService.clearSession();
      emit(
        state.copyWith(
          status: AuthenticationStatus.unauthenticated,
          user: null,
        ),
      );
      print("🔐 AuthBloc: User is not authenticated, emitted unauthenticated state");
    } catch (e) {
      print("🚨 AuthBloc: Error checking auth status: $e");
      // Clear data on error and emit unauthenticated state
      await _sessionService.clearSession();
      emit(
        state.copyWith(
          status: AuthenticationStatus.unauthenticated,
          user: null,
        ),
      );
    }
  }

  Future<void> _onInitializeSession(
    InitializeSessionEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    print("🔐 AuthBloc: Initializing session");
    await _sessionService.initialize();
  }

  String _mapFailureToString(Failure failure) {
    if (failure is ServerFailure) {
      // Surface specific server message (e.g., invalid credentials)
      return failure.message.isNotEmpty
          ? failure.message
          : 'Server error. Please try again later.';
    } else if (failure is NetworkFailure) {
      return failure.message.isNotEmpty
          ? failure.message
          : 'Network connection failed.';
    } else if (failure is CacheFailure) {
      return failure.message.isNotEmpty
          ? failure.message
          : 'Authentication failed due to a caching issue.';
    }
    return 'An unexpected error occurred.';
  }
}
