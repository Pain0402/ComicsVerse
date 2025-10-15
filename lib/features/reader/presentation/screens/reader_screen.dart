import 'package:cached_network_image/cached_network_image.dart';
import 'package:comicsapp/features/home/domain/entities/chapter.dart';
import 'package:comicsapp/features/reader/presentation/providers/reader_providers.dart';
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

  const ReaderScreen({
    super.key,
    required this.storyId,
    required this.storyTitle,
    required this.chapter,
  });

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  // Trạng thái cục bộ của màn hình đọc
  bool _showControls = true; // Hiển thị thanh điều khiển
  ReadingMode _readingMode = ReadingMode.vertical; // Chế độ đọc mặc định

  @override
  Widget build(BuildContext context) {
    final chapterContentAsync = ref.watch(chapterContentProvider(widget.chapter.chapterId));
    final theme = Theme.of(context);

    return Scaffold(
      // Nền đen tuyền theo yêu cầu UI/UX
      backgroundColor: Colors.black,
      // extendBodyBehindAppBar và extendBody để nội dung tràn ra sau các thanh điều khiển
      extendBodyBehindAppBar: true,
      extendBody: true,
      // Ẩn/hiện AppBar dựa trên trạng thái _showControls
      appBar: _showControls
          ? ReaderAppBar(
              storyTitle: widget.storyTitle,
              chapterTitle: 'Chương ${widget.chapter.chapterNumber}: ${widget.chapter.title}',
              onSettingsTap: () {
                // TODO: Mở bottom sheet cài đặt (độ sáng, etc.)
              },
            )
          : null,
      body: GestureDetector(
        // Khi nhấn vào vùng nội dung, đảo ngược trạng thái hiển thị của các thanh điều khiển
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
            // Lựa chọn widget đọc dựa trên chế độ đã chọn
            return _readingMode == ReadingMode.vertical
                ? _buildVerticalReader(imageUrls)
                : _buildHorizontalReader(imageUrls);
          },
        ),
      ),
      // Ẩn/hiện BottomBar dựa trên trạng thái _showControls
      bottomNavigationBar: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        child: _showControls
            ? ReaderBottomBar(
                onChapterListTap: () {
                  // TODO: Mở bottom sheet danh sách chương
                },
                onCommentTap: () {
                  // TODO: Mở bottom sheet bình luận
                },
                onReadingModeTap: () {
                  // Thay đổi chế độ đọc
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

  /// Widget xây dựng trình đọc kiểu cuộn dọc (Webtoon)
  Widget _buildVerticalReader(List<String> imageUrls) {
    return ListView.builder(
      padding: EdgeInsets.zero, // Xóa padding mặc định của ListView
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return _buildChapterImage(imageUrls[index]);
      },
    );
  }

  /// Widget xây dựng trình đọc kiểu lật trang (Manga)
  Widget _buildHorizontalReader(List<String> imageUrls) {
    return PageView.builder(
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return _buildChapterImage(imageUrls[index]);
      },
    );
  }

  /// Widget hiển thị một ảnh của chương, có hỗ trợ zoom và placeholder
  Widget _buildChapterImage(String imageUrl) {
    return InteractiveViewer(
      minScale: 1.0,
      maxScale: 4.0,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.fitWidth,
        // Placeholder hiển thị trong khi tải ảnh
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.grey[900]!,
          highlightColor: Colors.grey[800]!,
          child: Container(
            // Giả lập chiều cao để Shimmer có kích thước hợp lý
            height: MediaQuery.of(context).size.height * 0.8,
            color: Colors.black,
          ),
        ),
        // Widget hiển thị khi có lỗi tải ảnh
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

  /// Widget hiển thị skeleton loading cho toàn màn hình
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
