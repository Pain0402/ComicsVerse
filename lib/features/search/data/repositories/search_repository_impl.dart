import 'package:comicsapp/features/home/domain/entities/story.dart';
import 'package:comicsapp/features/search/domain/repositories/search_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SupabaseClient supabaseClient;

  SearchRepositoryImpl(this.supabaseClient);

  @override
  Future<List<Story>> searchStories(String query) async {
    try {
      // Sử dụng .ilike() để tìm kiếm không phân biệt chữ hoa/thường.
      // '%$query%' có nghĩa là tìm bất kỳ truyện nào có tiêu đề chứa chuỗi query.
      final response = await supabaseClient
          .from('Story')
          .select('*, profiles:author_id(*)') // Dựa theo cấu trúc CSDL của bạn
          .ilike('title', '%$query%');

      // Chuyển đổi kết quả JSON thành danh sách các đối tượng Story.
      final stories = (response as List)
          .map((item) => Story.fromMap(item))
          .toList();
      return stories;
    } catch (e) {
      // Xử lý lỗi nếu có
      throw Exception('Lỗi khi tìm kiếm truyện: $e');
    }
  }
}
