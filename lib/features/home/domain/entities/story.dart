import 'package:comicsapp/features/auth/domain/entities/profile.dart';

class Story {
  final String storyId;
  final Profile author;
  final String title;
  final String? synopsis;
  final String? coverImageUrl;
  final String status;
  final bool isVipOnly;
  final double averageRating;
  final int totalReads;
  final DateTime createdAt;
  final DateTime updatedAt;

  Story({
    required this.storyId,
    required this.author,
    required this.title,
    this.synopsis,
    this.coverImageUrl,
    required this.status,
    required this.isVipOnly,
    required this.averageRating,
    required this.totalReads,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor được làm mạnh mẽ hơn để xử lý các giá trị null
  factory Story.fromMap(Map<String, dynamic> map) {
    return Story(
      storyId: map['story_id'] ?? '',
      author: map['profiles'] != null
          ? Profile.fromMap(map['profiles'] as Map<String, dynamic>)
          : Profile(id: '', displayName: 'Unknown Author'),
      title: map['title'] ?? 'No Title',
      synopsis: map['synopsis'],
      coverImageUrl: map['cover_image_url'],
      status: map['status'] ?? 'draft',
      isVipOnly: map['is_vip_only'] ?? false,
      averageRating: (map['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReads: map['total_reads'] as int? ?? 0,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : DateTime.now(),
    );
  }
}

