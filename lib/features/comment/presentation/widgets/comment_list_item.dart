import 'package:cached_network_image/cached_network_image.dart';
import 'package:comicsapp/features/comment/domain/entities/comment_entity.dart';
import 'package:flutter/material.dart';

/// Widget để hiển thị một mục bình luận.
class CommentListItem extends StatelessWidget {
  final CommentEntity comment;

  const CommentListItem({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar người dùng
          CircleAvatar(
            radius: 20,
            backgroundColor: theme.colorScheme.surfaceVariant,
            backgroundImage: comment.author.avatarUrl != null
                ? CachedNetworkImageProvider(comment.author.avatarUrl!)
                : null,
            child: comment.author.avatarUrl == null
                ? const Icon(Icons.person)
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
                      // Format thời gian cho dễ đọc, ví dụ: "5 phút trước"
                      // Tạm thời hiển thị đơn giản
                      '• ${comment.createdAt.hour}:${comment.createdAt.minute}',
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
                Text(
                  'Trả lời',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
