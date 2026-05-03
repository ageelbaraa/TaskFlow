import 'package:dio/dio.dart';

import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Concrete [AuthRepository] that coordinates remote calls with local secure storage.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._storage);

  final AuthRemoteDataSource _remote;
  final SecureStorageService _storage;

  @override
  Future<UserEntity> login({required String email, required String password}) async {
    try {
      final model = await _remote.login(email: email, password: password);
      await _persistSession(model);
      return _toEntity(model);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final model = await _remote.register(name: name, email: email, password: password);
      await _persistSession(model);
      return _toEntity(model);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  @override
  Future<void> logout() => _storage.clearAll();

  @override
  Future<UserEntity?> getStoredSession() async {
    final profile = await _storage.getUserProfile();
    final token = await _storage.getToken();
    if (profile == null || token == null) return null;

    // Decode the exp claim to check expiry without a full JWT library.
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = parts[1];
      // Pad base64 to multiple of 4
      final padded = payload.padRight((payload.length + 3) ~/ 4 * 4, '=');
      final decoded = String.fromCharCodes(
        Uri.decodeFull(padded).codeUnits,
      );
      // Simple exp extraction — avoids importing a JWT library
      final expMatch = RegExp(r'"exp":(\d+)').firstMatch(decoded);
      if (expMatch != null) {
        final exp = int.parse(expMatch.group(1)!);
        final expiresAt = DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
        if (expiresAt.isBefore(DateTime.now().toUtc())) return null;

        return UserEntity(
          id: profile['id']!,
          name: profile['name']!,
          email: profile['email']!,
          role: profile['role']!,
          accessToken: token,
          expiresAt: expiresAt,
        );
      }
    } catch (_) {
      await _storage.clearAll();
    }
    return null;
  }

  Future<void> _persistSession(AuthResponseModel model) async {
    await _storage.saveToken(model.accessToken);
    await _storage.saveUserProfile(
      id: model.userId,
      name: model.name,
      email: model.email,
      role: model.role,
    );
  }

  UserEntity _toEntity(AuthResponseModel model) => UserEntity(
        id: model.userId,
        name: model.name,
        email: model.email,
        role: model.role,
        accessToken: model.accessToken,
        expiresAt: model.expiresAt,
      );

  Exception _mapDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final detail = e.response?.data is Map
        ? (e.response!.data as Map)['detail'] as String?
        : null;

    if (statusCode == 401) return Exception('Invalid email or password.');
    if (statusCode == 409) return Exception(detail ?? 'An account with this email already exists.');
    if (statusCode == 400) {
      final errors = e.response?.data is Map
          ? ((e.response!.data as Map)['errors'] as List?)
              ?.map((e) => e.toString())
              .join('\n')
          : null;
      return Exception(errors ?? 'Validation failed.');
    }
    return Exception('Network error. Please try again.');
  }
}
