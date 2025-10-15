import 'package:comicsapp/features/auth/presentation/providers/auth_providers.dart';
import 'package:comicsapp/features/comment/data/repositories/comment_repository_impl.dart';
import 'package:comicsapp/features/comment/domain/entities/comment_entity.dart';
import 'package:comicsapp/features/comment/domain/repositories/comment_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider cung cấp instance của CommentRepository.
final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return CommentRepositoryImpl(supabaseClient);
});

/// StreamProvider lắng nghe danh sách bình luận của một chương.
/// Sử dụng `.family` để có thể truyền `chapterId` vào.
final commentsStreamProvider =
    StreamProvider.autoDispose.family<List<CommentEntity>, String>((ref, chapterId) {
  final commentRepository = ref.watch(commentRepositoryProvider);
  return commentRepository.watchComments(chapterId);
});

/// StateNotifierProvider quản lý trạng thái của việc gửi bình luận.
final commentPostControllerProvider =
    StateNotifierProvider.autoDispose<CommentPostController, AsyncValue<void>>((ref) {
  return CommentPostController(ref.watch(commentRepositoryProvider));
});

class CommentPostController extends StateNotifier<AsyncValue<void>> {
  final CommentRepository _commentRepository;

  CommentPostController(this._commentRepository) : super(const AsyncData(null));

  /// Hàm để gửi bình luận, quản lý trạng thái loading và error.
  Future<void> postComment({
    required String content,
    required String chapterId,
    String? parentCommentId,
  }) async {
    state = const AsyncLoading();
    try {
      await _commentRepository.postComment(
        content: content,
        chapterId: chapterId,
        parentCommentId: parentCommentId,
      );
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
