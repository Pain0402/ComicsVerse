import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comicsapp/features/auth/domain/entities/profile.dart';

class HomeSliverAppBar extends StatefulWidget {
  final AsyncValue<Profile?> userProfile;
  const HomeSliverAppBar({super.key, required this.userProfile});

  @override
  State<HomeSliverAppBar> createState() => _HomeSliverAppBarState();
}

class _HomeSliverAppBarState extends State<HomeSliverAppBar> {
  final ValueNotifier<bool> isScrolledNotifier = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
            // Sử dụng Stack để đặt BackdropFilter đúng vị trí
            return Stack(
              children: [
                // Lớp nền mờ
                Positioned.fill(
                  child: ClipRRect(
                    child: BackdropFilter(
                      filter: isScrolled
                          ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
                          : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        color: isScrolled
                            ? theme.colorScheme.background.withOpacity(0.5)
                            : Colors.transparent,
                      ),
                    ),
                  ),
                ),
                // Lớp nội dung (FlexibleSpaceBar)
                FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: isScrolled
                      ? _buildCollapsedTitle(widget.userProfile, theme)
                      : null,
                  background: _buildExpandedBackground(widget.userProfile, theme),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildExpandedBackground(AsyncValue<Profile?> userProfile, ThemeData theme) {
     // ... (Nội dung hàm này không thay đổi)
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
    // ... (Nội dung hàm này không thay đổi)
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

