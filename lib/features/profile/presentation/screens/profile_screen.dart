import 'package:comicsapp/features/auth/presentation/providers/auth_providers.dart';
import 'package:comicsapp/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ Sơ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/profile/edit'),
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Không tìm thấy thông tin người dùng.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: colorScheme.surfaceVariant,
                      backgroundImage: profile.avatarUrl != null
                          ? NetworkImage(profile.avatarUrl!)
                          : null,
                      child: profile.avatarUrl == null
                          ? Icon(Icons.person, size: 50, color: colorScheme.onSurfaceVariant)
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.displayName ?? 'Chưa có tên',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ref.read(supabaseClientProvider).auth.currentUser?.email ?? '',
                      style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
               const SizedBox(height: 32),

              // --- THÊM MỚI: Phần thống kê ---
              _buildStatsSection(context, profile: profile),

              const SizedBox(height: 16),
              const Divider(),
              
              // --- Phần Cài đặt và Đăng xuất ---
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Cài đặt'),
                onTap: () { 
                  // TODO: Điều hướng đến trang cài đặt
                },
              ),
              ListTile(
                leading: Icon(Icons.logout, color: colorScheme.error),
                title: Text('Đăng xuất', style: TextStyle(color: colorScheme.error)),
                onTap: () async {
                  await ref.read(profileRepositoryProvider).signOut();
                },
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Lỗi tải hồ sơ: $err')),
      ),
    );
  }

  // THÊM MỚI: Widget xây dựng khu vực thống kê
  Widget _buildStatsSection(BuildContext context, {required dynamic profile}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(context, count: profile.bookmarkedStoriesCount, label: 'Theo dõi'),
        _buildStatItem(context, count: profile.commentsCount, label: 'Bình luận'),
        _buildStatItem(context, count: profile.reviewsCount, label: 'Đánh giá'),
      ],
    );
  }
  
  // THÊM MỚI: Widget cho một mục thống kê
  Widget _buildStatItem(BuildContext context, {required int count, required String label}) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          count.toString(),
          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

