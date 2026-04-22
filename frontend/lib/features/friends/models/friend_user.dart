class FriendUser {
  const FriendUser({required this.id, required this.fullName, required this.email});

  final String id;
  final String fullName;
  final String email;

  factory FriendUser.fromJson(Map<String, dynamic> json) => FriendUser(
        id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
        fullName: json['fullName'] as String? ?? '',
        email: json['email'] as String? ?? '',
      );
}
