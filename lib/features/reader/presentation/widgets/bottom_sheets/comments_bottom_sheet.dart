import 'dart:ui';
import 'package:comicsapp/features/comment/domain/entities/comment_entity.dart';
import 'package:comicsapp/features/comment/presentation/providers/comment_providers.dart';
import 'package:comicsapp/features/comment/presentation/widgets/comment_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

/// BottomSheet hiển thị khu vực bình luận đã được nâng cấp.
class CommentsBottomSheet extends ConsumerStatefulWidget {
  final String chapterId;
  const CommentsBottomSheet({super.key, required this.chapterId});

  @override
  ConsumerState<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends ConsumerState<CommentsBottomSheet> {
  final _commentController = TextEditingController();
  // State để lưu thông tin bình luận đang được trả lời
  CommentEntity? _replyingToComment;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _postComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    await ref.read(commentPostControllerProvider.notifier).postComment(
          content: content,
          chapterId: widget.chapterId,
          // Gửi kèm parent_id nếu đang trả lời bình luận
          parentCommentId: _replyingToComment?.id,
        );
    
    // Sau khi gửi, xóa nội dung trong text field và reset trạng thái trả lời
    if (mounted) {
      _commentController.clear();
      setState(() {
        _replyingToComment = null;
      });
      // Ẩn bàn phím
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // CẬP NHẬT: Sử dụng nestedCommentsProvider để lấy dữ liệu dạng cây
    final comments = ref.watch(nestedCommentsProvider(widget.chapterId));
    // Vẫn lắng nghe stream provider gốc để biết trạng thái loading/error ban đầu
    final commentsAsync = ref.watch(commentsStreamProvider(widget.chapterId));

    final isPosting = ref.watch(commentPostControllerProvider).isLoading;

    ref.listen(commentPostControllerProvider, (_, state) {
      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi gửi bình luận: ${state.error}'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    });

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          color: theme.colorScheme.background.withOpacity(0.7),
          child: Column(
            children: [
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
                  'Bình luận',
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: commentsAsync.when(
                  loading: () => _buildLoadingSkeleton(),
                  error: (err, stack) => Center(child: Text('Lỗi tải bình luận: $err')),
                  data: (_) { // Dữ liệu từ stream gốc chỉ dùng để trigger, dữ liệu thật lấy từ provider 'comments'
                    if (comments.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded, size: 60, color: theme.colorScheme.onSurfaceVariant),
                            const SizedBox(height: 16),
                            Text('Hãy là người đầu tiên bình luận!', style: theme.textTheme.bodyLarge),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        return CommentListItem(
                          comment: comments[index],
                          // Callback để set trạng thái đang trả lời
                          onReply: (commentToReply) {
                            setState(() {
                              _replyingToComment = commentToReply;
                            });
                            FocusScope.of(context).requestFocus(); // Focus vào text field
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              // Giao diện nhập liệu
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Hiển thị thông báo khi đang trả lời ai đó
                      if (_replyingToComment != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Đang trả lời @${_replyingToComment!.author.displayName ?? '...'}',
                                style: theme.textTheme.bodySmall,
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                onPressed: () {
                                  setState(() {
                                    _replyingToComment = null;
                                  });
                                },
                              )
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: 'Viết bình luận...',
                            filled: true,
                            fillColor: theme.colorScheme.surface.withOpacity(0.8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: isPosting 
                              ? const Padding(padding: EdgeInsets.all(12.0), child: CircularProgressIndicator(strokeWidth: 2))
                              : IconButton(
                                  icon: Icon(Icons.send_rounded, color: theme.colorScheme.primary),
                                  onPressed: _postComment,
                                ),
                          ),
                          onSubmitted: (_) => _postComment(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.withOpacity(0.1),
      highlightColor: Colors.grey.withOpacity(0.2),
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(radius: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 16, width: 100, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(height: 32, width: double.infinity, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

