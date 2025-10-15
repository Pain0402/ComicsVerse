import 'dart:io';
import 'package:comicsapp/features/auth/domain/entities/profile.dart';

abstract class ProfileRepository {
  /// Lấy thông tin hồ sơ của người dùng hiện tại
  Future<Profile?> getUserProfile();

  /// Cập nhật thông tin hồ sơ
  Future<void> updateUserProfile({
    required String userId,
    required String displayName,
    File? avatarFile,
  });

  /// Đăng xuất
  Future<void> signOut();
}
