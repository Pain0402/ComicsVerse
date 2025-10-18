class Profile {
  final String id;
  final String? displayName;
  final String? avatarUrl;
  final String? role;
  // THÊM MỚI: Các trường thống kê
  final int bookmarkedStoriesCount;
  final int commentsCount;
  final int reviewsCount;

  Profile({
    required this.id,
    this.displayName,
    this.avatarUrl,
    this.role,
    // THÊM MỚI: Khởi tạo giá trị mặc định
    this.bookmarkedStoriesCount = 0,
    this.commentsCount = 0,
    this.reviewsCount = 0,
  });

  /// Factory này dùng cho RPC `get_user_profile_details` trả về cấu trúc lồng nhau
  factory Profile.fromMap(Map<String, dynamic> map) {
    // Lấy dữ liệu profile và stats từ JSON trả về của RPC
    final profileMap = map['profile'] as Map<String, dynamic>? ?? {};
    final statsMap = map['stats'] as Map<String, dynamic>? ?? {};

    return Profile(
      id: profileMap['id'] ?? '',
      displayName: profileMap['display_name'],
      avatarUrl: profileMap['avatar_url'],
      role: profileMap['role'] ?? 'reader',
      // THÊM MỚI: Gán giá trị thống kê
      bookmarkedStoriesCount: statsMap['bookmarked_stories_count'] ?? 0,
      commentsCount: statsMap['comments_count'] ?? 0,
      reviewsCount: statsMap['reviews_count'] ?? 0,
    );
  }

  /// Factory mới để parse dữ liệu profile được join trực tiếp từ câu lệnh select
  factory Profile.fromEmbeddedMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] ?? '',
      displayName: map['display_name'],
      avatarUrl: map['avatar_url'],
      role: map['role'] ?? 'reader',
    );
  }
}
