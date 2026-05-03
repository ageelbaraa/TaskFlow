import '../entities/user_entity.dart';

/// Contract for auth operations. Implementations live in the data layer.
abstract class AuthRepository {
  /// Authenticates with [email] and [password]. Returns the authenticated user
  /// or throws an exception describing the failure.
  Future<UserEntity> login({required String email, required String password});

  /// Creates a new account. Returns the newly created user with a token,
  /// or throws an exception describing the failure.
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
  });

  /// Removes persisted credentials and marks the session as logged out.
  Future<void> logout();

  /// Attempts to restore a session from secure storage. Returns null if no
  /// valid session exists.
  Future<UserEntity?> getStoredSession();
}
