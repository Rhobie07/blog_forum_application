import 'package:flutter/material.dart';
import '../models/blog_models.dart';
import 'post_card.dart';

class BlogPostList extends StatelessWidget {
  const BlogPostList({
    super.key,
    required this.posts,
    this.currentUserId,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.currentPage = 1,
    this.totalPages = 0,
    this.onPageChanged,
  });

  final List<BlogPost> posts;
  final String? currentUserId;
  final ValueChanged<BlogPost>? onTap;
  final ValueChanged<BlogPost>? onEdit;
  final ValueChanged<BlogPost>? onDelete;
  final int currentPage;
  final int totalPages;
  final ValueChanged<int>? onPageChanged;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: posts.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        if (index == posts.length) {
          return _PaginationBar(
            currentPage: currentPage,
            totalPages: totalPages,
            onPageChanged: onPageChanged,
          );
        }
        final post = posts[index];
        return PostCard(
          key: ValueKey(post.id),
          post: post,
          canManage: currentUserId != null && post.authorId == currentUserId,
          onTap: onTap == null ? null : () => onTap!(post),
          onEdit: onEdit == null ? null : () => onEdit!(post),
          onDelete: onDelete == null ? null : () => onDelete!(post),
        );
      },
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    this.onPageChanged,
  });

  final int currentPage;
  final int totalPages;
  final ValueChanged<int>? onPageChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (totalPages <= 1) return const SizedBox.shrink();

    final pages = _buildPageNumbers();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PageButton(
            icon: Icons.chevron_left,
            label: 'Previous',
            enabled: currentPage > 1,
            onTap: onPageChanged == null
                ? null
                : () => onPageChanged!(currentPage - 1),
          ),

          const SizedBox(width: 4),

          ...pages.map(
            (p) => p == -1
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text('...', style: theme.textTheme.bodySmall),
                  )
                : _PageNumber(
                    page: p,
                    selected: p == currentPage,
                    onTap: onPageChanged == null
                        ? null
                        : () => onPageChanged!(p),
                  ),
          ),

          const SizedBox(width: 4),

          _PageButton(
            icon: Icons.chevron_right,
            label: 'Next',
            enabled: currentPage < totalPages,
            onTap: onPageChanged == null
                ? null
                : () => onPageChanged!(currentPage + 1),
          ),
        ],
      ),
    );
  }

  List<int> _buildPageNumbers() {
    if (totalPages <= 7) {
      return List.generate(totalPages, (i) => i + 1);
    }

    final result = <int>{1, totalPages};

    final start = (currentPage - 2).clamp(1, totalPages);
    final end = (currentPage + 2).clamp(1, totalPages);
    for (var i = start; i <= end; i++) {
      result.add(i);
    }

    return _insertEllipses(result.toList()..sort());
  }

  List<int> _insertEllipses(List<int> pages) {
    final result = <int>[];
    for (var i = 0; i < pages.length; i++) {
      if (i > 0 && pages[i] - pages[i - 1] > 1) {
        result.add(-1);
      }
      result.add(pages[i]);
    }
    return result;
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.icon,
    required this.label,
    required this.enabled,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      onPressed: enabled ? onTap : null,
      icon: Icon(icon, size: 20),
      tooltip: label,
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        disabledForegroundColor: theme.colorScheme.secondary.withAlpha(50),
      ),
    );
  }
}

class _PageNumber extends StatelessWidget {
  const _PageNumber({required this.page, required this.selected, this.onTap});

  final int page;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: SizedBox(
        width: 32,
        height: 32,
        child: Material(
          color: selected
              ? theme.colorScheme.primary
              : theme.colorScheme.primary.withAlpha(0),
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: selected ? null : onTap,
            borderRadius: BorderRadius.circular(6),
            child: Center(
              child: Text(
                '$page',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
