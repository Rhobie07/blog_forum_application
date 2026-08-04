import 'package:biog_forum_application/core/redux/app_state.dart';
import 'package:biog_forum_application/features/blog_page/data/blog_repository.dart';
import 'package:biog_forum_application/features/blog_page/models/blog_models.dart';
import 'package:image_picker/image_picker.dart';
import 'package:redux/redux.dart';
import 'blog_actions.dart';

Middleware<AppState> createBlogMiddleware(BlogRepository repository) =>
    (store, action, next) {
      if (action is LoadPostsRequested) {
        if (store.state.blog.postsLoading) {
          next(action);
          return;
        }
      }
      next(action);

      if (action is LoadPostsRequested) {
        _loadFeed(store, repository, action);
      } else if (action is LoadPostRequested) {
        _loadDetail(store, repository, action);
      } else if (action is LoadCommentsRequested) {
        _loadComments(store, repository, action);
      } else if (action is CreatePostRequested) {
        _create(store, repository, action);
      } else if (action is UpdatePostRequested) {
        _update(store, repository, action);
      } else if (action is DeletePostRequested) {
        _delete(store, repository, action);
      } else if (action is CreateCommentRequested) {
        _createComment(store, repository, action);
      } else if (action is UpdateCommentRequested) {
        _updateComment(store, repository, action);
      } else if (action is DeleteCommentRequested) {
        _deleteComment(store, repository, action);
      } else if (action is UploadPostImageRequested) {
        _uploadPostImage(store, repository, action);
      } else if (action is DeletePostImageRequested) {
        _deletePostImage(store, repository, action);
      } else if (action is UploadCommentImageRequested) {
        _uploadCommentImage(store, repository, action);
      } else if (action is DeleteCommentImageRequested) {
        _deleteCommentImage(store, repository, action);
      }
    };

Future<void> _loadFeed(
  Store<AppState> s,
  BlogRepository r,
  LoadPostsRequested a,
) async {
  try {
    final page = await r.listPublishedPage(page: a.page);
    s.dispatch(
      LoadPostsSucceeded(
        page.posts,
        currentPage: page.currentPage,
        totalPages: page.totalPages,
      ),
    );
  } catch (e) {
    s.dispatch(LoadPostsFailed('$e'));
  }
}

Future<void> _loadDetail(
  Store<AppState> s,
  BlogRepository r,
  LoadPostRequested a,
) async {
  try {
    s.dispatch(LoadPostSucceeded(await r.fetchPost(a.postId)));
  } catch (e) {
    s.dispatch(LoadPostFailed('$e'));
  }
}

Future<void> _loadComments(
  Store<AppState> s,
  BlogRepository r,
  LoadCommentsRequested a,
) async {
  try {
    s.dispatch(LoadCommentsSucceeded(await r.listComments(a.postId)));
  } catch (e) {
    s.dispatch(LoadCommentsFailed('$e'));
  }
}

Future<void> _create(
  Store<AppState> s,
  BlogRepository r,
  CreatePostRequested a,
) async {
  late final BlogPost created;
  try {
    created = await r.create(
      title: a.title,
      excerpt: a.excerpt,
      content: a.content,
    );
  } catch (_) {
    s.dispatch(
      const CreatePostFailed('Unable to save changes. Please try again.'),
    );
    return;
  }
  s.dispatch(PostCreated(created));
  await _uploadSavedPostImages(s, r, created.id, a.images);
}

Future<void> _update(
  Store<AppState> s,
  BlogRepository r,
  UpdatePostRequested a,
) async {
  late final BlogPost updated;
  try {
    updated = await r.update(
      id: a.id,
      title: a.title,
      excerpt: a.excerpt,
      content: a.content,
    );
  } catch (_) {
    s.dispatch(
      const UpdatePostFailed('Unable to save changes. Please try again.'),
    );
    return;
  }
  s.dispatch(PostUpdated(updated));
  await _uploadSavedPostImages(s, r, updated.id, a.images);
}

