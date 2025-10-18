import 'package:cached_network_image/cached_network_image.dart';
import 'package:comicsapp/features/comment/domain/entities/comment_entity.dart';
import 'package:flutter/material.dart';

// THÊM MỚI: Hàm tiện ích để định dạng thời gian tương đối
String timeAgo(DateTime date) {
  final duration = DateTime.now().difference(date);
  if (duration.inDays > 365) {
    return '${(duration.inDays / 365).floor()} năm trước';
  } else if (duration.inDays > 30) {
    return '${(duration.inDays / 30).floor()} tháng trước';
  } else if (duration.inDays > 0) {
    return '${duration.inDays} ngày trước';
  } else if (duration.inHours > 0) {
    return '${duration.inHours} giờ trước';
  } else if (duration.inMinutes > 0) {
    return '${duration.inMinutes} phút trước';
  } else {
    return 'Vừa xong';
  }
}


/// Widget để hiển thị một mục bình luận.
class CommentListItem extends StatelessWidget {
  final CommentEntity comment;
  final Function(CommentEntity) onReply; // THÊM MỚI: Callback cho nút trả lời
  final int depth; // THÊM MỚI: Để xác định độ sâu của bình luận

  const CommentListItem({
    super.key,
    required this.comment,
    required this.onReply,
    this.depth = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isReply = depth > 0;

    return Padding(
      // Thụt vào cho các bình luận trả lời
      padding: EdgeInsets.only(left: isReply ? 36.0 : 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar người dùng
                CircleAvatar(
                  radius: isReply ? 16 : 20, // Avatar nhỏ hơn cho trả lời
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  backgroundImage: comment.author.avatarUrl != null
                      ? CachedNetworkImageProvider(comment.author.avatarUrl!)
                      : null,
                  child: comment.author.avatarUrl == null
                      ? Icon(Icons.person, size: isReply ? 16 : 20)
                      : null,
                ),
                const SizedBox(width: 12),
                // Nội dung bình luận
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            comment.author.displayName ?? 'Người dùng',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            // SỬ DỤNG HÀM MỚI
                            '• ${timeAgo(comment.createdAt)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        comment.content,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      // CẬP NHẬT: Nút trả lời
                      GestureDetector(
                        onTap: () => onReply(comment),
                        child: Text(
                          'Trả lời',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // THÊM MỚI: Hiển thị danh sách các bình luận trả lời
          if (comment.replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                children: comment.replies
                    .map((reply) => CommentListItem(
                          comment: reply,
                          onReply: onReply,
                          depth: depth + 1,
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

