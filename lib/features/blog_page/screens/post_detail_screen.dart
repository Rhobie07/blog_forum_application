import 'package:biog_forum_application/core/redux/app_state.dart';
import 'package:biog_forum_application/features/blog_page/redux/blog_actions.dart';
import 'package:biog_forum_application/features/blog_page/view_models/blog_view_models.dart';
import 'package:biog_forum_application/features/blog_page/widgets/comment_thread.dart';
import 'package:biog_forum_application/features/blog_page/widgets/media_gallery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:redux/redux.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key, required this.postId});

  final int postId;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  @override
  void didUpdateWidget(covariant PostDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.postId != widget.postId) {
      _load(StoreProvider.of<AppState>(context));
    }
  }

  void _load(Store<AppState> store) {
    store.dispatch(LoadPostRequested(widget.postId));
    store.dispatch(LoadCommentsRequested(widget.postId));
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
  Widget build(
    BuildContext context,
  ) => StoreConnector<AppState, PostDetailViewModel>(
    converter: _postDetailsFromStore,
    onInit: (store) => _load(store),
    builder: (context, dvm) {
      if (dvm.postLoading && dvm.post == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      if (dvm.postError != null && dvm.post == null) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(dvm.postError!),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => StoreProvider.of<AppState>(
                    context,
                  ).dispatch(LoadPostRequested(widget.postId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      final post = dvm.post;

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
                        comments: dvm.comments,
                        currentUserId: dvm.currentUserId,
                        commentsLoading: dvm.commentsLoading,
                        error: dvm.commentsError,
                        isBusy: dvm.isBusy,
                        onLogin: () => context.go('/login'),
                        onCreate: dvm.isSignedIn
                            ? (postId, body) async {
                                StoreProvider.of<AppState>(context).dispatch(
                                  CreateCommentRequested(postId, body),
                                );
                                return null;
                              }
                            : null,
                        onUpdate: dvm.isSignedIn
                            ? (id, body) async {
                                StoreProvider.of<AppState>(
                                  context,
                                ).dispatch(UpdateCommentRequested(id, body));
                                return null;
                              }
                            : null,
                        onDelete: dvm.isSignedIn
                            ? (id) async {
                                StoreProvider.of<AppState>(
                                  context,
                                ).dispatch(DeleteCommentRequested(id));
                                return null;
                              }
                            : null,
                        onUploadImage: dvm.isSignedIn
                            ? (commentId, file, position) {
                                StoreProvider.of<AppState>(context).dispatch(
                                  UploadCommentImageRequested(
                                    commentId,
                                    file,
                                    position,
                                  ),
                                );
                              }
                            : null,
                        onDeleteImage: dvm.isSignedIn
                            ? (commentId, image) {
                                StoreProvider.of<AppState>(context).dispatch(
                                  DeleteCommentImageRequested(commentId, image),
                                );
                              }
                            : null,
                        onRetryComments: () => StoreProvider.of<AppState>(
                          context,
                        ).dispatch(LoadCommentsRequested(post.id)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}

PostDetailViewModel _postDetailsFromStore(Store<AppState> store) {
  final blog = store.state.blog;
  return PostDetailViewModel(
    post: blog.selectedPost,
    postLoading: blog.postLoading,
    postError: blog.postError,
    comments: blog.comments,
    commentsLoading: blog.commentsLoading,
    commentsError: blog.commentsError,
    isBusy: blog.isBusy,
    isSignedIn: store.state.auth.session != null,
    currentUserId: store.state.auth.session?.user.id,
  );
}
