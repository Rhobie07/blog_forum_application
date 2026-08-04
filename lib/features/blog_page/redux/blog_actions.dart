import 'package:biog_forum_application/features/blog_page/models/blog_models.dart';
import 'package:image_picker/image_picker.dart';

class LoadPostsRequested {
  const LoadPostsRequested({this.page = 1});

  final int page;
}

class LoadPostsSucceeded {
  const LoadPostsSucceeded(
    this.posts, {
    required this.currentPage,
    required this.totalPages,
  });

  final List<BlogPost> posts;
  final int currentPage;
  final int totalPages;
}

class LoadPostsFailed {
  const LoadPostsFailed(this.message);
  final String message;
}

class LoadPostRequested {
  const LoadPostRequested(this.postId);
  final int postId;
}

class LoadPostSucceeded {
  const LoadPostSucceeded(this.post);
  final BlogPost post;
}

class LoadPostFailed {
  const LoadPostFailed(this.message);
  final String message;
}

class LoadCommentsRequested {
  const LoadCommentsRequested(this.postId);
  final int postId;
}

class LoadCommentsSucceeded {
  const LoadCommentsSucceeded(this.comments);
  final List<BlogComment> comments;
}

class LoadCommentsFailed {
  const LoadCommentsFailed(this.message);
  final String message;
}

class CreatePostRequested {
  const CreatePostRequested(this.title, this.excerpt, this.content);
  final String title;
  final String excerpt;
  final String content;
}

class PostCreated {
  const PostCreated(this.post);
  final BlogPost post;
}

class CreatePostFailed {
  const CreatePostFailed(this.message);
  final String message;
}

class UpdatePostRequested {
  const UpdatePostRequested(this.id, this.title, this.excerpt, this.content);
  final int id;
  final String title;
  final String excerpt;
  final String content;
}

class PostUpdated {
  const PostUpdated(this.post);
  final BlogPost post;
}

class UpdatePostFailed {
  const UpdatePostFailed(this.message);
  final String message;
}

class DeletePostRequested {
  const DeletePostRequested(this.id);
  final int id;
}

class PostDeleted {
  const PostDeleted(this.id);
  final int id;
}

class DeletePostFailed {
  const DeletePostFailed(this.message);
  final String message;
}

class CreateCommentRequested {
  const CreateCommentRequested(this.postId, this.body);
  final int postId;
  final String? body;
}

class CommentCreated {
  const CommentCreated(this.comment);
  final BlogComment comment;
}

class CreateCommentFailed {
  const CreateCommentFailed(this.message);
  final String message;
}

class UpdateCommentRequested {
  const UpdateCommentRequested(this.id, this.body);
  final int id;
  final String body;
}

class CommentUpdated {
  const CommentUpdated(this.comment);
  final BlogComment comment;
}

class UpdateCommentFailed {
  const UpdateCommentFailed(this.message);
  final String message;
}

class DeleteCommentRequested {
  const DeleteCommentRequested(this.id);
  final int id;
}

class CommentDeleted {
  const CommentDeleted(this.id);
  final int id;
}

class DeleteCommentFailed {
  const DeleteCommentFailed(this.message);
  final String message;
}

class UploadPostImageRequested {
  const UploadPostImageRequested(this.postId, this.file, this.position);
  final int postId;
  final XFile file;
  final int position;
}

class PostImageUploaded {
  const PostImageUploaded(this.postId, this.image);
  final int postId;
  final ContentImage image;
}

class UploadPostImageFailed {
  const UploadPostImageFailed(this.message);
  final String message;
}

class DeletePostImageRequested {
  const DeletePostImageRequested(this.postId, this.image);
  final int postId;
  final ContentImage image;
}

class PostImageDeleted {
  const PostImageDeleted(this.postId, this.imageId);
  final int postId;
  final int imageId;
}

class DeletePostImageFailed {
  const DeletePostImageFailed(this.message);
  final String message;
}

class UploadCommentImageRequested {
  const UploadCommentImageRequested(this.commentId, this.file, this.position);
  final int commentId;
  final XFile file;
  final int position;
}

class CommentImageUploaded {
  const CommentImageUploaded(this.commentId, this.image);
  final int commentId;
  final ContentImage image;
}

class UploadCommentImageFailed {
  const UploadCommentImageFailed(this.message);
  final String message;
}

class DeleteCommentImageRequested {
  const DeleteCommentImageRequested(this.commentId, this.image);
  final int commentId;
  final ContentImage image;
}

class CommentImageDeleted {
  const CommentImageDeleted(this.commentId, this.imageId);
  final int commentId;
  final int imageId;
}

class DeleteCommentImageFailed {
  const DeleteCommentImageFailed(this.message);
  final String message;
}
