import 'package:biog_forum_application/features/blog_page/models/blog_models.dart';

class BlogState {
  BlogState({
    List<BlogPost> posts = const [],
    this.currentPage = 1,
    this.totalPages = 0,
    this.postsLoading = false,
    this.postsError,
    this.selectedPost,
    this.postLoading = false,
    this.postError,
    List<BlogComment> comments = const [],
    this.commentsLoading = false,
    this.commentsError,
    this.isBusy = false,
  }) : posts = List.unmodifiable(posts),
       comments = List.unmodifiable(comments);

  final List<BlogPost> posts;
  final int currentPage;
  final int totalPages;
  final bool postsLoading;
  final String? postsError;
  final BlogPost? selectedPost;
  final bool postLoading;
  final String? postError;
  final List<BlogComment> comments;
  final bool commentsLoading;
  final String? commentsError;
  final bool isBusy;

  BlogState copyWith({
    List<BlogPost>? posts,
    int? currentPage,
    int? totalPages,
    bool? postsLoading,
    String? postsError,
    bool clearPostsError = false,
    BlogPost? selectedPost,
    bool clearSelectedPost = false,
    bool? postLoading,
    String? postError,
    bool clearPostError = false,
    List<BlogComment>? comments,
    bool? commentsLoading,
    String? commentsError,
    bool clearCommentsError = false,
    bool? isBusy,
  }) => BlogState(
    posts: posts ?? this.posts,
    currentPage: currentPage ?? this.currentPage,
    totalPages: totalPages ?? this.totalPages,
    postsLoading: postsLoading ?? this.postsLoading,
    postsError: clearPostsError ? null : postsError ?? this.postsError,
    selectedPost: clearSelectedPost ? null : selectedPost ?? this.selectedPost,
    postLoading: postLoading ?? this.postLoading,
    postError: clearPostError ? null : postError ?? this.postError,
    comments: comments ?? this.comments,
    commentsLoading: commentsLoading ?? this.commentsLoading,
    commentsError: clearCommentsError
        ? null
        : commentsError ?? this.commentsError,
    isBusy: isBusy ?? this.isBusy,
  );
}
