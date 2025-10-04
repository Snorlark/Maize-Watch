import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/cache_service.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/services/completion_status_manager.dart';
import '../../../../core/services/notification_service.dart';
// import '../../../../core/services/background_task_service.dart';
import '../../domain/entities/user.dart';
import '../../data/model/user_model.dart';
import '../../domain/usecases/login_user.dart';
import '../../domain/usecases/register_user.dart';
import '../../domain/usecases/update_profile.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final LoginUser loginUseCase;
  final RegisterUser registerUseCase;
  final UpdateProfile updateProfileUseCase;
  final SessionService _sessionService = SessionService();

  AuthenticationBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.updateProfileUseCase,
  }) : super(const AuthenticationState()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<InitializeSessionEvent>(_onInitializeSession);
    on<UpdateProfileEvent>(_onUpdateProfile);
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
          // Set current user ID for cache isolation
          await CacheService.setCurrentUserId(user.id);
          
          // Switch completion status manager to new user
          await CompletionStatusManager.switchUser(user.id);
          
          // Get tokens from secure storage (they were stored by the data source)
          print("🔐 AuthBloc: Retrieving tokens from storage...");
          final accessToken = await SecureStorage.getToken();
          final refreshToken = await SecureStorage.getRefreshToken();
          
          print("🔐 AuthBloc: Retrieved tokens - accessToken: ${accessToken != null ? "exists" : "null"}, refreshToken: ${refreshToken != null ? "exists" : "null"}");
          
          if (accessToken != null && refreshToken != null) {
            print("🔐 AuthBloc: Tokens found, starting session...");
            // Start session with tokens (this will also store user data)
            await _sessionService.startSession(accessToken, refreshToken, user);
            
            print("🔐 AuthBloc: Session started, emitting authenticated state");
            emit(
              state.copyWith(
                status: AuthenticationStatus.authenticated,
                user: user,
              ),
            );
            print("🔐 AuthBloc: Authenticated state emitted successfully");
            
            // Start background tasks for notifications
            print("🔄 AuthBloc: Starting background tasks for user ${user.username}");
            // await BackgroundTaskService.startAllTasks();
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

    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            status: AuthenticationStatus.failure,
            message: _mapFailureToString(failure),
          ),
        );
      },
      (user) async {
        // Handle success case asynchronously
        await _handleRegistrationSuccess(user, emit);
      },
    );
  }

  Future<void> _handleRegistrationSuccess(User user, Emitter<AuthenticationState> emit) async {
    // Store user data in secure storage for persistence
    try {
      await SecureStorage.storeUserData(jsonEncode({
        'id': user.id,
        'username': user.username,
        'fullName': user.fullName,
        'contactNumber': user.contactNumber,
        'address': user.address,
        'role': user.role,
      }));
      print("🔐 AuthBloc: User data stored in secure storage");
      
      // Set current user ID for cache isolation
      await CacheService.setCurrentUserId(user.id);
    } catch (e) {
      print("🚨 AuthBloc: Error storing user data: $e");
    }
    
    // Emit registration success and automatically authenticate the user
    print(
      "🔐 AuthBloc: Registration successful for user: ${user.username}",
    );
    
    // Check if we have tokens from registration
    final accessToken = await SecureStorage.getToken();
    final refreshToken = await SecureStorage.getRefreshToken();
    
    print("🔐 AuthBloc: Token check - AccessToken: ${accessToken != null ? 'Found' : 'Not found'}, RefreshToken: ${refreshToken != null ? 'Found' : 'Not found'}");
    
    if (accessToken != null && refreshToken != null) {
      // We have tokens, so we can authenticate the user immediately
      print("🔐 AuthBloc: Tokens found from registration, authenticating user");
      emit(
        state.copyWith(
          status: AuthenticationStatus.authenticated,
          user: user,
        ),
      );
    } else {
      // No tokens, emit registration success for UI to handle
      print("🔐 AuthBloc: No tokens found, emitting registration success");
      emit(
        state.copyWith(
          status: AuthenticationStatus.registrationSuccess,
          user: user,
        ),
      );
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    print("🔐 AuthBloc: Starting logout process");

    // Get current user ID before clearing session
    final currentUserId = await CacheService.getCurrentUserId();

    // Clear session using SessionService
    await _sessionService.logout();
    print("🔐 AuthBloc: Session cleared");
    
    // Clear user-specific cache
    if (currentUserId != null) {
      await CacheService.clearCache(userId: currentUserId);
      print("🔐 AuthBloc: User-specific cache cleared");
      
      // Clear completion status for this user
      await CompletionStatusManager.clearAll();
      print("🔐 AuthBloc: Completion status cleared");
      
      // Clear user notifications
      final notificationService = NotificationService();
      await notificationService.clearAllUserNotifications();
      print("🔐 AuthBloc: User notifications cleared");
      
      // Clear user session flag to force refresh on next login
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('last_user_id');
      print("🔐 AuthBloc: User session flag cleared");
    }

    // Stop background tasks
    print("🔄 AuthBloc: Stopping background tasks");
    // await BackgroundTaskService.stopAllTasks();

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
              final user = UserModel.fromJson(userJson);

              emit(
                state.copyWith(
                  status: AuthenticationStatus.authenticated,
                  user: user,
                ),
              );
              print("🔐 AuthBloc: User is authenticated, emitted authenticated state");
              
              // Start background tasks for existing authenticated user
              print("🔄 AuthBloc: Starting background tasks for existing user ${user.username}");
              // await BackgroundTaskService.startAllTasks();
              return;
            } catch (e) {
              print("🚨 AuthBloc: Error parsing user data: $e");
              print("🚨 AuthBloc: User data that failed to parse: $userData");
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
      print("🔐 AuthBloc: No valid session found, emitting unauthenticated state");
      // Don't clear session data here - let the user manually logout if needed
      emit(
        state.copyWith(
          status: AuthenticationStatus.unauthenticated,
          user: null,
        ),
      );
      print("🔐 AuthBloc: User is not authenticated, emitted unauthenticated state");
    } catch (e) {
      print("🚨 AuthBloc: Error checking auth status: $e");
      // Don't clear session data on error - just emit unauthenticated state
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

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<AuthenticationState> emit,
  ) async {
    print("🔐 AuthBloc: Starting profile update for user: ${event.userId}");
    print("🔐 AuthBloc: Update data - fullName: ${event.fullName}, contactNumber: ${event.contactNumber}");
    print("🔐 AuthBloc: Address data: ${event.address} (type: ${event.address.runtimeType})");
    
    emit(state.copyWith(status: AuthenticationStatus.loading));

    try {
      final result = await updateProfileUseCase(
        userId: event.userId,
        fullName: event.fullName,
        contactNumber: event.contactNumber,
        address: event.address,
      );

      print("🔐 AuthBloc: updateProfileUseCase completed");
      print("🔐 AuthBloc: Result type: ${result.runtimeType}");
      
      result.fold(
        (failure) {
          print("🚨 AuthBloc: Profile update failed: ${failure.toString()}");
          emit(
            state.copyWith(
              status: AuthenticationStatus.failure,
              message: _mapFailureToString(failure),
            ),
          );
        },
        (updatedUser) {
          print("🔐 AuthBloc: Success callback called");
          print("🔐 AuthBloc: UpdatedUser type: ${updatedUser.runtimeType}");
          print("🔐 AuthBloc: Profile updated successfully for user: ${updatedUser.username}");
          print("🔐 AuthBloc: Updated user address: ${updatedUser.address} (type: ${updatedUser.address.runtimeType})");
          
          try {
            print("🔐 AuthBloc: About to emit updated state...");
            emit(
              state.copyWith(
                status: AuthenticationStatus.authenticated,
                user: updatedUser,
                message: "profile_updated_successfully",
              ),
            );
            print("🔐 AuthBloc: State emitted successfully");
          } catch (e, stackTrace) {
            print("🚨 AuthBloc: Error emitting state: $e");
            print("🚨 AuthBloc: Stack trace: $stackTrace");
            rethrow;
          }
        },
      );
    } catch (e) {
      print("🚨 AuthBloc: Exception during profile update: $e");
      emit(
        state.copyWith(
          status: AuthenticationStatus.failure,
          message: "Profile update failed: $e",
        ),
      );
    }
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
