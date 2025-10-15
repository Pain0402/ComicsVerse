import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:comicsapp/features/home/domain/entities/story.dart';
import 'package:comicsapp/features/home/domain/entities/story_details.dart';
import 'package:comicsapp/features/home/presentation/providers/home_providers.dart';
import 'package:comicsapp/features/home/presentation/widgets/story_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:comicsapp/features/home/domain/entities/chapter.dart';
import 'package:comicsapp/features/library/presentation/providers/library_providers.dart';
import 'package:comicsapp/features/profile/presentation/providers/profile_providers.dart';

// Provider để lấy dữ liệu chi tiết truyện, sử dụng .family để truyền storyId vào
final storyDetailsProvider =
    FutureProvider.autoDispose.family<StoryDetails, String>((ref, storyId) {
  final storyRepository = ref.watch(storyRepositoryProvider);
  return storyRepository.getStoryDetails(storyId);
});

class StoryDetailsScreen extends StatefulWidget {
  final String storyId;
  final Story? story; // Story object được truyền từ trang trước

  const StoryDetailsScreen({
    super.key,
    required this.storyId,
    this.story,
  });

  @override
  State<StoryDetailsScreen> createState() => _StoryDetailsScreenState();
}

class _StoryDetailsScreenState extends State<StoryDetailsScreen> {
  bool _isSynopsisExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final storyDetailsAsync = ref.watch(storyDetailsProvider(widget.storyId));
        final theme = Theme.of(context);

