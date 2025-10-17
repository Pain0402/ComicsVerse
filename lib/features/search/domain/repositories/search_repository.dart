import 'package:comicsapp/features/home/domain/entities/story.dart';

abstract class SearchRepository {
  /// Tìm kiếm truyện dựa trên một query string.
  /// Trả về một danh sách các truyện phù hợp.
  Future<List<Story>> searchStories(String query);
}
