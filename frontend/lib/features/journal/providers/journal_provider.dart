import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../models/journal_entry.dart';

enum JournalListTab { mine, sharedWithMe }

class JournalState {
  const JournalState({
    this.entries = const [],
    this.selectedDateEntries = const [],
    this.isLoading = false,
    this.query = '',
    this.moodFilter,
    this.categoryFilter,
    this.tagFilter,
    this.tab = JournalListTab.mine,
  });

  final List<JournalEntry> entries;
  final List<JournalEntry> selectedDateEntries;
  final bool isLoading;
  final String query;
  final Mood? moodFilter;
  final JournalCategory? categoryFilter;
  final String? tagFilter;
  final JournalListTab tab;

  JournalState copyWith({
    List<JournalEntry>? entries,
    List<JournalEntry>? selectedDateEntries,
    bool? isLoading,
    String? query,
    Mood? moodFilter,
    JournalCategory? categoryFilter,
    String? tagFilter,
    bool clearMood = false,
    bool clearCategory = false,
    bool clearTag = false,
    JournalListTab? tab,
  }) =>
      JournalState(
        entries: entries ?? this.entries,
        selectedDateEntries: selectedDateEntries ?? this.selectedDateEntries,
        isLoading: isLoading ?? this.isLoading,
        query: query ?? this.query,
        moodFilter: clearMood ? null : (moodFilter ?? this.moodFilter),
        categoryFilter: clearCategory ? null : (categoryFilter ?? this.categoryFilter),
        tagFilter: clearTag ? null : (tagFilter ?? this.tagFilter),
        tab: tab ?? this.tab,
      );
}

final journalControllerProvider = StateNotifierProvider<JournalController, JournalState>(
  (ref) => JournalController(ref),
);

class JournalController extends StateNotifier<JournalState> {
  JournalController(this.ref) : super(const JournalState());

  final Ref ref;

  Future<void> setTab(JournalListTab t) async {
    state = state.copyWith(tab: t);
    if (t == JournalListTab.mine) {
      await fetchEntries();
    } else {
      await fetchSharedWithMe();
    }
  }

  Future<void> fetchEntries() async {
    // Capture filters BEFORE any state mutation so they survive the copyWith calls below.
    final mood = state.moodFilter;
    final category = state.categoryFilter;
    final tag = state.tagFilter;
    final query = state.query;

    state = state.copyWith(isLoading: true);
    try {
      final res = await ref.read(dioProvider).get('/journals', queryParameters: {
        if (query.isNotEmpty) 'search': query,
        if (mood != null) 'mood': _cap(mood.name),
        if (category != null) 'category': _cap(category.name),
        if (tag != null) 'tags': tag,
      });
      final data = List<Map<String, dynamic>>.from(res.data['data']['items'] as List);
      final entries = data.map(JournalEntry.fromJson).toList();
      state = state.copyWith(entries: _sortEntries(entries), isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> fetchSharedWithMe() async {
    state = state.copyWith(isLoading: true);
    try {
      final res = await ref.read(dioProvider).get('/journals/shared-with-me');
      final data = List<Map<String, dynamic>>.from(res.data['data']['items'] as List);
      final entries = data.map(JournalEntry.fromJson).toList();
      state = state.copyWith(entries: _sortEntries(entries), isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> shareEntry(String entryId, List<String> friendUserIds) async {
    await ref.read(dioProvider).post('/journals/$entryId/share', data: {'friendUserIds': friendUserIds});
    await fetchEntries();
  }

  Future<void> createEntry(JournalEntry entry) async {
    await ref.read(dioProvider).post('/journals', data: entry.toJson());
    await fetchEntries();
  }

  Future<void> updateEntry(String id, JournalEntry entry) async {
    await ref.read(dioProvider).patch('/journals/$id', data: entry.toJson());
    await fetchEntries();
  }

  Future<void> deleteEntry(String id) async {
    await ref.read(dioProvider).delete('/journals/$id');
    await fetchEntries();
  }

  Future<void> fetchByDate(DateTime date) async {
    final iso = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final res = await ref.read(dioProvider).get('/journals/calendar/$iso');
    final data = List<Map<String, dynamic>>.from(res.data['data']['items'] as List);
    state = state.copyWith(selectedDateEntries: data.map(JournalEntry.fromJson).toList());
  }

  void setQuery(String q) => state = state.copyWith(query: q);
  void setMood(Mood? m) => m == null
      ? state = state.copyWith(clearMood: true)
      : state = state.copyWith(moodFilter: m);
  void setCategory(JournalCategory? c) => c == null
      ? state = state.copyWith(clearCategory: true)
      : state = state.copyWith(categoryFilter: c);
  void setTag(String? t) => t == null
      ? state = state.copyWith(clearTag: true)
      : state = state.copyWith(tagFilter: t);
  Set<DateTime> get markedDates => state.entries.map((e) => DateTime(e.entryDate.year, e.entryDate.month, e.entryDate.day)).toSet();

  List<JournalEntry> _sortEntries(List<JournalEntry> list) {
    return list..sort((a, b) {
      if (a.isFavorite != b.isFavorite) return a.isFavorite ? -1 : 1;
      return b.entryDate.compareTo(a.entryDate);
    });
  }

  String _cap(String v) => v[0].toUpperCase() + v.substring(1);
}
