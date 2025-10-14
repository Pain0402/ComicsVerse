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
    url: 'https://ezdqwuypgldtkcwtuate.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV6ZHF3dXlwZ2xkdGtjd3R1YXRlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk5NDYxNjEsImV4cCI6MjA3NTUyMjE2MX0.ATd8pP2zRvw91yWeK4SqeTmsPvCYdoSZktQzhta2x2s',
  );

  // Chạy ứng dụng
  // runApp(const App());
  runApp(const ProviderScope(child: App()));
}

// Lấy instance của Supabase client để sử dụng trong ứng dụng
// final supabase = Supabase.instance.client;
