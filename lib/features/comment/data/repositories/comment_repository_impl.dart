import 'dart:async';
import 'package:comicsapp/features/comment/domain/entities/comment_entity.dart';
import 'package:comicsapp/features/comment/domain/repositories/comment_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommentRepositoryImpl implements CommentRepository {
  final SupabaseClient _supabaseClient;

  CommentRepositoryImpl(this._supabaseClient);

  @override
  Stream<List<CommentEntity>> watchComments(String chapterId) {
    // Tạo một stream controller để quản lý dữ liệu
    final controller = StreamController<List<CommentEntity>>();

    // Lắng nghe các thay đổi trên bảng 'Comment'
    final subscription = _supabaseClient
        .from('Comment')
        .stream(primaryKey: ['comment_id'])
        .eq('chapter_id', chapterId)
        .order('created_at', ascending: true)
        .listen((maps) {
          // Khi có dữ liệu mới, chuyển đổi nó thành danh sách CommentEntity
          final comments = maps.map((map) => CommentEntity.fromMap(map)).toList();
          controller.add(comments);
        });
    
    // Khi stream bị hủy, đóng subscription để tránh memory leak
    controller.onCancel = () {
      subscription.cancel();
    };

    return controller.stream;
  }

  @override
  Future<void> postComment({
    required String content,
    required String chapterId,
    String? parentCommentId,
  }) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      throw const AuthException('Người dùng chưa đăng nhập');
    }

    try {
      await _supabaseClient.from('Comment').insert({
        'user_id': user.id,
        'chapter_id': chapterId,
        'content': content,
        'parent_comment_id': parentCommentId,
      });
    } catch (e) {
      // Ném lại lỗi để lớp presentation có thể xử lý
      rethrow;
    }
  }
}
