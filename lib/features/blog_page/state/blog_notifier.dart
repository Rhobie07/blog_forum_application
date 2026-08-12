import 'package:biog_forum_application/features/blog_page/data/blog_repository.dart';
import 'package:biog_forum_application/features/blog_page/models/blog_models.dart';
import 'package:biog_forum_application/features/blog_page/state/blog_state.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class BlogNotifier extends ChangeNotifier {
  BlogNotifier(this._repository);

  final BlogRepository _repository;

  BlogState _state = BlogState();
  BlogState get state => _state;

  int _feedGeneration = 0;
  int _detailGeneration = 0;
  int _commentsGeneration = 0;
  bool _disposed = false;

  Future<void> loadPosts({required int page}) async {
    if (page < 1) return;
    if (_state.postsLoading && page == _state.currentPage) return;

    _feedGeneration = _feedGeneration + 1;
    final generation = _feedGeneration;
    _setState(
      _state.copyWith(
        postsLoading: true,
        currentPage: page,
        clearPostsError: true,
      ),
    );

    try {
      final result = await _repository.listPublishedPage(page: page);
      if (generation != _feedGeneration) return;
      _setState(
        _state.copyWith(
          posts: result.posts,
          postsLoading: false,
          currentPage: result.currentPage,
          totalPages: result.totalPages,
          clearPostsError: true,
        ),
      );
    } catch (error) {
      if (generation != _feedGeneration) return;
      _setState(_state.copyWith(postsLoading: false, postsError: '$error'));
    }
  }

  Future<void> loadPost(int postId) async {
    if (postId <= 0) return;

    _detailGeneration = _detailGeneration + 1;
    final generation = _detailGeneration;

    final keepSelected = _state.selectedPost?.id == postId;
    _setState(
      _state.copyWith(
        postLoading: true,
        clearPostError: true,
        clearSelectedPost: !keepSelected,
      ),
    );

    try {
      final post = await _repository.fetchPost(postId);
      if (generation != _detailGeneration) return;
      _setState(
        _state.copyWith(
          selectedPost: post,
          postLoading: false,
          clearPostError: true,
          posts: _replacePost(_state.posts, post),
        ),
      );
    } catch (error) {
      if (generation != _detailGeneration) return;
      _setState(_state.copyWith(postLoading: false, postError: '$error'));
    }
  }

  Future<void> loadComments(int postId) async {
    if (postId <= 0) return;

    _commentsGeneration = _commentsGeneration + 1;
    final generation = _commentsGeneration;

    _setState(
      _state.copyWith(
        comments: postId == _state.selectedPost?.id
            ? _state.comments
            : const [],
        commentsLoading: true,
        clearCommentsError: true,
      ),
    );

    try {
      final comments = await _repository.listComments(postId);
      if (generation != _commentsGeneration) return;
      _setState(
        _state.copyWith(
          comments: comments,
          commentsLoading: false,
          clearCommentsError: true,
        ),
      );
    } catch (error) {
      if (generation != _commentsGeneration) return;
      _setState(
        _state.copyWith(commentsLoading: false, commentsError: '$error'),
      );
    }
  }

  Future<void> createPost(
    String title,
    String excerpt,
    String content,
    List<XFile> images,
  ) async {
    if (!_beginMutation()) return;

    late final BlogPost created;
    try {
      created = await _repository.create(
        title: title,
        excerpt: excerpt,
        content: content,
      );
    } catch (_) {
      _setState(
        _state.copyWith(
          isBusy: false,
          postsError: 'Unable to save changes. Please try again.',
        ),
      );
      return;
    }

    _setState(
      _state.copyWith(
        posts: [created, ..._state.posts],
        isBusy: false,
        selectedPost: created,
        clearPostError: true,
      ),
    );
    await _uploadSavedPostImages(created.id, images);
  }

  Future<void> updatePost(
    int postId,
    String title,
    String excerpt,
    String content,
    List<XFile> images,
  ) async {
    if (!_beginMutation()) return;

    late final BlogPost updated;
    try {
      updated = await _repository.update(
        id: postId,
        title: title,
        excerpt: excerpt,
        content: content,
      );
    } catch (_) {
      _setState(
        _state.copyWith(
          isBusy: false,
          postsError: 'Unable to save changes. Please try again.',
        ),
      );
      return;
    }

    _setState(
      _state.copyWith(
        posts: _replacePost(_state.posts, updated),
        selectedPost: _state.selectedPost?.id == updated.id
            ? _mergePostImages(_state.selectedPost!, updated)
            : _state.selectedPost,
        isBusy: false,
        clearPostError: true,
      ),
    );
    await _uploadSavedPostImages(updated.id, images);
  }

  Future<void> deletePost(int postId) async {
    if (!_beginMutation()) return;

    try {
      await _repository.delete(postId);
      _setState(
        _state.copyWith(
          posts: _state.posts.where((post) => post.id != postId).toList(),
          clearSelectedPost: _state.selectedPost?.id == postId,
          isBusy: false,
          clearPostError: true,
        ),
      );
    } catch (_) {
      _setState(
        _state.copyWith(
          isBusy: false,
          postsError: 'Unable to delete post. Please try again.',
        ),
      );
    }
  }

  Future<void> createComment(int postId, String? body) async {
    if (!_beginMutation()) return;

    try {
      final comment = await _repository.createComment(
        postId: postId,
        body: body,
      );
      _setState(
        _state.copyWith(
          comments: [..._state.comments, comment],
          isBusy: false,
          clearCommentsError: true,
        ),
      );
    } catch (_) {
      _setState(
        _state.copyWith(
          isBusy: false,
          commentsError: 'Unable to save comment. Please try again.',
        ),
      );
    }
  }

  Future<void> updateComment(int commentId, String body) async {
    if (!_beginMutation()) return;

    try {
      final updated = await _repository.updateComment(
        id: commentId,
        body: body,
      );
      _setState(
        _state.copyWith(
          comments: _state.comments
              .map(
                (comment) => comment.id == updated.id
                    ? _mergeCommentImages(comment, updated)
                    : comment,
              )
              .toList(),
          isBusy: false,
          clearCommentsError: true,
        ),
      );
    } catch (_) {
      _setState(
        _state.copyWith(
          isBusy: false,
          commentsError: 'Unable to save comment. Please try again.',
        ),
      );
    }
  }

  Future<void> deleteComment(int commentId) async {
    if (!_beginMutation()) return;

    try {
      await _repository.deleteComment(commentId);
      _setState(
        _state.copyWith(
          comments: _state.comments
              .where((comment) => comment.id != commentId)
              .toList(),
          isBusy: false,
          clearCommentsError: true,
        ),
      );
    } catch (_) {
      _setState(
        _state.copyWith(
          isBusy: false,
          commentsError: 'Unable to delete comment. Please try again.',
        ),
      );
    }
  }

  Future<void> uploadPostImage(int postId, XFile file, int position) async {
    if (!_beginMutation()) return;

    try {
      final image = await _repository.uploadPostImage(
        postId: postId,
        file: file,
        position: position,
      );
      _applyPostImage(postId, image);
    } catch (_) {
      _setState(
        _state.copyWith(
          isBusy: false,
          postsError: 'Unable to save image. Please try again.',
        ),
      );
    }
  }

  Future<void> deletePostImage(int postId, ContentImage image) async {
    if (!_beginMutation()) return;

    try {
      await _repository.deletePostImage(image);
      _setState(
        _state.copyWith(
          posts: _state.posts
              .map(
                (post) => post.id == postId
                    ? post.copyWith(
                        images: post.images
                            .where((item) => item.id != image.id)
                            .toList(),
                      )
                    : post,
              )
              .toList(),
          selectedPost: _state.selectedPost?.id == postId
              ? _state.selectedPost!.copyWith(
                  images: _state.selectedPost!.images
                      .where((item) => item.id != image.id)
                      .toList(),
                )
              : _state.selectedPost,
          isBusy: false,
          clearPostError: true,
        ),
      );
    } catch (_) {
      _setState(
        _state.copyWith(
          isBusy: false,
          postsError: 'Unable to delete image. Please try again.',
        ),
      );
    }
  }

  Future<void> uploadCommentImage(
    int commentId,
    XFile file,
    int position,
  ) async {
    if (!_beginMutation()) return;

    try {
      final image = await _repository.uploadCommentImage(
        commentId: commentId,
        file: file,
        position: position,
      );
      _setState(
        _state.copyWith(
          comments: _state.comments
              .map(
                (comment) => comment.id == commentId
                    ? _copyCommentWithImages(
                        comment,
                        _sortedImages([...comment.images, image]),
                      )
                    : comment,
              )
              .toList(),
          isBusy: false,
          clearCommentsError: true,
        ),
      );
    } catch (_) {
      _setState(
        _state.copyWith(
          isBusy: false,
          commentsError: 'Unable to save image. Please try again.',
        ),
      );
    }
  }

  Future<void> deleteCommentImage(int commentId, ContentImage image) async {
    if (!_beginMutation()) return;

    try {
      await _repository.deleteCommentImage(image);
      _setState(
        _state.copyWith(
          comments: _state.comments
              .map(
                (comment) => comment.id == commentId
                    ? _copyCommentWithImages(
                        comment,
                        comment.images
                            .where((item) => item.id != image.id)
                            .toList(),
                      )
                    : comment,
              )
              .toList(),
          isBusy: false,
          clearCommentsError: true,
        ),
      );
    } catch (_) {
      _setState(
        _state.copyWith(
          isBusy: false,
          commentsError: 'Unable to delete image. Please try again.',
        ),
      );
    }
  }

  bool _beginMutation() {
    if (_state.isBusy) return false;
    _setState(_state.copyWith(isBusy: true));
    return true;
  }

  Future<void> _uploadSavedPostImages(int postId, List<XFile> images) async {
    for (var position = 0; position < images.length; position++) {
      try {
        final image = await _repository.uploadPostImage(
          postId: postId,
          file: images[position],
          position: position,
        );
        _applyPostImage(postId, image);
      } catch (_) {
        _setState(
          _state.copyWith(
            isBusy: false,
            postsError: 'Unable to save image. Please try again.',
          ),
        );
      }
    }
  }

  void _applyPostImage(int postId, ContentImage image) {
    _setState(
      _state.copyWith(
        posts: _state.posts
            .map(
              (post) => post.id == postId
                  ? post.copyWith(
                      images: _sortedImages([...post.images, image]),
                    )
                  : post,
            )
            .toList(),
        selectedPost: _state.selectedPost?.id == postId
            ? _state.selectedPost!.copyWith(
                images: _sortedImages([..._state.selectedPost!.images, image]),
              )
            : _state.selectedPost,
        isBusy: false,
        clearPostError: true,
      ),
    );
  }

  void _setState(BlogState next) {
    if (_disposed) return;
    _state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

List<BlogPost> _replacePost(List<BlogPost> posts, BlogPost post) => posts
    .map(
      (existing) =>
          existing.id == post.id ? _mergePostImages(existing, post) : existing,
    )
    .toList();

BlogPost _mergePostImages(BlogPost existing, BlogPost incoming) =>
    incoming.images.isNotEmpty || existing.images.isEmpty
    ? incoming
    : incoming.copyWith(images: existing.images);

BlogComment _mergeCommentImages(BlogComment existing, BlogComment incoming) =>
    incoming.images.isNotEmpty || existing.images.isEmpty
    ? incoming
    : _copyCommentWithImages(incoming, existing.images);

BlogComment _copyCommentWithImages(
  BlogComment comment,
  List<ContentImage> images,
) => BlogComment(
  id: comment.id,
  postId: comment.postId,
  authorId: comment.authorId,
  body: comment.body,
  createdAt: comment.createdAt,
  updatedAt: comment.updatedAt,
  author: comment.author,
  images: images,
);

List<ContentImage> _sortedImages(List<ContentImage> images) {
  images.sort(compareImages);
  return images;
}