        return Scaffold(
          body: storyDetailsAsync.when(
            loading: () => _buildLoadingSkeleton(context),
            error: (err, stack) => Center(child: Text('Lỗi tải chi tiết truyện: $err')),
            data: (details) {
              final story = details.story;
              final chapters = details.chapters ?? [];
              final imageUrl = resolveImageUrl(story.coverImageUrl);

              return CustomScrollView(
                slivers: [
                  _buildSliverAppBar(context, story, imageUrl),
                  _buildHeaderSection(context, story),
                  _buildActionButtons(context, ref, story), // Sửa đổi hàm này
                  _buildSynopsisSection(context, story), // Widget mới cho tóm tắt
                  _buildChapterListHeader(context, chapters.length),
                  _buildChapterList(chapters),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // ... _buildLoadingSkeleton, _buildSliverAppBar, _buildHeaderSection không đổi ...
  Widget _buildLoadingSkeleton(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDarkMode ? Colors.grey[850]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[800]! : Colors.grey[100]!,
      child: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(expandedHeight: MediaQuery.of(context).size.height * 0.4, flexibleSpace: Container(color: Colors.white)),
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(16.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(height: 30, width: 250, color: Colors.white), const SizedBox(height: 8), Container(height: 20, width: 150, color: Colors.white)]))),
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), child: Row(children: [Expanded(child: Container(height: 48, color: Colors.white)), const SizedBox(width: 12), Container(width: 48, height: 48, color: Colors.white)]))),
        ],
      ),
    );
  }

  // Widget _buildSliverAppBar(BuildContext context, Story story, String? imageUrl) {
  //   return SliverAppBar(
  //     expandedHeight: MediaQuery.of(context).size.height * 0.4,
  //     pinned: true,
  //     stretch: true,
  //     backgroundColor: Colors.transparent,
  //     flexibleSpace: FlexibleSpaceBar(
  //       stretchModes: const [StretchMode.zoomBackground, StretchMode.fadeTitle],
  //       background: imageUrl != null
  //           ? Hero(
  //               tag: 'story-cover-${story.storyId}',
  //               child: CachedNetworkImage(
  //                 imageUrl: imageUrl,
  //                 fit: BoxFit.cover,
  //                 placeholder: (context, url) => Container(color: Theme.of(context).colorScheme.surfaceVariant),
  //                 errorWidget: (context, url, error) => const Icon(Icons.error),
  //               ),
  //             )
  //           : Container(color: Theme.of(context).colorScheme.surfaceVariant),
  //       title: ClipRRect(
  //         child: BackdropFilter(
  //           filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
  //           child: Padding(
  //             padding: const EdgeInsets.all(4.0),
  //             child: Text(
  //               story.title,
  //               style: const TextStyle(fontSize: 16, shadows: [Shadow(blurRadius: 2)]),
  //             ),
  //           ),
  //         ),
  //       ),
  //       centerTitle: true,
  //     ),
  //   );
  // }
  Widget _buildSliverAppBar(BuildContext context, Story story, String? imageUrl) {
  final bg = Theme.of(context).scaffoldBackgroundColor;

  return SliverAppBar(
    expandedHeight: MediaQuery.of(context).size.height * 0.42,
    pinned: true,
    stretch: true,
    elevation: 0,
    backgroundColor: Colors.transparent,
    flexibleSpace: FlexibleSpaceBar(
      stretchModes: const [StretchMode.zoomBackground, StretchMode.fadeTitle],
      centerTitle: true,
      title: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              story.title,
              style: const TextStyle(fontSize: 16, shadows: [Shadow(blurRadius: 2)]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
      background: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl != null)
            Hero(
              tag: 'story-cover-${story.storyId}',
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(color: Theme.of(context).colorScheme.surfaceVariant),

          // Lớp gradient làm mờ dần xuống nền
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.65, 0.85, 1.0],
                  colors: [
                    Colors.transparent,
                    bg.withOpacity(0.0),
                    bg, // hòa vào nền (đen/trắng tùy theme)
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
  
  Widget _buildHeaderSection(BuildContext context, Story story) {
    final theme = Theme.of(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              story.title,
              style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  story.author.displayName ?? 'Unknown Author',
                  style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.star_rate_rounded, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(
                  story.averageRating.toStringAsFixed(1),
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // SỬA ĐỔI HOÀN TOÀN: Tái cấu trúc khu vực hành động
  Widget _buildActionButtons(BuildContext context, WidgetRef ref, Story story) {
    final theme = Theme.of(context);
    final isBookmarkedAsync = ref.watch(isBookmarkedProvider(story.storyId));

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () { /* TODO: Navigate to first chapter */ },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Đọc ngay'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Nút Bookmark (chỉ icon)
            isBookmarkedAsync.when(
              data: (isBookmarked) => IconButton(
                onPressed: () {
                  ref.read(isBookmarkedProvider(story.storyId).notifier).toggleBookmark();
                  ref.invalidate(bookmarkedStoriesProvider);
                  ref.invalidate(userProfileProvider);
                },
                icon: Icon(isBookmarked ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined),
                color: theme.colorScheme.primary,
                iconSize: 28,
                tooltip: isBookmarked ? 'Xóa khỏi tủ truyện' : 'Thêm vào tủ truyện',
              ),
              loading: () => const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2)),
              error: (e, st) => IconButton(onPressed: null, icon: const Icon(Icons.error_outline), iconSize: 28),
            ),
            // Nút Chia sẻ (placeholder)
            IconButton(
              onPressed: () { /* TODO: Implement share functionality */ },
              icon: const Icon(Icons.share_outlined),
              color: theme.colorScheme.onSurfaceVariant,
              iconSize: 28,
              tooltip: 'Chia sẻ',
            ),
            // Nút Đánh giá (placeholder)
            IconButton(
              onPressed: () { /* TODO: Implement review functionality */ },
              icon: const Icon(Icons.star_outline_rounded),
              color: theme.colorScheme.onSurfaceVariant,
              iconSize: 28,
              tooltip: 'Đánh giá',
            ),
          ],
        ),
      ),
    );
  }

  // TẠO MỚI: Widget cho phần tóm tắt có thể mở rộng
  Widget _buildSynopsisSection(BuildContext context, Story story) {
    final theme = Theme.of(context);
    if (story.synopsis == null || story.synopsis!.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tóm tắt', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Text(
                story.synopsis!,
                maxLines: _isSynopsisExpanded ? null : 3,
                overflow: _isSynopsisExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isSynopsisExpanded = !_isSynopsisExpanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  _isSynopsisExpanded ? 'Thu gọn' : 'Xem thêm',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // ... _buildChapterListHeader và _buildChapterList không đổi ...
  Widget _buildChapterListHeader(BuildContext context, int chapterCount) {
    final theme = Theme.of(context);
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Danh sách chương ($chapterCount)', style: theme.textTheme.headlineSmall),
            IconButton(onPressed: () {}, icon: const Icon(Icons.sort)),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterList(List<Chapter> chapters) {
    if (chapters.isEmpty) {
      return const SliverFillRemaining(child: Center(child: Text('Chưa có chương nào.')));
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return ChapterListItem(chapter: chapters[index]);
        },
        childCount: chapters.length,
      ),
    );
  }
}

// ... class ChapterListItem không đổi ...
class ChapterListItem extends StatelessWidget {
  final Chapter chapter;
  const ChapterListItem({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: () {},
      title: Text('Chương ${chapter.chapterNumber}: ${chapter.title}'),
      subtitle: Text('Cập nhật: ${chapter.releaseDate.toLocal().toString().split(' ')[0]}'),
      trailing: chapter.isVip ? Icon(Icons.lock_outline_rounded, color: theme.colorScheme.secondary) : null,
    );
  }
}





