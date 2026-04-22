class User {
  const User({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    this.isPremium = false,
    this.subscriptionPlan = 'free',
    this.subscriptionExpiry,
    this.role = 'user',
    this.isActive = true,
  });

  final String id;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final bool isPremium;
  final String subscriptionPlan;
  final DateTime? subscriptionExpiry;
  final String role;
  final bool isActive;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        fullName: json['fullName'] as String? ?? '',
        email: json['email'] as String? ?? '',
        avatarUrl: json['avatarUrl'] as String?,
        isPremium: json['isPremium'] as bool? ?? false,
        subscriptionPlan: json['subscriptionPlan'] as String? ?? 'free',
        subscriptionExpiry: json['subscriptionExpiry'] != null ? DateTime.parse(json['subscriptionExpiry'] as String) : null,
        role: json['role'] as String? ?? 'user',
        isActive: json['isActive'] as bool? ?? true,
      );
}
