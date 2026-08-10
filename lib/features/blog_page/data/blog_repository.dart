import 'dart:math';

import 'package:biog_forum_application/features/blog_page/models/blog_models.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef PostPage = ({List<BlogPost> posts, int currentPage, int totalPages});

class BlogRepository {
  BlogRepository(this.client);

  final SupabaseClient client;

  static const _selection = '*, profiles(*)';
  static const _commentSelection = '*, profiles(*), comment_images(*)';

  static const _storageBucket = 'post-images';

  String get _ownerId =>
      client.auth.currentUser?.id ??
      (throw StateError('An authenticated user is required'));

  Future<PostPage> listPublishedPage({int page = 1, int limit = 10}) async {
    final total =
        (await client.from('posts').select('id').eq('status', 'published'))
            .length;
    final totalPages = total > 0 ? (total / limit).ceil() : 0;

    final start = (page - 1) * limit;
    final end = start + limit - 1;
    final rows = await client
        .from('posts')
        .select(_selection)
        .eq('status', 'published')
        .order('created_at', ascending: false)
        .order('id', ascending: false)
        .range(start, end < start ? start : end);
    final posts = rows.whereType<Json>().map(BlogPost.fromJson).toList();
    posts.sort(_comparePosts);

    final images = await _listImages('post_images', posts.map((p) => p.id));
    final byPost = <int, List<ContentImage>>{};
    for (final image in images) {
      byPost
          .putIfAbsent(image['post_id'] as int, () => [])
          .add(ContentImage.fromJson(image));
    }
    return (
      posts: posts
          .map((post) => post.copyWith(images: byPost[post.id] ?? const []))
          .toList(),
      currentPage: page,
      totalPages: totalPages,
    );
  }

  Future<BlogPost> fetchPost(int id) async {
    final row = await client
        .from('posts')
        .select(_selection)
        .eq('id', id)
        .single();
    final post = BlogPost.fromJson(row);
    final images = await _listImages('post_images', [id]);
    return post.copyWith(images: images.map(ContentImage.fromJson).toList());
  }

  Future<List<BlogComment>> listComments(int postId) async {
    final rows = await client
        .from('comments')
        .select(_commentSelection)
        .eq('post_id', postId)
        .order('created_at')
        .order('id');
    return rows.whereType<Json>().map(BlogComment.fromJson).toList();
  }

  Future<BlogComment> createComment({required int postId, String? body}) async {
    final values = <String, dynamic>{'post_id': postId};
    if (body != null) values['body'] = body;
    final row = await client
        .from('comments')
        .insert(values)
        .select(_commentSelection)
        .single();
    return BlogComment.fromJson(row);
  }

  Future<BlogComment> updateComment({
    required int id,
    required String body,
  }) async {
    final row = await client
        .from('comments')
        .update({'body': body})
        .eq('id', id)
        .select(_commentSelection)
        .single();
    return BlogComment.fromJson(row);
  }

  Future<bool> deleteComment(int id) async {
    final rows = await client
        .from('comments')
        .delete()
        .eq('id', id)
        .select('id');
    return rows.isNotEmpty;
  }

  Future<BlogPost> create({
    required String title,
    required String excerpt,
    required String content,
  }) async {
    final row = await client
        .from('posts')
        .insert({'title': title, 'excerpt': excerpt, 'content': content})
        .select(_selection)
        .single();
    return BlogPost.fromJson(row);
  }

  Future<BlogPost> update({
    required int id,
    required String title,
    required String excerpt,
    required String content,
  }) async {
    final row = await client
        .from('posts')
        .update({'title': title, 'excerpt': excerpt, 'content': content})
        .eq('id', id)
        .select(_selection)
        .single();
    return BlogPost.fromJson(row);
  }

  Future<bool> delete(int id) async {
    final rows = await client.from('posts').delete().eq('id', id).select('id');
    return rows.isNotEmpty;
  }

  Future<ContentImage> uploadPostImage({
    required int postId,
    required XFile file,
    required int position,
  }) async {
    final extension = _extension(file);
    final contentType = _contentType(extension);
    final bytes = await file.readAsBytes();
    final path = '$_ownerId/$postId/${_uuid()}.$extension';
    await client.storage
        .from(_storageBucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(upsert: false, contentType: contentType),
        );
    final row = await client
        .from('post_images')
        .insert({'post_id': postId, 'storage_path': path, 'position': position})
        .select()
        .single();
    return ContentImage.fromJson(row);
  }

  Future<void> deletePostImage(ContentImage image) async {
    await client.storage.from(_storageBucket).remove([image.storagePath]);
    await client.from('post_images').delete().eq('id', image.id);
  }

  Future<ContentImage> uploadCommentImage({
    required int commentId,
    required XFile file,
    required int position,
  }) async {
    final extension = _extension(file);
    final contentType = _contentType(extension);
    final bytes = await file.readAsBytes();
    final path = '$_ownerId/$commentId/${_uuid()}.$extension';
    await client.storage
        .from(_storageBucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(upsert: false, contentType: contentType),
        );
    final row = await client
        .from('comment_images')
        .insert({
          'comment_id': commentId,
          'storage_path': path,
          'position': position,
        })
        .select()
        .single();
    return ContentImage.fromJson(row);
  }

  Future<void> deleteCommentImage(ContentImage image) async {
    await client.storage.from(_storageBucket).remove([image.storagePath]);
    await client.from('comment_images').delete().eq('id', image.id);
  }

  Future<List<Json>> _listImages(String table, Iterable<int> parentIds) async {
    if (parentIds.isEmpty) return const [];
    final key = table == 'post_images' ? 'post_id' : 'comment_id';
    return (await client
            .from(table)
            .select('*')
            .inFilter(key, parentIds.toList())
            .order('position')
            .order('id'))
        .whereType<Json>()
        .toList();
  }
}

int _comparePosts(BlogPost a, BlogPost b) {
  final created = b.createdAt.compareTo(a.createdAt);
  return created == 0 ? b.id.compareTo(a.id) : created;
}

String _extension(XFile file) {
  final name = file.name.isNotEmpty ? file.name : file.path.split('/').last;
  final dot = name.lastIndexOf('.');
  if (dot < 0 || dot == name.length - 1) {
    throw const FormatException('Image file must have a supported extension.');
  }
  final result = name.substring(dot + 1).toLowerCase();
  _contentType(result);
  return result;
}

String _contentType(String extension) {
  switch (extension) {
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
    case 'webp':
      return 'image/webp';
    default:
      throw FormatException('Unsupported image extension: .$extension');
  }
}

String _uuid() {
  final random = Random.secure();

  String block(int length) =>
      List.generate(length, (_) => random.nextInt(16).toRadixString(16)).join();
  return '${block(8)}-${block(4)}-4${block(3)}-${(8 + random.nextInt(4)).toRadixString(16)}${block(3)}-${block(12)}';
}
