import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../models/friend_user.dart';

class FriendsState {
  const FriendsState({
    this.friends = const [],
    this.incoming = const [],
    this.searchResults = const [],
    this.isLoading = false,
    this.error,
  });

  final List<FriendUser> friends;
  final List<Map<String, dynamic>> incoming;
  final List<Map<String, dynamic>> searchResults;
  final bool isLoading;
  final String? error;

  FriendsState copyWith({
    List<FriendUser>? friends,
    List<Map<String, dynamic>>? incoming,
    List<Map<String, dynamic>>? searchResults,
    bool? isLoading,
    String? error,
  }) =>
      FriendsState(
        friends: friends ?? this.friends,
        incoming: incoming ?? this.incoming,
        searchResults: searchResults ?? this.searchResults,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

final friendsControllerProvider = StateNotifierProvider<FriendsController, FriendsState>(
  (ref) => FriendsController(ref),
);

class FriendsController extends StateNotifier<FriendsState> {
  FriendsController(this.ref) : super(const FriendsState());

  final Ref ref;

  Future<void> refreshAll() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      final fr = await dio.get('/friends');
      final inc = await dio.get('/friends/incoming');
      final friendsList = List<Map<String, dynamic>>.from(fr.data['data']['items'] as List);
      final incomingList = List<Map<String, dynamic>>.from(inc.data['data']['items'] as List);
      state = FriendsState(
        friends: friendsList.map(FriendUser.fromJson).toList(),
        incoming: incomingList,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Could not load friends');
    }
  }

  Future<String?> requestByEmail(String email) async {
    try {
      await ref.read(dioProvider).post('/friends/request', data: {'email': email.trim().toLowerCase()});
      await refreshAll();
      return null;
    } catch (e) {
      return 'Could not send request';
    }
  }

  Future<void> requestById(String userId) async {
    try {
      await ref.read(dioProvider).post('/friends/request', data: {'targetUserId': userId});
      await refreshAll();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> searchUsers(String query) async {
    if (query.length < 2) {
      state = state.copyWith(searchResults: []);
      return;
    }
    try {
      final res = await ref.read(dioProvider).get('/users/search', queryParameters: {'q': query});
      final list = List<Map<String, dynamic>>.from(res.data['data'] as List);
      state = state.copyWith(searchResults: list);
    } catch (e) {
      // Fail silently for search
    }
  }

  Future<void> accept(String friendshipId) async {
    await ref.read(dioProvider).post('/friends/accept/$friendshipId');
    await refreshAll();
  }

  Future<void> reject(String friendshipId) async {
    await ref.read(dioProvider).post('/friends/reject/$friendshipId');
    await refreshAll();
  }

  Future<void> removeFriend(String friendUserId) async {
    await ref.read(dioProvider).delete('/friends/$friendUserId');
    await refreshAll();
  }
}
