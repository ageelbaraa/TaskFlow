import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps [FlutterSecureStorage] with typed helpers for token management.
class SecureStorageService {
  static const _tokenKey = 'access_token';
  static const _userIdKey = 'user_id';
  static const _userNameKey = 'user_name';
  static const _userEmailKey = 'user_email';
  static const _userRoleKey = 'user_role';

  final FlutterSecureStorage _storage;

  SecureStorageService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
          iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
        );

  /// Persists the access token received after authentication.
  Future<void> saveToken(String token) => _storage.write(key: _tokenKey, value: token);

  /// Retrieves the stored access token, or null if not authenticated.
  Future<String?> getToken() => _storage.read(key: _tokenKey);

  /// Saves basic user profile data for offline display.
  Future<void> saveUserProfile({
    required String id,
    required String name,
    required String email,
    required String role,
  }) async {
    await Future.wait([
      _storage.write(key: _userIdKey, value: id),
      _storage.write(key: _userNameKey, value: name),
      _storage.write(key: _userEmailKey, value: email),
      _storage.write(key: _userRoleKey, value: role),
    ]);
  }

  /// Returns a map with stored user profile keys, or null if no session exists.
  Future<Map<String, String>?> getUserProfile() async {
    final id = await _storage.read(key: _userIdKey);
    if (id == null) return null;
    return {
      'id': id,
      'name': await _storage.read(key: _userNameKey) ?? '',
      'email': await _storage.read(key: _userEmailKey) ?? '',
      'role': await _storage.read(key: _userRoleKey) ?? 'Member',
    };
  }

  /// Removes all stored credentials and profile data.
  Future<void> clearAll() => _storage.deleteAll();
}
