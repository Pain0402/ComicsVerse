import 'package:comicsapp/features/auth/domain/entities/profile.dart';

/// Đại diện cho một đối tượng bình luận trong ứng dụng.
class CommentEntity {
  final String id;
  final String content;
  final DateTime createdAt;
  final Profile author; // Thông tin người viết bình luận
  final String? parentId;

  CommentEntity({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.author,
    this.parentId,
  });

  /// Factory constructor để tạo một CommentEntity từ dữ liệu JSON (map) trả về từ Supabase.
  factory CommentEntity.fromMap(Map<String, dynamic> map) {
    return CommentEntity(
      id: map['comment_id'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      // Giả định rằng dữ liệu profile được lồng vào trong response
      // thông qua câu lệnh select('*, profiles(*)')
      author: map['profiles'] != null
          ? Profile.fromMap(map['profiles'] as Map<String, dynamic>)
          : Profile(id: map['user_id'], displayName: 'Người dùng ẩn danh'),
      parentId: map['parent_comment_id'] as String?,
    );
  }
}
