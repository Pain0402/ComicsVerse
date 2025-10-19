class Profile {
  final String id;
  final String? displayName;
  final String? avatarUrl;
  final String? role;
  // User statistics
  final int bookmarkedStoriesCount;
  final int commentsCount;
  final int reviewsCount;

  Profile({
    required this.id,
    this.displayName,
    this.avatarUrl,
    this.role,
    this.bookmarkedStoriesCount = 0,
    this.commentsCount = 0,
    this.reviewsCount = 0,
  });

  /// Factory for creating a Profile from the nested structure returned by the `get_user_profile_details` RPC.
  factory Profile.fromMap(Map<String, dynamic> map) {
    final profileMap = map['profile'] as Map<String, dynamic>? ?? {};
    final statsMap = map['stats'] as Map<String, dynamic>? ?? {};

    return Profile(
      id: profileMap['id'] ?? '',
      displayName: profileMap['display_name'],
      avatarUrl: profileMap['avatar_url'],
      role: profileMap['role'] ?? 'reader',
      bookmarkedStoriesCount: statsMap['bookmarked_stories_count'] ?? 0,
      commentsCount: statsMap['comments_count'] ?? 0,
      reviewsCount: statsMap['reviews_count'] ?? 0,
    );
  }

  /// Factory for parsing profile data embedded directly in a `select` query (e.g., from a join).
  factory Profile.fromEmbeddedMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] ?? '',
      displayName: map['display_name'],
      avatarUrl: map['avatar_url'],
      role: map['role'] ?? 'reader',
    );
  }
}
