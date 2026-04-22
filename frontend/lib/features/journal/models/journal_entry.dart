enum Mood { happy, calm, neutral, sad, stressed }

enum JournalCategory { personal, study, work, family, ideas, goals }

class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.mood,
    required this.category,
    required this.tags,
    required this.entryDate,
    required this.createdAt,
    required this.updatedAt,
    this.isFavorite = false,
    this.isPinned = false,
    this.ownerName,
    this.ownerEmail,
    this.sharedWithIds = const [],
  });

  final String id;
  final String userId;
  final String title;
  final String content;
  final Mood mood;
  final JournalCategory category;
  final List<String> tags;
  final DateTime entryDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;
  final bool isPinned;
  final String? ownerName;
  final String? ownerEmail;
  final List<String> sharedWithIds;

  bool isOwnedBy(String? currentUserId) => currentUserId != null && userId == currentUserId;

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    final uid = _parseId(json['userId']);
    String? ownerName = json['ownerName'] as String?;
    String? ownerEmail = json['ownerEmail'] as String?;
    if (json['userId'] is Map) {
      final m = json['userId'] as Map<String, dynamic>;
      ownerName ??= m['fullName'] as String?;
      ownerEmail ??= m['email'] as String?;
    }
    final sw = json['sharedWith'];
    final sharedIds = <String>[];
    if (sw is List) {
      for (final x in sw) {
        if (x is String) sharedIds.add(x);
        if (x is Map && x['_id'] != null) sharedIds.add(x['_id'].toString());
      }
    }
    return JournalEntry(
      id: json['_id']?.toString() ?? json['id'].toString(),
      userId: uid,
      title: json['title'] as String,
      content: json['content'] as String,
      mood: Mood.values.firstWhere(
        (m) => m.name.toLowerCase() == (json['mood'] as String).toLowerCase(),
        orElse: () => Mood.neutral,
      ),
      category: JournalCategory.values.firstWhere(
        (c) => c.name.toLowerCase() == (json['category'] as String).toLowerCase(),
        orElse: () => JournalCategory.personal,
      ),
      tags: List<String>.from(json['tags'] ?? const <String>[]),
      entryDate: DateTime.parse(json['entryDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
      isPinned: json['isPinned'] as bool? ?? false,
      ownerName: ownerName,
      ownerEmail: ownerEmail,
      sharedWithIds: sharedIds,
    );
  }

  static String _parseId(dynamic v) {
    if (v == null) return '';
    if (v is String) return v;
    if (v is Map) return v['_id']?.toString() ?? v['id']?.toString() ?? '';
    return v.toString();
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'mood': _capitalize(mood.name),
        'category': _capitalize(category.name),
        'tags': tags,
        'entryDate': entryDate.toIso8601String(),
        'isFavorite': isFavorite,
        'isPinned': isPinned,
      };

  static String _capitalize(String value) => value[0].toUpperCase() + value.substring(1);
}
