import 'package:comicsapp/features/home/domain/entities/story.dart';

abstract class LibraryRepository {
  /// Lấy danh sách tất cả các truyện đã được bookmark bởi người dùng hiện tại
  Future<List<Story>> getBookmarkedStories();

  /// Kiểm tra xem một truyện cụ thể đã được bookmark hay chưa
  Future<bool> isStoryBookmarked(String storyId);

  /// Thêm một truyện vào bookmark
  Future<void> addStoryToBookmarks(String storyId);

  /// Xóa một truyện khỏi bookmark
  Future<void> removeStoryFromBookmarks(String storyId);
}
