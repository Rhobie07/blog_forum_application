import 'package:flutter/material.dart';
import '../models/blog_models.dart';
import 'blog_post_list.dart';

class BlogFeed extends StatefulWidget {
  const BlogFeed({
    super.key,
    this.posts = const [],
    this.isSignedIn = false,
    this.currentUserId,
    this.isBusy = false,
    this.loading = false,
    this.error,
    this.searchQuery = '',
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
  final bool isSignedIn;
  final String? currentUserId;
  final bool isBusy;
  final bool loading;
  final String? error;
  final String searchQuery;
  final VoidCallback? onCreate;
  final ValueChanged<BlogPost>? onEdit;
  final ValueChanged<BlogPost>? onDelete;
  final ValueChanged<BlogPost>? onOpen;
  final int currentPage;
  final int totalPages;
  final ValueChanged<int>? onPageChanged;
  final VoidCallback? onRetry;

  @override
  State<BlogFeed> createState() => _BlogFeedState();
}

class _BlogFeedState extends State<BlogFeed> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.searchQuery,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant BlogFeed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != _controller.text) {
      _controller.text = widget.searchQuery;
    }
  }

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
                  if (widget.onCreate != null) ...[
                    const SizedBox(width: 10),
                    FilledButton.icon(
                      onPressed: widget.isBusy ? null : widget.onCreate,
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

        if (widget.error != null && widget.posts.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              widget.error!,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),

        if (widget.isBusy) const LinearProgressIndicator(),
      ],
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (widget.loading && widget.posts.isEmpty) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (widget.error != null && widget.posts.isEmpty) {
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
                widget.error!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              if (widget.onRetry != null) ...[
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: widget.onRetry,
                  child: const Text('Try again'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (widget.posts.isEmpty && widget.totalPages == 0) {
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
              Text(
                widget.searchQuery.isNotEmpty
                    ? 'No posts match your search'
                    : 'No posts yet',
                style: theme.textTheme.bodyMedium,
              ),
              if (widget.onCreate != null && widget.searchQuery.isEmpty) ...[
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: widget.onCreate,
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
      posts: widget.posts,
      currentUserId: widget.currentUserId,
      onTap: widget.onOpen,
      onEdit: widget.onEdit,
      onDelete: widget.onDelete,
      currentPage: widget.currentPage,
      totalPages: widget.totalPages,
      onPageChanged: widget.onPageChanged,
    );
  }
}
