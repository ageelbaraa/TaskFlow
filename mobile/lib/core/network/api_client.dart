import 'package:dio/dio.dart';

import '../storage/secure_storage_service.dart';

/// Central Dio client. Attaches the JWT bearer token to every request automatically.
class ApiClient {
  late final Dio dio;

  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000',
  );

  ApiClient(SecureStorageService storage) {
    dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        contentType: 'application/json',
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Surface DioException as-is; repositories handle the mapping.
          return handler.next(e);
        },
      ),
    );
  }
}
