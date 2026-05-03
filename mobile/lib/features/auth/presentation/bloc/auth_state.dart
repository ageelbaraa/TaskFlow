import 'package:equatable/equatable.dart';

import '../../domain/entities/user_entity.dart';

/// Base class for all auth states.
sealed class AuthState extends Equatable {
  const AuthState();
}

/// Initial state — session check not yet performed.
final class AuthInitial extends AuthState {
  const AuthInitial();
  @override
  List<Object?> get props => [];
}

/// A long-running auth operation is in progress.
final class AuthLoading extends AuthState {
  const AuthLoading();
  @override
  List<Object?> get props => [];
}

/// User is authenticated and holds a valid token.
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final UserEntity user;

  @override
  List<Object?> get props => [user];
}

/// No valid session exists; user must log in.
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
  @override
  List<Object?> get props => [];
}

/// An auth operation failed with a human-readable message.
final class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
