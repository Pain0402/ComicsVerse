import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:comicsapp/features/home/domain/entities/story.dart';
import 'package:comicsapp/features/home/domain/entities/story_details.dart';
import 'package:comicsapp/features/home/presentation/providers/home_providers.dart';
import 'package:comicsapp/features/home/presentation/widgets/story_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

// Provider để lấy dữ liệu chi tiết truyện, sử dụng .family để truyền storyId vào
final storyDetailsProvider =
    FutureProvider.autoDispose.family<StoryDetails, String>((ref, storyId) {
  final storyRepository = ref.watch(storyRepositoryProvider);
  return storyRepository.getStoryDetails(storyId);
});

class StoryDetailsScreen extends ConsumerWidget {
  final String storyId;
  final Story? story; // Nhận story ban đầu để dùng cho Hero Animation

  const StoryDetailsScreen({super.key, required this.storyId, this.story});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storyDetailsAsync = ref.watch(storyDetailsProvider(storyId));
    final theme = Theme.of(context);

    return Scaffold(
      body: storyDetailsAsync.when(
        data: (details) => _buildContent(context, theme, details),
        loading: () => _buildLoadingSkeleton(context, theme),
        error: (error, stack) => Center(child: Text('Lỗi: $error')),
      ),
    );
  }

  // Giao diện chính khi đã có dữ liệu
  Widget _buildContent(BuildContext context, ThemeData theme, StoryDetails details) {
    final imageUrl = resolveImageUrl(details.story.coverImageUrl);
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context, theme, details.story, imageUrl),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  details.story.title,
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontFamily: 'BebasNeue',
                    color: theme.colorScheme.onBackground
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tác giả: ${details.story.author.displayName}',
                  style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                _buildActionButtons(theme),
                const SizedBox(height: 24),
                Text('Tóm tắt', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  details.story.synopsis ?? 'Chưa có tóm tắt.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
         SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text('Danh sách chương (${details.chapters.length})', style: theme.textTheme.headlineMedium),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final chapter = details.chapters[index];
              return ListTile(
                leading: Text(
                  '#${chapter.chapterNumber}',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                title: Text(chapter.title),
                trailing: chapter.isVip ? Icon(Icons.lock, color: Colors.amber, size: 18) : null,
                onTap: () {
                  // TODO: Điều hướng đến màn hình đọc truyện
                },
              );
            },
            childCount: details.chapters.length,
          ),
        ),
      ],
    );
  }
  
  // Các nút hành động chính
  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: const Text('Đọc từ đầu'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: theme.textTheme.bodyLarge
            ),
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.bookmark_add_outlined),
          iconSize: 32,
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.share_outlined),
          iconSize: 32,
          onPressed: () {},
        ),
      ],
    );
  }

  // Giao diện AppBar co dãn
  Widget _buildSliverAppBar(BuildContext context, ThemeData theme, Story storyData, String? imageUrl) {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height * 0.4,
      pinned: true,
      stretch: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl != null)
              // Hero widget để tạo animation
              Hero(
                tag: 'story-cover-${storyData.storyId}',
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            // Lớp phủ gradient để làm nổi bật tiêu đề
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    theme.scaffoldBackgroundColor.withOpacity(0.2),
                    theme.scaffoldBackgroundColor,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            // Hiệu ứng kính mờ cho thanh trạng thái
             ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    color: Colors.black.withOpacity(0.1),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Giao diện Shimmer khi đang tải
  Widget _buildLoadingSkeleton(BuildContext context, ThemeData theme) {
    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surface.withOpacity(0.5),
      highlightColor: theme.colorScheme.surface,
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.4,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(color: Colors.grey),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 40, width: 250, color: Colors.grey),
                  const SizedBox(height: 12),
                  Container(height: 20, width: 150, color: Colors.grey),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: Container(height: 50, color: Colors.grey)),
                      const SizedBox(width: 16),
                      Container(width: 50, height: 50, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(height: 24, width: 120, color: Colors.grey),
                  const SizedBox(height: 12),
                  Container(height: 16, color: Colors.grey),
                  const SizedBox(height: 8),
                  Container(height: 16, color: Colors.grey),
                  const SizedBox(height: 8),
                  Container(height: 16, width: 200, color: Colors.grey),
                  const SizedBox(height: 24),
                  Container(height: 24, width: 180, color: Colors.grey),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => ListTile(
                leading: Container(width: 40, height: 20, color: Colors.grey),
                title: Container(height: 20, color: Colors.grey),
              ),
              childCount: 5,
            ),
          ),
        ],
      ),
    );
  }
}
