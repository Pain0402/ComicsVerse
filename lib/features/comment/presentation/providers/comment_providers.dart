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

/// StreamProvider lắng nghe danh sách bình luận (dạng phẳng) của một chương.
/// Sử dụng `.family` để có thể truyền `chapterId` vào.
final commentsStreamProvider =
    StreamProvider.autoDispose.family<List<CommentEntity>, String>((ref, chapterId) {
  final commentRepository = ref.watch(commentRepositoryProvider);
  return commentRepository.watchComments(chapterId);
});

/// Provider mới để xử lý danh sách bình luận phẳng thành dạng cây (có replies lồng nhau)
final nestedCommentsProvider =
    Provider.autoDispose.family<List<CommentEntity>, String>((ref, chapterId) {
  // Lắng nghe danh sách bình luận phẳng từ stream
  final commentsAsync = ref.watch(commentsStreamProvider(chapterId));

  return commentsAsync.when(
    data: (flatList) {
      final repliesMap = <String, List<CommentEntity>>{};
      final topLevelComments = <CommentEntity>[];

      // Phân loại comments và replies
      for (final comment in flatList) {
        if (comment.parentId != null) {
          (repliesMap[comment.parentId!] ??= []).add(comment);
        } else {
          topLevelComments.add(comment);
        }
      }

      // Tạo danh sách kết quả cuối cùng với các replies được gán đúng cách
      final result = topLevelComments.map((parentComment) {
        if (repliesMap.containsKey(parentComment.id)) {
          // Tạo một bản sao của comment cha với danh sách replies mới
          return parentComment.copyWith(replies: repliesMap[parentComment.id]);
        }
        return parentComment;
      }).toList();

      return result;
    },
    // Trả về danh sách rỗng cho các trạng thái khác
    loading: () => [],
    error: (e, st) => [],
  );
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

