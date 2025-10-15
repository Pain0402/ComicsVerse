import 'package:cached_network_image/cached_network_image.dart';
import 'package:comicsapp/features/home/domain/entities/chapter.dart';
import 'package:comicsapp/features/reader/presentation/providers/reader_providers.dart';
import 'package:comicsapp/features/reader/presentation/widgets/bottom_sheets/chapter_list_bottom_sheet.dart';
import 'package:comicsapp/features/reader/presentation/widgets/bottom_sheets/comments_bottom_sheet.dart';
import 'package:comicsapp/features/reader/presentation/widgets/bottom_sheets/reader_settings_bottom_sheet.dart';
import 'package:comicsapp/features/reader/presentation/widgets/reader_app_bar.dart';
import 'package:comicsapp/features/reader/presentation/widgets/reader_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

enum ReadingMode { vertical, horizontal }

class ReaderScreen extends ConsumerStatefulWidget {
  final String storyId;
  final String storyTitle;
  final Chapter chapter;
  final List<Chapter> allChapters; // THÊM MỚI: Nhận danh sách tất cả các chương

  const ReaderScreen({
    super.key,
    required this.storyId,
    required this.storyTitle,
    required this.chapter,
    required this.allChapters, // Yêu cầu tham số này
  });

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  bool _showControls = true;
  ReadingMode _readingMode = ReadingMode.vertical;

  // HÀM MỚI: Hàm chung để hiển thị BottomSheet với hiệu ứng Glassmorphism
  void _showGlassBottomSheet(BuildContext context, {required Widget child}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Quan trọng để hiệu ứng blur hoạt động
      isScrollControlled: true, // Cho phép bottom sheet chiếm nhiều không gian hơn
      builder: (context) => child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final chapterContentAsync = ref.watch(chapterContentProvider(widget.chapter.chapterId));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: _showControls
          ? ReaderAppBar(
              storyTitle: widget.storyTitle,
              chapterTitle: 'Chương ${widget.chapter.chapterNumber}: ${widget.chapter.title}',
              onSettingsTap: () {
                // CẬP NHẬT: Gọi hàm hiển thị bottom sheet cài đặt
                _showGlassBottomSheet(
                  context,
                  child: const ReaderSettingsBottomSheet(),
                );
              },
            )
          : null,
      body: GestureDetector(
        onTap: () => setState(() => _showControls = !_showControls),
        child: chapterContentAsync.when(
          loading: () => _buildLoadingSkeleton(),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Lỗi: ${error.toString()}',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (imageUrls) {
            if (imageUrls.isEmpty) {
              return const Center(
                child: Text(
                  'Chương này chưa có nội dung.',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }
            return _readingMode == ReadingMode.vertical
                ? _buildVerticalReader(imageUrls)
                : _buildHorizontalReader(imageUrls);
          },
        ),
      ),
      bottomNavigationBar: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        child: _showControls
            ? ReaderBottomBar(
                onChapterListTap: () {
                  // CẬP NHẬT: Gọi hàm hiển thị bottom sheet danh sách chương
                  _showGlassBottomSheet(
                    context,
                    child: ChapterListBottomSheet(
                      storyId: widget.storyId,
                      storyTitle: widget.storyTitle,
                      allChapters: widget.allChapters,
                      currentChapter: widget.chapter,
                    ),
                  );
                },
                onCommentTap: () {
                  // CẬP NHẬT: Gọi hàm hiển thị bottom sheet bình luận
                  _showGlassBottomSheet(
                    context,
                    child: CommentsBottomSheet(chapterId: widget.chapter.chapterId),
                  );
                },
                onReadingModeTap: () {
                  setState(() {
                    _readingMode = _readingMode == ReadingMode.vertical
                        ? ReadingMode.horizontal
                        : ReadingMode.vertical;
                  });
                },
                readingModeIcon: _readingMode == ReadingMode.vertical
                    ? Icons.swap_horiz_rounded
                    : Icons.swap_vert_rounded,
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  // ... các hàm build còn lại không đổi ...
  Widget _buildVerticalReader(List<String> imageUrls) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return _buildChapterImage(imageUrls[index]);
      },
    );
  }

  Widget _buildHorizontalReader(List<String> imageUrls) {
    return PageView.builder(
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return _buildChapterImage(imageUrls[index]);
      },
    );
  }

  Widget _buildChapterImage(String imageUrl) {
    return InteractiveViewer(
      minScale: 1.0,
      maxScale: 4.0,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.fitWidth,
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.grey[900]!,
          highlightColor: Colors.grey[800]!,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            color: Colors.black,
          ),
        ),
        errorWidget: (context, url, error) => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 50),
              SizedBox(height: 8),
              Text(
                'Không thể tải ảnh',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(
            3,
            (index) => Container(
                  height: MediaQuery.of(context).size.height,
                  color: Colors.black,
                  margin: const EdgeInsets.only(bottom: 8),
                )),
      ),
    );
  }
}

