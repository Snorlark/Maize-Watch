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
    return AuthenticationState(
      status: status ?? this.status,
      user: user ?? this.user,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, user, message];
}
