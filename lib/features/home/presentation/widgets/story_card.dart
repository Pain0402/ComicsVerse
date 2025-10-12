import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:comicsapp/features/home/domain/entities/story.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Chuyển giá trị ảnh thành URL có thể dùng:
/// - Nếu đã là URL (http/https) → trả nguyên vẹn
/// - Nếu là path trong bucket 'stories' → tạo public URL
/// - Nếu null/empty → trả null
String? resolveImageUrl(String? value) {
  if (value == null || value.isEmpty) return null;
  if (value.startsWith('http')) return value;
  return Supabase.instance.client.storage.from('stories').getPublicUrl(value);
}

Color _baseShimmer(BuildContext ctx) =>
    Theme.of(ctx).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade300;

Color _highlightShimmer(BuildContext ctx) =>
    Theme.of(ctx).brightness == Brightness.dark
        ? Colors.grey.shade700
        : Colors.grey.shade100;

/// ------------------------------
/// Card dùng trong Grid "Dành Cho Bạn"
/// ------------------------------
class StoryCard extends StatelessWidget {
  final Story story;
  const StoryCard({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = resolveImageUrl(story.coverImageUrl);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      // Token mới trong M3 thay cho surfaceVariant (đã deprecated ở một số theme)
      color: theme.colorScheme.surfaceContainerHigh.withOpacity(0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ảnh chiếm ~60% chiều cao ô grid → ổn định, không overflow
          Flexible(
            flex: 6,
            fit: FlexFit.tight,
            child: imageUrl == null
                ? Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_outlined),
                  )
                : CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: _baseShimmer(context),
                      highlightColor: _highlightShimmer(context),
                      child: Container(color: Colors.white),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image_outlined),
                    ),
                  ),
          ),
          // Text chiếm ~40% còn lại
          Flexible(
            flex: 4,
            fit: FlexFit.tight,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Bọc trong Flexible để hạn chế chiều cao text khi font lớn
                  Flexible(
                    child: Text(
                      story.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      // Nếu có font BebasNeue thì mở comment
                      // style: theme.textTheme.headlineMedium?.copyWith(fontFamily: 'BebasNeue', letterSpacing: 1.1),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Chương 12', // TODO: bind chương mới nhất
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------
/// Card dùng trong Carousel "Bảng Xếp Hạng"
/// ------------------------------
class RankingStoryCard extends StatelessWidget {
  final Story story;
  final int rank;
  const RankingStoryCard({super.key, required this.story, required this.rank});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = resolveImageUrl(story.coverImageUrl);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.25),
            blurRadius: 24,
            spreadRadius: -8,
          ),
        ],
      ),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl == null)
              Container(
                color: theme.colorScheme.surfaceContainerHighest,
                alignment: Alignment.center,
                child: const Icon(Icons.image_outlined),
              )
            else
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: _baseShimmer(context),
                  highlightColor: _highlightShimmer(context),
                  child: Container(color: Colors.white),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.image_not_supported_rounded),
                ),
              ),

            // Gradient giúp chữ nổi bật
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.0),
                    Colors.black.withOpacity(0.85),
                  ],
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // Huy hiệu TOP
            Positioned(
              top: 12,
              left: 12,
              child: Chip(
                label: Text('TOP $rank'),
                backgroundColor: theme.colorScheme.secondary,
                labelStyle: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSecondary,
                ),
              ),
            ),

            // Tiêu đề
            Positioned(
              bottom: 12,
              left: 16,
              right: 16,
              child: Text(
                story.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                // Nếu có font BebasNeue thì mở comment
                // style: theme.textTheme.headlineMedium?.copyWith(
                //   fontFamily: 'BebasNeue',
                //   color: Colors.white,
                //   letterSpacing: 1.1,
                //   shadows: [Shadow(blurRadius: 4, color: Colors.black54, offset: Offset(0, 2))],
                // ),
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  letterSpacing: 1.1,
                  shadows: const [
                    Shadow(blurRadius: 4, color: Colors.black54, offset: Offset(0, 2)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