Future<void> _uploadSavedPostImages(
  Store<AppState> s,
  BlogRepository r,
  int postId,
  List<XFile> images,
) async {
  for (var position = 0; position < images.length; position++) {
    try {
      final image = await r.uploadPostImage(
        postId: postId,
        file: images[position],
        position: position,
      );
      s.dispatch(PostImageUploaded(postId, image));
    } catch (_) {
      s.dispatch(
        const UploadPostImageFailed('Unable to save image. Please try again.'),
      );
    }
  }
}

Future<void> _delete(
  Store<AppState> s,
  BlogRepository r,
  DeletePostRequested a,
) async {
  try {
    await r.delete(a.id);
    s.dispatch(PostDeleted(a.id));
  } catch (_) {
    s.dispatch(
      const DeletePostFailed('Unable to delete post. Please try again.'),
    );
  }
}

Future<void> _createComment(
  Store<AppState> s,
  BlogRepository r,
  CreateCommentRequested a,
) async {
  try {
    final created = await r.createComment(postId: a.postId, body: a.body);
    s.dispatch(CommentCreated(created));
  } catch (_) {
    s.dispatch(
      const CreateCommentFailed('Unable to save comment. Please try again.'),
    );
  }
}

Future<void> _updateComment(
  Store<AppState> s,
  BlogRepository r,
  UpdateCommentRequested a,
) async {
  try {
    s.dispatch(CommentUpdated(await r.updateComment(id: a.id, body: a.body)));
  } catch (_) {
    s.dispatch(
      const UpdateCommentFailed('Unable to save comment. Please try again.'),
    );
  }
}

Future<void> _deleteComment(
  Store<AppState> s,
  BlogRepository r,
  DeleteCommentRequested a,
) async {
  try {
    await r.deleteComment(a.id);
    s.dispatch(CommentDeleted(a.id));
  } catch (_) {
    s.dispatch(
      const DeleteCommentFailed('Unable to delete comment. Please try again.'),
    );
  }
}

Future<void> _uploadPostImage(
  Store<AppState> s,
  BlogRepository r,
  UploadPostImageRequested a,
) async {
  try {
    s.dispatch(
      PostImageUploaded(
        a.postId,
        await r.uploadPostImage(
          postId: a.postId,
          file: a.file,
          position: a.position,
        ),
      ),
    );
  } catch (_) {
    s.dispatch(
      const UploadPostImageFailed('Unable to save image. Please try again.'),
    );
  }
}

Future<void> _deletePostImage(
  Store<AppState> s,
  BlogRepository r,
  DeletePostImageRequested a,
) async {
  try {
    await r.deletePostImage(a.image);
    s.dispatch(PostImageDeleted(a.postId, a.image.id));
  } catch (_) {
    s.dispatch(
      const DeletePostImageFailed('Unable to delete image. Please try again.'),
    );
  }
}

Future<void> _uploadCommentImage(
  Store<AppState> s,
  BlogRepository r,
  UploadCommentImageRequested a,
) async {
  try {
    s.dispatch(
      CommentImageUploaded(
        a.commentId,
        await r.uploadCommentImage(
          commentId: a.commentId,
          file: a.file,
          position: a.position,
        ),
      ),
    );
  } catch (_) {
    s.dispatch(
      const UploadCommentImageFailed('Unable to save image. Please try again.'),
    );
  }
}

Future<void> _deleteCommentImage(
  Store<AppState> s,
  BlogRepository r,
  DeleteCommentImageRequested a,
) async {
  try {
    await r.deleteCommentImage(a.image);
    s.dispatch(CommentImageDeleted(a.commentId, a.image.id));
  } catch (_) {
    s.dispatch(
      const DeleteCommentImageFailed(
        'Unable to delete image. Please try again.',
      ),
    );
  }
}
