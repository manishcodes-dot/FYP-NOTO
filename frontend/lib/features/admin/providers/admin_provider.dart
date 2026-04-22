import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../profile/models/user.dart';

final adminControllerProvider = StateNotifierProvider<AdminController, AdminState>((ref) => AdminController(ref));

class AdminState {
  final List<User> users;
  final Map<String, dynamic> stats;
  final bool isLoading;
  final String? error;

  AdminState({this.users = const [], this.stats = const {}, this.isLoading = false, this.error});

  AdminState copyWith({List<User>? users, Map<String, dynamic>? stats, bool? isLoading, String? error}) {
    return AdminState(
      users: users ?? this.users,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AdminController extends StateNotifier<AdminState> {
  AdminController(this.ref) : super(AdminState());
  final Ref ref;

  Future<void> fetchStats() async {
    state = state.copyWith(isLoading: true);
    try {
      final res = await ref.read(dioProvider).get('/admin/stats');
      state = state.copyWith(stats: res.data['data'] as Map<String, dynamic>, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchUsers({String? search}) async {
    state = state.copyWith(isLoading: true);
    try {
      final res = await ref.read(dioProvider).get('/admin/users', queryParameters: search != null ? {'search': search} : null);
      final users = (res.data['data'] as List).map((u) => User.fromJson(u)).toList();
      state = state.copyWith(users: users, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> toggleUserStatus(String id) async {
    try {
      await ref.read(dioProvider).post('/admin/users/$id/toggle-status');
      await fetchUsers(); // Refresh
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> togglePremium(String id) async {
    try {
      await ref.read(dioProvider).post('/admin/users/$id/toggle-premium');
      await fetchUsers(); // Refresh
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
