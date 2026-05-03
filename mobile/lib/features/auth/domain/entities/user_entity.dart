import 'package:equatable/equatable.dart';

/// Immutable domain representation of an authenticated user.
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.accessToken,
    required this.expiresAt,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String accessToken;
  final DateTime expiresAt;

  bool get isTokenExpired => DateTime.now().isAfter(expiresAt);

  @override
  List<Object?> get props => [id, email, role];
}
