import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:comicsapp/features/home/domain/entities/story.dart';
import 'package:comicsapp/features/auth/domain/entities/profile.dart'; // Giả sử đã có file này
import 'package:comicsapp/features/home/domain/entities/story_details.dart';

class StoryRepository {
  final SupabaseClient _client;
  StoryRepository(this._client);

  // Lấy tất cả truyện, sắp xếp theo ngày cập nhật mới nhất
  Future<List<Story>> getAllStories() async {
    try {
      final data = await _client
          .from('Story')
          .select()
          .order('updated_at', ascending: false);
      return data.map((item) => Story.fromMap(item)).toList();
    } catch (e) {
      // Trong ứng dụng thực tế, nên dùng một hệ thống logging tốt hơn
      print('Error fetching stories: $e');
      rethrow;
    }
  }

  // Hàm lấy chi tiết truyện bằng RPC
  Future<StoryDetails> getStoryDetails(String storyId) async {
    try {
      final response = await _client.rpc(
        'get_story_details',
        params: {'p_story_id': storyId},
      );
      return StoryDetails.fromRpcResponse(response as Map<String, dynamic>);
    } catch (e) {
      print('Error fetching story details: $e');
      rethrow;
    }
  }

  // Lấy thông tin profile của người dùng hiện tại
  Future<Profile?> getUserProfile() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final data =
          await _client.from('profiles').select().eq('id', user.id).single();
      return Profile.fromMap(data);
    } catch (e) {
      print('Error fetching profile: $e');
      // Trả về null nếu không tìm thấy hoặc có lỗi
      return null;
    }
  }
}

