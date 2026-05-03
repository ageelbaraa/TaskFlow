import 'package:equatable/equatable.dart';

/// Base class for all auth events.
sealed class AuthEvent extends Equatable {
  const AuthEvent();
}

/// Check secure storage for an existing valid session on app launch.
final class AuthCheckStatusEvent extends AuthEvent {
  const AuthCheckStatusEvent();
  @override
  List<Object?> get props => [];
}

/// Trigger a login attempt with the given credentials.
final class AuthLoginEvent extends AuthEvent {
  const AuthLoginEvent({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// Trigger a registration with name, email, and password.
final class AuthRegisterEvent extends AuthEvent {
  const AuthRegisterEvent({
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;

  @override
  List<Object?> get props => [name, email, password];
}

/// Clear stored credentials and transition to unauthenticated state.
final class AuthLogoutEvent extends AuthEvent {
  const AuthLogoutEvent();
  @override
  List<Object?> get props => [];
}
