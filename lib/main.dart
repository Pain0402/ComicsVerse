import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

// Hàm main - điểm khởi đầu của ứng dụng
Future<void> main() async {
  // Đảm bảo các thành phần của Flutter đã được khởi tạo trước khi chạy app
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Supabase client
  // TODO: Thay thế url và anonKey bằng thông tin dự án của bạn từ Supabase Dashboard
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  // Chạy ứng dụng
  // runApp(const App());
  runApp(const ProviderScope(child: App()));
}

// Lấy instance của Supabase client để sử dụng trong ứng dụng
// final supabase = Supabase.instance.client;
