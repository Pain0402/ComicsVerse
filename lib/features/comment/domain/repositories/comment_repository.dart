import 'package:comicsapp/features/comment/domain/entities/comment_entity.dart';

/// Giao diện trừu tượng cho việc quản lý dữ liệu bình luận.
abstract class CommentRepository {
  /// Lắng nghe và nhận một stream danh sách các bình luận cho một chương.
  /// Sử dụng Stream để cập nhật real-time.
  Stream<List<CommentEntity>> watchComments(String chapterId);

  /// Gửi một bình luận mới.
  Future<void> postComment({
    required String content,
    required String chapterId,
    String? parentCommentId,
  });
}
