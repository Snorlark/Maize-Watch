part of 'authentication_bloc.dart';

enum AuthenticationStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  registrationSuccess,
  failure,
}

final class AuthenticationState extends Equatable {
  const AuthenticationState({
    this.status = AuthenticationStatus.initial,
    this.user,
    this.message,
  });

  final AuthenticationStatus status;
  final User? user;
  final String? message;

  AuthenticationState copyWith({
    AuthenticationStatus? status,
    User? user,
    String? message,
  }) {
    print("🔍 AuthenticationState.copyWith called");
    print("🔍 New user: ${user?.username} (type: ${user.runtimeType})");
    if (user != null) {
      print("🔍 User address: ${user.address} (type: ${user.address.runtimeType})");
    }
    
    try {
      final newState = AuthenticationState(
        status: status ?? this.status,
        user: user ?? this.user,
        message: message ?? this.message,
      );
      print("🔍 New AuthenticationState created successfully");
      return newState;
    } catch (e, stackTrace) {
      print("🚨 Error creating AuthenticationState: $e");
      print("🚨 Stack trace: $stackTrace");
      rethrow;
    }
  }

  @override
  List<Object?> get props => [status, user, message];
}
