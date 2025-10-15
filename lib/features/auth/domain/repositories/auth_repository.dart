import 'package:supabase_flutter/supabase_flutter.dart';

// Định nghĩa một "hợp đồng" (contract) cho các chức năng xác thực.
// Lớp này không quan tâm việc xác thực được thực hiện bằng Supabase, Firebase hay một API tự viết.
abstract class AuthRepository {
  // Lấy stream theo dõi sự thay đổi trạng thái xác thực (đăng nhập, đăng xuất).
  Stream<User?> get authStateChanges;

  // Lấy người dùng hiện tại
  User? get currentUser;

  // Chức năng đăng nhập bằng email và mật khẩu.
  Future<void> signInWithPassword({
    required String email,
    required String password,
  });

  // Chức năng đăng ký bằng email và mật khẩu.
  Future<void> signUp({required String email, required String password});

  // Chức năng đăng nhập bằng Google.
  Future<void> signInWithGoogle();

  // Chức năng đăng xuất.
  Future<void> signOut();
}
