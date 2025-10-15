import 'dart:io';
import 'package:comicsapp/features/auth/domain/entities/profile.dart';
import 'package:comicsapp/features/auth/presentation/providers/auth_providers.dart';
import 'package:comicsapp/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:comicsapp/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Provider cung cấp ProfileRepository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return ProfileRepositoryImpl(supabaseClient);
});

// 2. FutureProvider để lấy dữ liệu hồ sơ ban đầu
final userProfileProvider = StreamProvider.autoDispose<Profile?>((ref) async* {
  final profileRepository = ref.watch(profileRepositoryProvider);
  // Ban đầu, tải dữ liệu người dùng
  yield await profileRepository.getUserProfile();

  // Trong tương lai, có thể lắng nghe các stream thay đổi ở đây
  // Ví dụ: ref.watch(notificationStreamProvider).
});

// 3. StateNotifierProvider để quản lý trạng thái cập nhật hồ sơ
final profileUpdaterProvider =
    StateNotifierProvider<ProfileUpdaterNotifier, AsyncValue<void>>((ref) {
  return ProfileUpdaterNotifier(ref);
});

class ProfileUpdaterNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  ProfileUpdaterNotifier(this._ref) : super(const AsyncData(null));

  Future<void> updateProfile({
    required String displayName,
    File? avatarFile,
  }) async {
    state = const AsyncLoading();
    final user = _ref.read(supabaseClientProvider).auth.currentUser;
    if (user == null) {
      state = AsyncError('User not logged in', StackTrace.current);
      return;
    }
    
    try {
      await _ref.read(profileRepositoryProvider).updateUserProfile(
            userId: user.id,
            displayName: displayName,
            avatarFile: avatarFile,
          );
      // Cập nhật thành công, làm mới lại provider userProfile
      _ref.invalidate(userProfileProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
