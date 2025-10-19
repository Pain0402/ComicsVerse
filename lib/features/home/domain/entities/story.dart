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

  /// A robust factory for creating a [Story] instance from a map.
  /// Handles null values and type conversions gracefully.
  factory Story.fromMap(Map<String, dynamic> map) {
    final num totalReadsNum = map['total_reads'] ?? 0;

    return Story(
      storyId: map['story_id'] ?? '',
      author: map['profiles'] is Map<String, dynamic>
          ? Profile.fromMap(map['profiles'] as Map<String, dynamic>)
          : Profile(id: map['author_id'] ?? '', displayName: 'Unknown Author'),
      title: map['title'] ?? 'No Title',
      synopsis: map['synopsis'],
      coverImageUrl: map['cover_image_url'],
      status: map['status'] ?? 'draft',
      isVipOnly: map['is_vip_only'] ?? false,
      averageRating: (map['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReads: totalReadsNum.toInt(),
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now(),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : DateTime.now(),
    );
  }
}
