import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';

/// DTO mirrors the server's AuthResponseDto record.
class AuthResponseModel {
  const AuthResponseModel({
    required this.accessToken,
    required this.expiresAt,
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
  });

  final String accessToken;
  final DateTime expiresAt;
  final String userId;
  final String name;
  final String email;
  final String role;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['accessToken'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      userId: json['userId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }
}

/// Calls the remote auth REST endpoints and returns raw response models.
class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._client);

  final ApiClient _client;

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return AuthResponseModel.fromJson(response.data!);
  }

  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: {'name': name, 'email': email, 'password': password},
    );
    return AuthResponseModel.fromJson(response.data!);
  }
}
