part of 'authentication_bloc.dart';

sealed class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

final class LoginEvent extends AuthenticationEvent {
  const LoginEvent({required this.username, required this.password});

  final String username;
  final String password;

  @override
  List<Object> get props => [username, password];
}

final class RegisterEvent extends AuthenticationEvent {
  const RegisterEvent({
    required this.fullName,
    required this.contactNumber,
    required this.address,
    required this.username,
    required this.password,
    required this.role, // Use the passed role instead of hardcoded 'user'
  });

  final String fullName;
  final String contactNumber;
  final Map<String, dynamic> address;
  final String username;
  final String password;
  final String role; // Use the passed role instead of hardcoded 'user'

  @override
  List<Object> get props => [
    fullName,
    contactNumber,
    address,
    username,
    password,
    role,
  ];
}

final class LogoutEvent extends AuthenticationEvent {}

final class CheckAuthStatusEvent extends AuthenticationEvent {}
