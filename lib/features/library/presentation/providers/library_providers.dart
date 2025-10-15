import 'package:comicsapp/features/auth/presentation/providers/auth_providers.dart';
import 'package:comicsapp/features/home/domain/entities/story.dart';
import 'package:comicsapp/features/library/data/repositories/library_repository_impl.dart';
import 'package:comicsapp/features/library/domain/repositories/library_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider cung cấp instance của LibraryRepository
final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return LibraryRepositoryImpl(supabaseClient);
});

/// Provider để lấy danh sách các truyện đã bookmark
final bookmarkedStoriesProvider = FutureProvider<List<Story>>((ref) async {
  final libraryRepository = ref.watch(libraryRepositoryProvider);
  return libraryRepository.getBookmarkedStories();
});

/// StateNotifier để quản lý trạng thái bookmark của một truyện cụ thể (đã thêm/chưa thêm)
final isBookmarkedProvider = StateNotifierProvider.family<IsBookmarkedNotifier, AsyncValue<bool>, String>((ref, storyId) {
  final libraryRepository = ref.watch(libraryRepositoryProvider);
  return IsBookmarkedNotifier(libraryRepository, storyId);
});

class IsBookmarkedNotifier extends StateNotifier<AsyncValue<bool>> {
  final LibraryRepository _libraryRepository;
  final String _storyId;

  IsBookmarkedNotifier(this._libraryRepository, this._storyId) : super(const AsyncValue.loading()) {
    _checkIfBookmarked();
  }

  Future<void> _checkIfBookmarked() async {
    try {
      final isBookmarked = await _libraryRepository.isStoryBookmarked(_storyId);
      state = AsyncValue.data(isBookmarked);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleBookmark() async {
    // Cập nhật UI ngay lập tức để tạo cảm giác phản hồi nhanh
    final previousState = state.value;
    if (previousState == null) return;

    state = AsyncValue.data(!previousState);

    try {
      if (!previousState) {
        await _libraryRepository.addStoryToBookmarks(_storyId);
      } else {
        await _libraryRepository.removeStoryFromBookmarks(_storyId);
      }
      // Sau khi API thành công, không cần làm gì thêm vì UI đã được cập nhật
    } catch (e, st) {
      // Nếu có lỗi, quay lại trạng thái cũ và báo lỗi
      state = AsyncValue.data(previousState);
      // Có thể hiển thị SnackBar hoặc thông báo lỗi ở đây
      print('Error toggling bookmark: $e');
    }
  }
}
