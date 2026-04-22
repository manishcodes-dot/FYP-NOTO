import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../profile/models/user.dart';

class AuthState {
  const AuthState({this.user, this.isLoading = false, this.error, this.token});

  final User? user;
  final bool isLoading;
  final String? error;
  final String? token;
  bool get isAuthenticated => token != null && user != null;

  AuthState copyWith({User? user, bool? isLoading, String? error, String? token}) => AuthState(
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        error: error,
        token: token ?? this.token,
      );
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref),
);

class AuthController extends StateNotifier<AuthState> {
  AuthController(this.ref) : super(const AuthState());

  final Ref ref;

  Future<void> restoreSession() async {
    try {
      final token = await ref.read(tokenStorageProvider).getToken();
      if (token != null) {
        state = state.copyWith(token: token);
        await fetchProfile();
      }
    } catch (e) {
      debugPrint("Restore Session Error: $e");
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await ref.read(dioProvider).post('/auth/login', data: {'email': email, 'password': password});
      final token = res.data['data']['token'] as String;
      final user = User.fromJson(res.data['data']['user'] as Map<String, dynamic>);
      await ref.read(tokenStorageProvider).saveToken(token);
      state = AuthState(user: user, token: token);
      return true;
    } on DioException catch (e) {
      final msg = e.response?.data?['message']?.toString() ?? 'Login failed';
      state = state.copyWith(isLoading: false, error: msg);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Connection error');
      return false;
    }
  }

  Future<bool> register(String fullName, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await ref.read(dioProvider).post(
            '/auth/register',
            data: {'fullName': fullName, 'email': email, 'password': password},
          );
      final token = res.data['data']['token'] as String;
      final user = User.fromJson(res.data['data']['user'] as Map<String, dynamic>);
      await ref.read(tokenStorageProvider).saveToken(token);
      state = AuthState(user: user, token: token);
      return true;
    } on DioException catch (e) {
      final msg = e.response?.data?['message']?.toString() ?? 'Registration failed';
      state = state.copyWith(isLoading: false, error: msg);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Connection error');
      return false;
    }
  }

  Future<void> fetchProfile() async {
    try {
      final res = await ref.read(dioProvider).get('/users/me');
      final user = User.fromJson(res.data['data'] as Map<String, dynamic>);
      state = state.copyWith(user: user);
    } catch (_) {}
  }

  Future<void> logout() async {
    await ref.read(tokenStorageProvider).clearToken();
    state = const AuthState();
  }

  void clearSession() => state = const AuthState();
}
