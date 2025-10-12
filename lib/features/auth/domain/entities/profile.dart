class Profile {
  final String id;
  final String? displayName;
  final String? avatarUrl;
  final String? role;

  Profile({
    required this.id,
    this.displayName,
    this.avatarUrl,
    this.role,
  });

  // Factory constructor được làm mạnh mẽ hơn để xử lý các giá trị null
  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] ?? '',
      displayName: map['display_name'],
      avatarUrl: map['avatar_url'],
      role: map['role'] ?? 'reader',
    );
  }
}

