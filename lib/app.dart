import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/theme/app_theme.dart';
import 'core/router/app_router.dart';

// Widget gốc của ứng dụng
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Đọc router từ goRouterProvider
    final router = ref.watch(goRouterProvider);

    // MaterialApp.router cho phép tích hợp với GoRouter
    return MaterialApp.router(
      title: 'StoryVerse',
      debugShowCheckedModeBanner: false,

      // Cấu hình theme sáng
      theme: AppTheme.lightTheme,
      // Cấu hình theme tối
      darkTheme: AppTheme.darkTheme,
      // Tự động chọn theme dựa trên cài đặt hệ thống
      themeMode: ThemeMode.system,

      // Cấu hình router
      routerConfig: router,
    );
  }
}
