import 'package:biog_forum_application/features/ui/header_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:go_router/go_router.dart';
import 'package:redux/redux.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:biog_forum_application/core/redux/app_state.dart';
import 'package:biog_forum_application/features/auth/redux/auth_actions.dart';
import 'package:biog_forum_application/features/blog_page/models/blog_models.dart';
import 'package:biog_forum_application/features/blog_page/redux/blog_actions.dart';
import 'package:biog_forum_application/features/blog_page/view_models/blog_view_models.dart';
import 'package:biog_forum_application/features/blog_page/widgets/blog_feed.dart';
import 'package:biog_forum_application/features/blog_page/widgets/post_editor.dart';
import 'package:biog_forum_application/features/blog_page/widgets/profile_menu.dart';

class BlogPageScreen extends StatelessWidget {
  const BlogPageScreen({super.key});

  @override
  Widget build(
    BuildContext context,
  ) => StoreConnector<AppState, BlogPageViewModel>(
    converter: _bvmFromStore,
    onInit: (store) => store.dispatch(const LoadPostsRequested(page: 1)),
    builder: (context, bvm) {
      final theme = Theme.of(context);
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              //Header
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
                        isSignedIn: bvm.isSignedIn,
                        displayName: bvm.displayName,
                        onLogin: () => context.go('/login'),
                        onLogout: () => StoreProvider.of<AppState>(
                          context,
                        ).dispatch(const SignOutRequested()),
                      ),
                    ],
                  ),
                ),
              ),

              //blog feed
              Expanded(
                child: BlogFeed(
                  posts: bvm.posts,
                  isSignedIn: bvm.isSignedIn,
                  currentUserId: bvm.currentUserId,
                  loading: bvm.postsLoading,
                  isBusy: bvm.isBusy,
                  error: bvm.postsError,
                  onCreate: bvm.isSignedIn ? () => _edit(context, bvm) : null,
                  onEdit: bvm.isSignedIn
                      ? (post) => _edit(context, bvm, post)
                      : null,
                  onDelete: bvm.isSignedIn
                      ? (post) => _confirmDelete(context, post)
                      : null,
                  onOpen: (post) => context.go('/posts/${post.id}'),
                  currentPage: bvm.currentPage,
                  totalPages: bvm.totalPages,
                  onPageChanged: (page) => StoreProvider.of<AppState>(
                    context,
                  ).dispatch(LoadPostsRequested(page: page)),
                  onRetry: () => StoreProvider.of<AppState>(
                    context,
                  ).dispatch(const LoadPostsRequested(page: 1)),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

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

    StoreProvider.of<AppState>(context).dispatch(DeletePostRequested(post.id));
  }

  Future<void> _edit(
    BuildContext context,
    BlogPageViewModel bvm, [
    BlogPost? post,
  ]) => showDialog<void>(
    context: context,
    builder: (_) => PostEditor(
      title: post?.title,
      excerpt: post?.excerpt,
      content: post?.content,
      postId: post?.id,
      existingImages: post?.images ?? const [],
      isSaving: bvm.isBusy,
      onSubmit: (title, excerpt, content) async {
        final store = StoreProvider.of<AppState>(context);
        if (post == null) {
          store.dispatch(CreatePostRequested(title, excerpt, content));
        } else {
          store.dispatch(UpdatePostRequested(post.id, title, excerpt, content));
        }
        return null;
      },
      onUploadImage: (file, position) {
        final store = StoreProvider.of<AppState>(context);
        final id = post?.id ?? store.state.blog.selectedPost?.id;
        if (id != null) {
          store.dispatch(UploadPostImageRequested(id, file, position));
        }
      },
      onDeleteImage: post == null
          ? null
          : (image) {
              StoreProvider.of<AppState>(
                context,
              ).dispatch(DeletePostImageRequested(post.id, image));
            },
    ),
  );
}

BlogPageViewModel _bvmFromStore(Store<AppState> store) {
  final blog = store.state.blog;
  final session = store.state.auth.session;
  return BlogPageViewModel(
    posts: blog.posts,
    isSignedIn: session != null,
    currentUserId: session?.user.id,
    displayName: _displayName(session),
    postsLoading: blog.postsLoading,
    isBusy: blog.isBusy,
    postsError: blog.postsError,
    currentPage: blog.currentPage,
    totalPages: blog.totalPages,
  );
}

String _displayName(Session? session) {
  final email = session?.user.email;
  if (email != null && email.contains('@')) {
    return email.substring(0, email.indexOf('@'));
  }
  return '';
}
