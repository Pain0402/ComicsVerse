import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/library/presentation/screens/library_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../presentation/screens/scaffold_with_nav_bar.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

// Bọc GoRouter trong một Provider để có thể truy cập các provider khác
final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/library',
              builder: (context, state) => const LibraryScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ]),
        ],
      ),
    ],
    // Logic điều hướng tự động
    redirect: (context, state) {
      // authStateChangesProvider sẽ cung cấp trạng thái người dùng
      // .value cho phép truy cập dữ liệu một cách an toàn
      final user = authState.value;
      final isLoggedIn = user != null;

      final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/signup';

      if (!isLoggedIn && !isLoggingIn) {
        // Nếu chưa đăng nhập và không ở trang login/signup, chuyển về login
        return '/login';
      }

      if (isLoggedIn && isLoggingIn) {
        // Nếu đã đăng nhập và đang ở trang login/signup, chuyển đến trang chủ
        return '/home';
      }

      // Không cần điều hướng, trả về null
      return null;
    },
  );
});


