import 'dart:ui';
import 'package:comicsapp/features/auth/domain/entities/profile.dart';
import 'package:comicsapp/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

class HomeSliverAppBar extends StatelessWidget {
  const HomeSliverAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // SỬA ĐỔI: Sử dụng Consumer để có thể truy cập WidgetRef
    return Consumer(
      builder: (context, ref, child) {
        // Lắng nghe provider profile đã được hợp nhất
        final userProfileAsync = ref.watch(userProfileProvider);

        return SliverAppBar(
          pinned: true,
          expandedHeight: 180.0,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: const [StretchMode.zoomBackground, StretchMode.fadeTitle],
            background: _buildExpandedBackground(context, userProfileAsync),
          ),
          // Các action khác không đổi
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.search_rounded, size: 28, color: theme.colorScheme.onBackground),
            ),
            const SizedBox(width: 8),
          ],
        );
      },
    );
  }

  // SỬA ĐỔI: Xử lý trạng thái loading/error cho phần background mở rộng
  Widget _buildExpandedBackground(BuildContext context, AsyncValue<Profile?> userProfileAsync) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: userProfileAsync.when(
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
          // THÊM MỚI: Hiển thị Shimmer khi đang tải
          loading: () => [
            Shimmer.fromColors(
              baseColor: Colors.grey.withOpacity(0.3),
              highlightColor: Colors.grey.withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 20, width: 120, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 30, width: 200, color: Colors.white),
                ],
              ),
            ),
          ],
          // THÊM MỚI: Hiển thị placeholder khi có lỗi
          error: (e, s) => [
             Text(
              "HI,",
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            Text(
              'ComicsApp',
              style: theme.textTheme.headlineLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

