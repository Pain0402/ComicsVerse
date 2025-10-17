import 'package:comicsapp/features/home/domain/entities/chapter.dart';
import 'package:comicsapp/features/reader/presentation/screens/reader_screen.dart';
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
import 'package:comicsapp/features/home/domain/entities/story.dart';
import 'package:comicsapp/features/home/presentation/screens/story_details_screen.dart';
import 'package:comicsapp/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:comicsapp/presentation/screens/splash_screen.dart';
import 'package:comicsapp/features/search/presentation/screens/search_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

// Bọc GoRouter trong một Provider để có thể truy cập các provider khác
final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash', // BẮT ĐẦU TỪ SPLASH SCREEN
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/story/:storyId',
        builder: (context, state) {
          final storyId = state.pathParameters['storyId']!;
          // Lấy object Story từ extra để dùng cho Hero Animation
          final story = state.extra as Story?;
          return StoryDetailsScreen(storyId: storyId, story: story);
        },
        // ĐỊNH NGHĨA ROUTE LỒNG NHAU CHO MÀN HÌNH ĐỌC TRUYỆN
        routes: [
          GoRoute(
            path: 'chapter/:chapterId',
            builder: (context, state) {
              final storyId = state.pathParameters['storyId']!;
              // CẬP NHẬT: Lấy dữ liệu từ extra một cách an toàn hơn
              final extra = state.extra as Map<String, dynamic>?;
              final storyTitle =
                  extra?['storyTitle'] as String? ?? 'Đang tải...';
              final chapter = extra?['chapter'] as Chapter?;
              // THÊM MỚI: Lấy danh sách tất cả các chương
              final allChapters = extra?['allChapters'] as List<Chapter>? ?? [];
              
              if (chapter == null) {
                return const Scaffold(body: Center(child: Text("Lỗi: Không tìm thấy thông tin chương.")));
              }

              return ReaderScreen(
                storyId: storyId,
                storyTitle: storyTitle,
                chapter: chapter,
                allChapters: allChapters, // Truyền vào ReaderScreen
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) => const LibraryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    // Logic điều hướng tự động
    // SỬA ĐỔI: Cập nhật toàn bộ logic điều hướng tự động
    redirect: (context, state) {
      // Trong khi trạng thái xác thực đang tải, chúng ta không làm gì cả.
      // Người dùng sẽ tiếp tục thấy màn hình chờ (SplashScreen).
      if (authState.isLoading || authState.hasError) {
        return null;
      }

      // Xác định người dùng đã đăng nhập hay chưa.
      final isLoggedIn = authState.valueOrNull != null;

      // Lấy vị trí hiện tại của người dùng.
      final location = state.uri.toString();
      final isAtSplash = location == '/splash';
      final isAtAuthScreen = location == '/login' || location == '/signup';

      // Kịch bản 1: Nếu đang ở màn hình chờ, phải điều hướng đi.
      if (isAtSplash) {
        return isLoggedIn ? '/home' : '/login';
      }

      // Kịch bản 2: Nếu đã đăng nhập nhưng lại ở màn hình đăng nhập/đăng ký.
      if (isLoggedIn && isAtAuthScreen) {
        return '/home';
      }

      // Kịch bản 3: Nếu chưa đăng nhập và cố gắng truy cập trang cần bảo vệ.
      if (!isLoggedIn && !isAtAuthScreen) {
        return '/login';
      }

      // Trong mọi trường hợp khác, không cần điều hướng.
      return null;
    },
  );
});

