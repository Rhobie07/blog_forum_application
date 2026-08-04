import 'package:biog_forum_application/features/blog_page/models/blog_models.dart';

class BlogPageViewModel {
  const BlogPageViewModel({
    required this.posts,
    required this.isSignedIn,
    this.currentUserId,
    required this.displayName,
    required this.postsLoading,
    required this.isBusy,
    required this.postsError,
    required this.currentPage,
    required this.totalPages,
  });

  final List<BlogPost> posts;
  final bool isSignedIn;
  final String? currentUserId;
  final String displayName;
  final bool postsLoading;
  final bool isBusy;
  final String? postsError;
  final int currentPage;
  final int totalPages;
}

class PostDetailViewModel {
  const PostDetailViewModel({
    this.post,
    required this.postLoading,
    this.postError,
    required this.comments,
    required this.commentsLoading,
    this.commentsError,
    required this.isBusy,
    required this.isSignedIn,
    this.currentUserId,
  });

  final BlogPost? post;
  final bool postLoading;
  final String? postError;
  final List<BlogComment> comments;
  final bool commentsLoading;
  final String? commentsError;
  final bool isBusy;
  final bool isSignedIn;
  final String? currentUserId;
}
