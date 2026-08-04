import 'package:biog_forum_application/features/blog_page/models/blog_models.dart';
import 'package:redux/redux.dart';
import 'blog_actions.dart';
import 'blog_state.dart';

BlogState blogReducer(
  BlogState s,
  dynamic action,
) => combineReducers<BlogState>([
  TypedReducer<BlogState, LoadPostsRequested>((s, a) {
    if (a.page == s.currentPage && s.postsLoading) return s;
    return s.copyWith(
      postsLoading: true,
      currentPage: a.page,
      clearPostsError: true,
    );
  }).call,
  TypedReducer<BlogState, LoadPostsSucceeded>(
    (s, a) => s.postsLoading
        ? s.copyWith(
            posts: a.posts,
            postsLoading: false,
            currentPage: a.currentPage,
            totalPages: a.totalPages,
            clearPostsError: true,
          )
        : s,
  ).call,
  TypedReducer<BlogState, LoadPostsFailed>(
    (s, a) => s.postsLoading
        ? s.copyWith(postsLoading: false, postsError: a.message)
        : s,
  ).call,

  TypedReducer<BlogState, LoadPostRequested>(
    (s, a) => s.copyWith(
      postLoading: true,
      clearPostError: true,
      selectedPost: a.postId == s.selectedPost?.id ? s.selectedPost : null,
    ),
  ).call,
  TypedReducer<BlogState, LoadPostSucceeded>(
    (s, a) => s.postLoading
        ? s.copyWith(
            selectedPost: a.post,
            postLoading: false,
            clearPostError: true,
            posts: _replacePost(s.posts, a.post),
          )
        : s,
  ).call,
  TypedReducer<BlogState, LoadPostFailed>(
    (s, a) => s.postLoading
        ? s.copyWith(postLoading: false, postError: a.message)
        : s,
  ).call,

  TypedReducer<BlogState, LoadCommentsRequested>(
    (s, a) => s.copyWith(
      comments: a.postId == _detailId(s) ? s.comments : [],
      commentsLoading: true,
      clearCommentsError: true,
    ),
  ).call,
  TypedReducer<BlogState, LoadCommentsSucceeded>(
    (s, a) => s.commentsLoading
        ? s.copyWith(
            comments: a.comments,
            commentsLoading: false,
            clearCommentsError: true,
          )
        : s,
  ).call,
  TypedReducer<BlogState, LoadCommentsFailed>(
    (s, a) => s.commentsLoading
        ? s.copyWith(commentsLoading: false, commentsError: a.message)
        : s,
  ).call,

  TypedReducer<BlogState, CreatePostRequested>(
    (s, _) => s.isBusy ? s : s.copyWith(isBusy: true),
  ).call,
  TypedReducer<BlogState, PostCreated>(
    (s, a) => s.isBusy
        ? s.copyWith(
            posts: [a.post, ...s.posts],
            isBusy: false,
            selectedPost: a.post,
            clearPostError: true,
          )
        : s,
  ).call,
  TypedReducer<BlogState, CreatePostFailed>(
    (s, a) => s.isBusy ? s.copyWith(isBusy: false, postsError: a.message) : s,
  ).call,
  TypedReducer<BlogState, UpdatePostRequested>(
    (s, _) => s.isBusy ? s : s.copyWith(isBusy: true),
  ).call,
  TypedReducer<BlogState, PostUpdated>(
    (s, a) => s.isBusy
        ? s.copyWith(
            posts: _replacePost(s.posts, a.post),
            selectedPost: s.selectedPost?.id == a.post.id
                ? _mergePostImages(s.selectedPost!, a.post)
                : s.selectedPost,
            isBusy: false,
            clearPostError: true,
          )
        : s,
  ).call,
  TypedReducer<BlogState, UpdatePostFailed>(
    (s, a) => s.isBusy ? s.copyWith(isBusy: false, postsError: a.message) : s,
  ).call,
  TypedReducer<BlogState, DeletePostRequested>(
    (s, a) => s.isBusy ? s : s.copyWith(isBusy: true),
  ).call,
  TypedReducer<BlogState, PostDeleted>(
    (s, a) => s.isBusy
        ? s.copyWith(
            posts: s.posts.where((p) => p.id != a.id).toList(),
            clearSelectedPost: s.selectedPost?.id == a.id,
            isBusy: false,
            clearPostError: true,
          )
        : s,
  ).call,
  TypedReducer<BlogState, DeletePostFailed>(
    (s, a) => s.isBusy ? s.copyWith(isBusy: false, postsError: a.message) : s,
  ).call,

  TypedReducer<BlogState, CreateCommentRequested>(
    (s, _) => s.isBusy ? s : s.copyWith(isBusy: true),
  ).call,
  TypedReducer<BlogState, CommentCreated>(
    (s, a) => s.isBusy
        ? s.copyWith(
            comments: [...s.comments, a.comment],
            isBusy: false,
            clearCommentsError: true,
          )
        : s,
  ).call,
  TypedReducer<BlogState, CreateCommentFailed>(
    (s, a) =>
        s.isBusy ? s.copyWith(isBusy: false, commentsError: a.message) : s,
  ).call,
  TypedReducer<BlogState, UpdateCommentRequested>(
    (s, _) => s.isBusy ? s : s.copyWith(isBusy: true),
  ).call,
  TypedReducer<BlogState, CommentUpdated>(
    (s, a) => s.isBusy
        ? s.copyWith(
            comments: s.comments
                .map(
                  (c) => c.id == a.comment.id
                      ? _mergeCommentImages(c, a.comment)
                      : c,
                )
                .toList(),
            isBusy: false,
            clearCommentsError: true,
          )
        : s,
  ).call,
  TypedReducer<BlogState, UpdateCommentFailed>(
    (s, a) =>
        s.isBusy ? s.copyWith(isBusy: false, commentsError: a.message) : s,
  ).call,
  TypedReducer<BlogState, DeleteCommentRequested>(
    (s, _) => s.isBusy ? s : s.copyWith(isBusy: true),
  ).call,
  TypedReducer<BlogState, CommentDeleted>(
    (s, a) => s.isBusy
        ? s.copyWith(
            comments: s.comments.where((c) => c.id != a.id).toList(),
            isBusy: false,
            clearCommentsError: true,
          )
        : s,
  ).call,
  TypedReducer<BlogState, DeleteCommentFailed>(
    (s, a) =>
        s.isBusy ? s.copyWith(isBusy: false, commentsError: a.message) : s,
  ).call,

  TypedReducer<BlogState, UploadPostImageRequested>(
    (s, _) => s.isBusy ? s : s.copyWith(isBusy: true),
  ).call,
  TypedReducer<BlogState, PostImageUploaded>(
    (s, a) => s.copyWith(
      posts: s.posts
          .map(
            (p) => p.id == a.postId
                ? p.copyWith(images: _sortedImages([...p.images, a.image]))
                : p,
          )
          .toList(),
      selectedPost: s.selectedPost?.id == a.postId
          ? s.selectedPost!.copyWith(
              images: _sortedImages([...s.selectedPost!.images, a.image]),
            )
          : s.selectedPost,
      isBusy: false,
      clearPostError: true,
    ),
  ).call,
  TypedReducer<BlogState, UploadPostImageFailed>(
    (s, a) => s.copyWith(isBusy: false, postsError: a.message),
  ).call,
  TypedReducer<BlogState, DeletePostImageRequested>(
    (s, _) => s.isBusy ? s : s.copyWith(isBusy: true),
  ).call,
  TypedReducer<BlogState, PostImageDeleted>(
    (s, a) => s.copyWith(
      posts: s.posts
          .map(
            (p) => p.id == a.postId
                ? p.copyWith(
                    images: p.images.where((i) => i.id != a.imageId).toList(),
                  )
                : p,
          )
          .toList(),
      selectedPost: s.selectedPost?.id == a.postId
          ? s.selectedPost!.copyWith(
              images: s.selectedPost!.images
                  .where((i) => i.id != a.imageId)
                  .toList(),
            )
          : s.selectedPost,
      isBusy: false,
      clearPostError: true,
    ),
  ).call,
  TypedReducer<BlogState, DeletePostImageFailed>(
    (s, a) => s.copyWith(isBusy: false, postsError: a.message),
  ).call,
  TypedReducer<BlogState, UploadCommentImageRequested>(
    (s, _) => s.isBusy ? s : s.copyWith(isBusy: true),
  ).call,
  TypedReducer<BlogState, CommentImageUploaded>(
    (s, a) => s.copyWith(
      comments: s.comments
          .map(
            (c) => c.id == a.commentId
                ? BlogComment(
                    id: c.id,
                    postId: c.postId,
                    authorId: c.authorId,
                    body: c.body,
                    createdAt: c.createdAt,
                    updatedAt: c.updatedAt,
                    author: c.author,
                    images: _sortedImages([...c.images, a.image]),
                  )
                : c,
          )
          .toList(),
      isBusy: false,
      clearCommentsError: true,
    ),
  ).call,
  TypedReducer<BlogState, UploadCommentImageFailed>(
    (s, a) => s.copyWith(isBusy: false, commentsError: a.message),
  ).call,
  TypedReducer<BlogState, DeleteCommentImageRequested>(
    (s, _) => s.isBusy ? s : s.copyWith(isBusy: true),
  ).call,
  TypedReducer<BlogState, CommentImageDeleted>(
    (s, a) => s.copyWith(
      comments: s.comments
          .map(
            (c) => c.id == a.commentId
                ? BlogComment(
                    id: c.id,
                    postId: c.postId,
                    authorId: c.authorId,
                    body: c.body,
                    createdAt: c.createdAt,
                    updatedAt: c.updatedAt,
                    author: c.author,
                    images: c.images.where((i) => i.id != a.imageId).toList(),
                  )
                : c,
          )
          .toList(),
      isBusy: false,
      clearCommentsError: true,
    ),
  ).call,
  TypedReducer<BlogState, DeleteCommentImageFailed>(
    (s, a) => s.copyWith(isBusy: false, commentsError: a.message),
  ).call,
])(s, action);

int? _detailId(BlogState s) => s.selectedPost?.id;

List<BlogPost> _replacePost(List<BlogPost> posts, BlogPost post) =>
    posts.map((p) {
      if (p.id != post.id) return p;
      return post.images.isNotEmpty || p.images.isEmpty
          ? post
          : post.copyWith(images: p.images);
    }).toList();

BlogPost _mergePostImages(BlogPost existing, BlogPost incoming) =>
    incoming.images.isNotEmpty || existing.images.isEmpty
    ? incoming
    : incoming.copyWith(images: existing.images);

BlogComment _mergeCommentImages(BlogComment existing, BlogComment incoming) {
  if (incoming.images.isNotEmpty || existing.images.isEmpty) return incoming;
  return BlogComment(
    id: incoming.id,
    postId: incoming.postId,
    authorId: incoming.authorId,
    body: incoming.body,
    createdAt: incoming.createdAt,
    updatedAt: incoming.updatedAt,
    author: incoming.author,
    images: existing.images,
  );
}

List<ContentImage> _sortedImages(List<ContentImage> images) {
  images.sort(
    (a, b) => a.position == b.position
        ? a.id.compareTo(b.id)
        : a.position.compareTo(b.position),
  );
  return images;
}
