import 'package:flutter/material.dart';
import '../models/blog_models.dart';
import 'blog_post_list.dart';

class BlogFeed extends StatelessWidget {
  const BlogFeed({
    super.key,
    this.posts = const [],
    this.currentUserId,
    this.isBusy = false,
    this.loading = false,
    this.error,
    this.onCreate,
    this.onEdit,
    this.onDelete,
    this.onOpen,
    this.currentPage = 1,
    this.totalPages = 0,
    this.onPageChanged,
    this.onRetry,
  });

  final List<BlogPost> posts;
  final String? currentUserId;
  final bool isBusy;
  final bool loading;
  final String? error;
  final VoidCallback? onCreate;
  final ValueChanged<BlogPost>? onEdit;
  final ValueChanged<BlogPost>? onDelete;
  final ValueChanged<BlogPost>? onOpen;
  final int currentPage;
  final int totalPages;
  final ValueChanged<int>? onPageChanged;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 500;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (onCreate != null) ...[
                    const SizedBox(width: 10),
                    FilledButton.icon(
                      onPressed: isBusy ? null : onCreate,
                      icon: const Icon(Icons.add, size: 18),
                      label: Text(narrow ? '' : 'New post'),
                    ),
                  ],
                ],
              );
            },
          ),
        ),

        Expanded(child: _buildBody(theme)),

        if (error != null && posts.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),

        if (isBusy) const LinearProgressIndicator(),
      ],
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (loading && posts.isEmpty) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (error != null && posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 40,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                error!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: onRetry,
                  child: const Text('Try again'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (posts.isEmpty && totalPages == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.article_outlined,
                size: 40,
                color: theme.colorScheme.secondary.withAlpha(80),
              ),
              const SizedBox(height: 12),
              Text('No posts yet', style: theme.textTheme.bodyMedium),
              if (onCreate != null) ...[
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onCreate,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Create the first post'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return BlogPostList(
      posts: posts,
      currentUserId: currentUserId,
      onTap: onOpen,
      onEdit: onEdit,
      onDelete: onDelete,
      currentPage: currentPage,
      totalPages: totalPages,
      onPageChanged: onPageChanged,
    );
  }
}
