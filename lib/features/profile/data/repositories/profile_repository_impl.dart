import 'dart:io';
import 'package:comicsapp/features/auth/domain/entities/profile.dart';
import 'package:comicsapp/features/profile/domain/repositories/profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseClient _supabaseClient;

  ProfileRepositoryImpl(this._supabaseClient);

  @override
  Future<Profile?> getUserProfile() async {
    try {
      final user = _supabaseClient.auth.currentUser;
      if (user == null) return null;

      final data = await _supabaseClient.rpc(
        'get_user_profile_details',
        params: {'p_user_id': user.id},
      ).single();
      
      return Profile.fromMap(data);
    } catch (e) {
      print('Error fetching profile details: $e');
      return null;
    }
  }

  @override
  Future<void> updateUserProfile({
    required String userId,
    required String displayName,
    File? avatarFile,
  }) async {
    try {
      String? avatarUrl;
      if (avatarFile != null) {
        final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        // SỬA ĐỔI: Thêm đường dẫn 'avatars' vào đầu
        final filePath = 'avatars/$userId/$fileName';

        // SỬA ĐỔI: Đảm bảo bucket là 'profiles' nếu bạn đã tạo bucket đó, hoặc 'public' nếu bucket là public.
        // Lỗi "Bucket not found" cho thấy tên bucket đang sai.
        // Giả sử bạn đã tạo bucket tên 'public' theo hướng dẫn.
        await _supabaseClient.storage.from('public_avatar').upload(
              filePath,
              avatarFile,
              fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
            );
        
        avatarUrl = _supabaseClient.storage.from('public_avatar').getPublicUrl(filePath);
      }
      
      final updates = <String, dynamic>{
        'display_name': displayName,
      };

      if (avatarUrl != null) {
        updates['avatar_url'] = avatarUrl;
      }
      
      await _supabaseClient.from('profiles').update(updates).eq('id', userId);

    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }
}

