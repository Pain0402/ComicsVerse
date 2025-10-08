import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Widget này tạo ra một Scaffold với BottomNavigationBar
// để sử dụng trong ShellRoute của GoRouter.
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  // 'navigationShell' quản lý trạng thái của các nhánh điều hướng (tabs)
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Hiển thị màn hình của tab hiện tại
      body: navigationShell,
      // Thanh điều hướng dưới cùng
      bottomNavigationBar: NavigationBar(
        // Chỉ số của tab đang được chọn
        selectedIndex: navigationShell.currentIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.book),
            icon: Icon(Icons.book_outlined),
            label: 'Tủ truyện',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person),
            icon: Icon(Icons.person_outline),
            label: 'Hồ sơ',
          ),
        ],
        // Hàm callback khi người dùng chọn một tab khác
        onDestinationSelected: (int index) {
          // Điều hướng đến nhánh tương ứng mà không làm mất trạng thái
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
