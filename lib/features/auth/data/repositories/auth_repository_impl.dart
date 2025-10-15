import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';

// Lớp triển khai (implementation) của AuthRepository, sử dụng Supabase.
// Mọi logic liên quan đến Supabase Auth sẽ được đặt ở đây.
class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabaseClient;

  AuthRepositoryImpl(this._supabaseClient);

  @override
  Stream<User?> get authStateChanges => _supabaseClient.auth.onAuthStateChange
      .map((authState) => authState.session?.user);

  @override
  User? get currentUser => _supabaseClient.auth.currentUser;

  @override
  Future<void> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      // Bắt lỗi và ném ra lại để lớp presentation có thể xử lý
      rethrow;
    }
  }

  @override
  Future<void> signUp({required String email, required String password}) async {
    try {
      await _supabaseClient.auth.signUp(email: email, password: password);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      // Hàm này sẽ tự động mở một web view để người dùng đăng nhập
      // và xử lý redirect về ứng dụng nhờ các cấu hình native ở trên.
      await _supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        // URL mà trình duyệt sẽ quay về sau khi đăng nhập thành công
        redirectTo: 'com.example.comicsapp://callback',
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
}
