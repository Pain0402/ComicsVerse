import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/theme/app_theme.dart';
import 'core/router/app_router.dart';

// The root widget of the application.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the GoRouter provider to integrate routing.
    final router = ref.watch(goRouterProvider);

    // Use MaterialApp.router to configure the app with GoRouter.
    return MaterialApp.router(
      title: 'ComicsVerse',
      debugShowCheckedModeBanner: false,

      // Theme configuration.
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Automatically select theme based on system settings.

      // Router configuration.
      routerConfig: router,
    );
  }
}
