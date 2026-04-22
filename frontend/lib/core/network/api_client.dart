import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/providers/auth_provider.dart';
import 'token_storage_service.dart';

const _envBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');

String _resolveBaseUrl() {
  if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
  if (kIsWeb) return 'http://127.0.0.1:5000/api';
  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:5000/api';
  }
  return 'http://127.0.0.1:5000/api';
}

final tokenStorageProvider = Provider<TokenStorageService>(
  (ref) => TokenStorageService(const FlutterSecureStorage()),
);

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(baseUrl: _resolveBaseUrl(), connectTimeout: const Duration(seconds: 15)));
  final tokenStorage = ref.read(tokenStorageProvider);

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (e, handler) async {
        if (e.response?.statusCode == 401) {
          await tokenStorage.clearToken();
          ref.read(authControllerProvider.notifier).clearSession();
        }
        handler.next(e);
      },
    ),
  );

  return dio;
});
