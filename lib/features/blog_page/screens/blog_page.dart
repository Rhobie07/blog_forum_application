import 'package:biog_forum_application/features/auth/state/auth_notifier.dart';
import 'package:biog_forum_application/features/blog_page/models/blog_models.dart';
import 'package:biog_forum_application/features/blog_page/state/blog_notifier.dart';
import 'package:biog_forum_application/features/blog_page/widgets/blog_feed.dart';
import 'package:biog_forum_application/features/blog_page/widgets/post_editor.dart';
import 'package:biog_forum_application/features/blog_page/widgets/profile_menu.dart';
import 'package:biog_forum_application/features/ui/header_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BlogPageScreen extends StatefulWidget {
  const BlogPageScreen({super.key});

  @override
  State<BlogPageScreen> createState() => _BlogPageScreenState();
}

class _BlogPageScreenState extends State<BlogPageScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<BlogNotifier>().loadPosts(page: 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context
        .select<
          AuthNotifier,
          ({bool signedIn, String? userId, String displayName})
        >((notifier) {
          final session = notifier.state.session;
          return (
            signedIn: session != null,
            userId: session?.user.id,
            displayName: _displayName(session),
          );
        });
    final blog = context
        .select<
          BlogNotifier,
          ({
            List<BlogPost> posts,
            bool loading,
            bool busy,
            String? error,
            int currentPage,
            int totalPages,
          })
        >(
          (notifier) => (
            posts: notifier.state.posts,
            loading: notifier.state.postsLoading,
            busy: notifier.state.isBusy,
            error: notifier.state.postsError,
            currentPage: notifier.state.currentPage,
            totalPages: notifier.state.totalPages,
          ),
        );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: theme.dividerColor)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    HeaderIconWidget(theme: theme),
                    ProfileMenu(
                      isSignedIn: auth.signedIn,
                      displayName: auth.displayName,
                      onLogin: () => context.go('/login'),
                      onLogout: () => _confirmLogout(context),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: BlogFeed(
                posts: blog.posts,
                currentUserId: auth.userId,
                loading: blog.loading,
                isBusy: blog.busy,
                error: blog.error,
                onCreate: auth.signedIn
                    ? () => _edit(context, blog.busy)
                    : null,
                onEdit: auth.signedIn
                    ? (post) => _edit(context, blog.busy, post)
                    : null,
                onDelete: auth.signedIn
                    ? (post) => _confirmDelete(context, post)
                    : null,
                onOpen: (post) => context.go('/posts/${post.id}'),
                currentPage: blog.currentPage,
                totalPages: blog.totalPages,
                onPageChanged: (page) =>
                    context.read<BlogNotifier>().loadPosts(page: page),
                onRetry: () => context.read<BlogNotifier>().loadPosts(page: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, BlogPost post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete post?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    await context.read<BlogNotifier>().deletePost(post.id);
  }

  Future<void> _edit(BuildContext context, bool isBusy, [BlogPost? post]) =>
      showDialog<void>(
        context: context,
        builder: (_) => PostEditor(
          title: post?.title,
          excerpt: post?.excerpt,
          content: post?.content,
          postId: post?.id,
          existingImages: post?.images ?? const [],
          isSaving: isBusy,
          onSubmit: (title, excerpt, content, images) async {
            final notifier = context.read<BlogNotifier>();
            if (post == null) {
              await notifier.createPost(title, excerpt, content, images);
            } else {
              await notifier.updatePost(
                post.id,
                title,
                excerpt,
                content,
                images,
              );
            }
            return null;
          },
          onDeleteImage: post == null
              ? null
              : (image) {
                  context.read<BlogNotifier>().deletePostImage(post.id, image);
                },
        ),
      );
}

Future<void> _confirmLogout(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Confirm Logout?'),
      content: const Text('This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Logout'),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;
  await context.read<AuthNotifier>().signOut();
}

String _displayName(Session? session) {
  final email = session?.user.email;
  if (email != null && email.contains('@')) {
    return email.substring(0, email.indexOf('@'));
  }
  return '';
}
