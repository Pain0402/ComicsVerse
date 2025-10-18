import 'package:comicsapp/features/auth/domain/entities/profile.dart';

/// Đại diện cho một đối tượng bình luận trong ứng dụng.
class CommentEntity {
  final String id;
  final String content;
  final DateTime createdAt;
  final Profile author; // Thông tin người viết bình luận
  final String? parentId;
  final List<CommentEntity> replies; // Danh sách các bình luận con

  CommentEntity({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.author,
    this.parentId,
    List<CommentEntity>? replies, // Cho phép truyền vào hoặc không
  }) : replies = replies ?? []; // Nếu null thì tạo list rỗng mới

  /// Factory constructor để tạo một CommentEntity từ dữ liệu JSON (map) trả về từ Supabase.
  factory CommentEntity.fromMap(Map<String, dynamic> map) {
    return CommentEntity(
      id: map['comment_id'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      // CẬP NHẬT: Sử dụng factory 'fromEmbeddedMap' mới
      author: map['profiles'] != null && map['profiles'] is Map<String, dynamic>
          ? Profile.fromEmbeddedMap(map['profiles'] as Map<String, dynamic>)
          : Profile(id: map['user_id'], displayName: 'Người dùng ẩn danh'),
      parentId: map['parent_comment_id'] as String?,
    );
  }

  // Hàm tiện ích để tạo một bản sao của đối tượng với các replies mới
  CommentEntity copyWith({
    List<CommentEntity>? replies,
  }) {
    return CommentEntity(
      id: id,
      content: content,
      createdAt: createdAt,
      author: author,
      parentId: parentId,
      replies: replies ?? this.replies,
    );
  }
}

