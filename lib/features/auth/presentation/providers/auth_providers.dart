import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

// 1. Provider cung cấp instance của Supabase client
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// 2. Provider cung cấp instance của AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return AuthRepositoryImpl(supabaseClient);
});

// 3. StreamProvider lắng nghe sự thay đổi trạng thái xác thực
// Nó sẽ tự động cập nhật và rebuild UI khi người dùng đăng nhập/đăng xuất
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});
