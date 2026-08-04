import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/blog_models.dart';
import 'media_gallery.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    this.canManage = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final BlogPost post;
  final bool canManage;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor}y';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor}mo';
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authorName = post.author?.displayName ?? 'Anonymous';
    final imageCount = post.images.length;

    return Card(
      child: InkWell(
        onTap: onTap ?? () => context.push('/posts/${post.id}'),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: theme.colorScheme.secondary.withAlpha(25),
                    child: Text(
                      authorName.isNotEmpty ? authorName[0].toUpperCase() : '?',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authorName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              _timeAgo(post.createdAt),
                              style: theme.textTheme.bodySmall,
                            ),
                            if (imageCount > 0) ...[
                              const SizedBox(width: 4),
                              Text(
                                '· $imageCount photo${imageCount > 1 ? 's' : ''}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (canManage)
                    SizedBox(
                      width: 40,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_horiz, size: 20),
                          onSelected: (value) {
                            if (value == 'edit') onEdit?.call();
                            if (value == 'delete') onDelete?.call();
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 14),

              Text(
                post.title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                post.excerpt.isEmpty ? post.content : post.excerpt,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),

              if (post.images.isNotEmpty) ...[
                const SizedBox(height: 14),
                SizedBox(
                  height: 180,
                  child: MediaGallery(
                    images: post.images,
                    compact: false,
                    parentLabel: post.title,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
