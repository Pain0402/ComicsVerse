import 'dart:ui';
import 'package:comicsapp/features/home/domain/entities/chapter.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// BottomSheet hiển thị danh sách tất cả các chương của một truyện.
class ChapterListBottomSheet extends StatelessWidget {
  final String storyId;
  final String storyTitle;
  final List<Chapter> allChapters;
  final Chapter currentChapter;

  const ChapterListBottomSheet({
    super.key,
    required this.storyId,
    required this.storyTitle,
    required this.allChapters,
    required this.currentChapter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          color: theme.colorScheme.background.withOpacity(0.7),
          child: Column(
            children: [
              // Thanh tiêu đề và drag handle
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Danh sách chương (${allChapters.length})',
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              const Divider(height: 1),
              // Danh sách chương có thể cuộn
              Expanded(
                child: ListView.builder(
                  itemCount: allChapters.length,
                  itemBuilder: (context, index) {
                    final chapter = allChapters[index];
                    final isCurrent = chapter.chapterId == currentChapter.chapterId;
                    return ListTile(
                      // Đánh dấu chương hiện tại
                      selected: isCurrent,
                      selectedTileColor: theme.colorScheme.primary.withOpacity(0.2),
                      leading: isCurrent ? Icon(Icons.play_arrow_rounded, color: theme.colorScheme.primary) : null,
                      title: Text(
                        'Chương ${chapter.chapterNumber}: ${chapter.title}',
                        style: TextStyle(
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCurrent ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                        ),
                      ),
                      trailing: chapter.isVip ? Icon(Icons.lock_outline_rounded, color: theme.colorScheme.secondary, size: 20) : null,
                      onTap: () {
                        // Nếu không phải chương hiện tại thì mới điều hướng
                        if (!isCurrent) {
                          // Sử dụng pushReplacement để thay thế màn hình đọc hiện tại
                          // bằng màn hình đọc của chương mới, tránh việc back lại chương cũ.
                          context.pushReplacement(
                            '/story/$storyId/chapter/${chapter.chapterId}',
                            extra: {
                              'storyTitle': storyTitle,
                              'chapter': chapter,
                              'allChapters': allChapters,
                            },
                          );
                        } else {
                          // Nếu là chương hiện tại, chỉ cần đóng bottom sheet
                          context.pop();
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
