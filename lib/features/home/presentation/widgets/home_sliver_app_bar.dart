import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comicsapp/features/auth/domain/entities/profile.dart';
// THÊM MỚI: Import provider từ feature profile
import 'package:comicsapp/features/profile/presentation/providers/profile_providers.dart';

class HomeSliverAppBar extends ConsumerWidget { // SỬA: Chuyển thành ConsumerWidget
  // BỎ DÒNG NÀY: final AsyncValue<Profile?> userProfile;
  const HomeSliverAppBar({super.key}); // SỬA: Bỏ tham số userProfile

  @override
  Widget build(BuildContext context, WidgetRef ref) { // SỬA: Thêm WidgetRef
    // THÊM MỚI: Lấy userProfile từ provider chung
    final userProfile = ref.watch(userProfileProvider);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    final ValueNotifier<bool> isScrolledNotifier = ValueNotifier(false);

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        final scroll = scrollNotification.metrics.pixels;
        if (scroll > 130) {
          if (!isScrolledNotifier.value) {
            isScrolledNotifier.value = true;
          }
        } else {
          if (isScrolledNotifier.value) {
            isScrolledNotifier.value = false;
          }
        }
        return true;
      },
      child: SliverAppBar(
        pinned: true,
        expandedHeight: 180.0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.search_rounded, size: 28, color: theme.colorScheme.onBackground),
          ),
          const SizedBox(width: 8),
        ],
        flexibleSpace: ValueListenableBuilder<bool>(
          valueListenable: isScrolledNotifier,
          builder: (context, isScrolled, child) {
            return ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: isScrolled ? 10 : 0, sigmaY: isScrolled ? 10 : 0),
                child: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: isScrolled
                      ? _buildCollapsedTitle(userProfile, theme)
                      : null,
                  background: _buildExpandedBackground(userProfile, theme),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildExpandedBackground(AsyncValue<Profile?> userProfile, ThemeData theme) {
    // ... nội dung hàm không đổi
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: userProfile.when(
          data: (profile) => [
            Text(
              "Chào buổi sáng,",
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            Text(
              profile?.displayName ?? 'Guest',
              style: theme.textTheme.headlineLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          loading: () => [
            Container(height: 20, width: 120, color: Colors.grey.withOpacity(0.3)),
            const SizedBox(height: 8),
            Container(height: 30, width: 200, color: Colors.grey.withOpacity(0.3)),
          ],
          error: (e, s) => [const Text('Error')],
        ),
      ),
    );
  }

  Widget _buildCollapsedTitle(AsyncValue<Profile?> userProfile, ThemeData theme) {
    // ... nội dung hàm không đổi
    return Row(
      children: userProfile.when(
        data: (profile) => [
          CircleAvatar(
            radius: 16,
            backgroundColor: theme.colorScheme.surface,
            backgroundImage: (profile?.avatarUrl != null)
                ? NetworkImage(profile!.avatarUrl!)
                : null,
            child: (profile?.avatarUrl == null)
                ? const Icon(Icons.person, size: 18)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              profile?.displayName ?? 'Guest',
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        loading: () => [Container(height: 20, width: 100, color: Colors.grey.withOpacity(0.3))],
        error: (e, s) => [const Text('Error')],
      ),
    );
  }
}
