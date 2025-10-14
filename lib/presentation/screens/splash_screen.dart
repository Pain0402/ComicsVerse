import 'package:flutter/material.dart';

/// Một màn hình đơn giản hiển thị một vòng xoay tải ở giữa.
/// Màn hình này sẽ được hiển thị trong khi ứng dụng đang xác định
/// trạng thái đăng nhập của người dùng khi khởi động.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
