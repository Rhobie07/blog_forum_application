import 'package:biog_forum_application/features/auth/state/auth_notifier.dart';
import 'package:biog_forum_application/features/blog_page/models/blog_models.dart';
import 'package:biog_forum_application/features/blog_page/state/blog_notifier.dart';
import 'package:biog_forum_application/features/blog_page/widgets/comment_thread.dart';
import 'package:biog_forum_application/features/blog_page/widgets/media_gallery.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key, required this.postId});

  final int postId;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _load();
  }

  @override
  void didUpdateWidget(covariant PostDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.postId != widget.postId) {
      _load();
    }
  }

  void _load() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final notifier = context.read<BlogNotifier>();
      notifier.loadPost(widget.postId);
      notifier.loadComments(widget.postId);
    });
  }

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
    final auth = context
        .select<AuthNotifier, ({bool signedIn, String? userId})>(
          (notifier) => (
            signedIn: notifier.state.session != null,
            userId: notifier.state.session?.user.id,
          ),
        );
    final blog = context
        .select<
          BlogNotifier,
          ({
            BlogPost? post,
            bool postLoading,
            String? postError,
            List<BlogComment> comments,
            bool commentsLoading,
            String? commentsError,
            bool busy,
          })
        >(
          (notifier) => (
            post: notifier.state.selectedPost,
            postLoading: notifier.state.postLoading,
            postError: notifier.state.postError,
            comments: notifier.state.comments,
            commentsLoading: notifier.state.commentsLoading,
            commentsError: notifier.state.commentsError,
            busy: notifier.state.isBusy,
          ),
        );

    if (blog.postLoading && blog.post == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (blog.postError != null && blog.post == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(blog.postError!),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () =>
                    context.read<BlogNotifier>().loadPost(widget.postId),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final post = blog.post;
    if (post == null) {
      return const Scaffold(body: Center(child: Text('Post unavailable')));
    }

    final theme = Theme.of(context);
    final authorName = post.author?.displayName ?? 'Anonymous';

    return Scaffold(
      appBar: AppBar(
        title: Text(post.title, style: theme.textTheme.titleSmall),
        leading: BackButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/blogPage'),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 760;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: wide ? 48 : 20,
                  vertical: 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: theme.colorScheme.secondary
                              .withAlpha(25),
                          child: Text(
                            authorName[0].toUpperCase(),
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.w600,
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
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${_timeAgo(post.createdAt)} ago',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (post.images.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: MediaGallery(
                          images: post.images,
                          imageFit: BoxFit.contain,
                          parentPostId: post.id,
                          parentLabel: post.title,
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    SelectableText(
                      post.content,
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.7),
                    ),
                    const SizedBox(height: 48),
                    const Divider(),
                    const SizedBox(height: 24),
                    CommentThread(
                      postId: post.id,
                      comments: blog.comments,
                      currentUserId: auth.userId,
                      commentsLoading: blog.commentsLoading,
                      error: blog.commentsError,
                      isBusy: blog.busy,
                      onLogin: () => context.go('/login'),
                      onCreate: auth.signedIn
                          ? (postId, body) async {
                              await context.read<BlogNotifier>().createComment(
                                postId,
                                body,
                              );
                              return null;
                            }
                          : null,
                      onUpdate: auth.signedIn
                          ? (id, body) async {
                              await context.read<BlogNotifier>().updateComment(
                                id,
                                body,
                              );
                              return null;
                            }
                          : null,
                      onDelete: auth.signedIn
                          ? (id) async {
                              await context.read<BlogNotifier>().deleteComment(
                                id,
                              );
                              return null;
                            }
                          : null,
                      onUploadImage: auth.signedIn
                          ? (commentId, file, position) {
                              context.read<BlogNotifier>().uploadCommentImage(
                                commentId,
                                file,
                                position,
                              );
                            }
                          : null,
                      onDeleteImage: auth.signedIn
                          ? (commentId, image) {
                              context.read<BlogNotifier>().deleteCommentImage(
                                commentId,
                                image,
                              );
                            }
                          : null,
                      onRetryComments: () =>
                          context.read<BlogNotifier>().loadComments(post.id),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
