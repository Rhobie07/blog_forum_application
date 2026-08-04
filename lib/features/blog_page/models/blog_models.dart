class Profile {
  const Profile({required this.id, required this.displayName, this.avatarUrl});

  final String id;
  final String displayName;
  final String? avatarUrl;

  factory Profile.fromJson(Json json) => Profile(
    id: json['id'] as String,
    displayName: json['display_name'] as String? ?? '',
    avatarUrl: json['avatar_url'] as String?,
  );

  @override
  bool operator ==(Object other) =>
      other is Profile &&
      other.id == id &&
      other.displayName == displayName &&
      other.avatarUrl == avatarUrl;

  @override
  int get hashCode => Object.hash(id, displayName, avatarUrl);
}

class ContentImage {
  const ContentImage({
    required this.id,
    required this.storagePath,
    required this.position,
  });

  final int id;

  final String storagePath;

  final int position;

  factory ContentImage.fromJson(Json json) => ContentImage(
    id: (json['id'] as num).toInt(),
    storagePath: json['storage_path'] as String,
    position: (json['position'] as num).toInt(),
  );

  @override
  bool operator ==(Object other) =>
      other is ContentImage &&
      other.id == id &&
      other.storagePath == storagePath &&
      other.position == position;

  @override
  int get hashCode => Object.hash(id, storagePath, position);
}

class BlogPost {
  static const Object _authorUnset = Object();

  factory BlogPost({
    required int id,
    required String authorId,
    required String title,
    required String excerpt,
    required String content,
    required bool published,
    required DateTime createdAt,
    required DateTime updatedAt,
    Profile? author,
    List<ContentImage> images = const <ContentImage>[],
  }) => BlogPost._(
    id: id,
    authorId: authorId,
    title: title,
    excerpt: excerpt,
    content: content,
    published: published,
    createdAt: createdAt,
    updatedAt: updatedAt,
    author: author,
    images: List.unmodifiable(images),
  );

  const BlogPost._({
    required this.id,
    required this.authorId,
    required this.title,
    required this.excerpt,
    required this.content,
    required this.published,
    required this.createdAt,
    required this.updatedAt,
    this.author,
    required this.images,
  });

  final int id;
  final String authorId;
  final String title;
  final String excerpt;
  final String content;
  final bool published;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Profile? author;
  final List<ContentImage> images;

  factory BlogPost.fromJson(Json json) => BlogPost(
    id: (json['id'] as num).toInt(),
    authorId: json['author_id'] as String,
    title: json['title'] as String,
    excerpt: json['excerpt'] as String? ?? '',
    content: json['content'] as String,
    published: (json['published'] as bool?) ?? json['status'] == 'published',
    createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
    updatedAt: DateTime.parse(json['updated_at'] as String).toUtc(),
    author: json['profiles'] is Json
        ? Profile.fromJson(json['profiles'] as Json)
        : null,
    images: _readImages(json['post_images']),
  );

  BlogPost copyWith({
    String? title,
    String? excerpt,
    String? content,
    bool? published,
    DateTime? updatedAt,
    Object? author = _authorUnset,
    List<ContentImage>? images,
  }) => BlogPost(
    id: id,
    authorId: authorId,
    title: title ?? this.title,
    excerpt: excerpt ?? this.excerpt,
    content: content ?? this.content,
    published: published ?? this.published,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    author: identical(author, _authorUnset) ? this.author : author as Profile?,
    images: images ?? this.images,
  );

  @override
  bool operator ==(Object other) =>
      other is BlogPost &&
      other.id == id &&
      other.authorId == authorId &&
      other.title == title &&
      other.excerpt == excerpt &&
      other.content == content &&
      other.published == published &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.author == author &&
      _listEquals(other.images, images);

  @override
  int get hashCode => Object.hash(
    id,
    authorId,
    title,
    excerpt,
    content,
    published,
    createdAt,
    updatedAt,
    author,
    _listHash(images),
  );
}

class BlogComment {
  factory BlogComment({
    required int id,
    required int postId,
    required String authorId,
    String? body,
    required DateTime createdAt,
    required DateTime updatedAt,
    Profile? author,
    List<ContentImage> images = const <ContentImage>[],
  }) => BlogComment._(
    id: id,
    postId: postId,
    authorId: authorId,
    body: body,
    createdAt: createdAt,
    updatedAt: updatedAt,
    author: author,
    images: List.unmodifiable(images),
  );

  const BlogComment._({
    required this.id,
    required this.postId,
    required this.authorId,
    this.body,
    required this.createdAt,
    required this.updatedAt,
    this.author,
    required this.images,
  });

  final int id;
  final int postId;
  final String authorId;
  final String? body;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Profile? author;
  final List<ContentImage> images;

  factory BlogComment.fromJson(Json json) => BlogComment(
    id: (json['id'] as num).toInt(),
    postId: (json['post_id'] as num).toInt(),
    authorId: json['author_id'] as String,
    body: json['body'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
    updatedAt: DateTime.parse(json['updated_at'] as String).toUtc(),
    author: json['profiles'] is Json
        ? Profile.fromJson(json['profiles'] as Json)
        : null,
    images: _readImages(json['comment_images']),
  );

  @override
  bool operator ==(Object other) =>
      other is BlogComment &&
      other.id == id &&
      other.postId == postId &&
      other.authorId == authorId &&
      other.body == body &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.author == author &&
      _listEquals(other.images, images);

  @override
  int get hashCode => Object.hash(
    id,
    postId,
    authorId,
    body,
    createdAt,
    updatedAt,
    author,
    _listHash(images),
  );
}

typedef Json = Map<String, dynamic>;

List<ContentImage> _readImages(Object? value) {
  if (value == null) return const <ContentImage>[];
  if (value is! List) {
    throw const FormatException('Nested media must be a list of objects.');
  }
  final rows = <Json>[];

  for (final item in value) {
    if (item is! Json) {
      throw const FormatException('Nested media items must be objects.');
    }
    rows.add(item);
  }
  final images = rows.map(ContentImage.fromJson).toList()
    ..sort((a, b) {
      final position = a.position.compareTo(b.position);
      return position == 0 ? a.id.compareTo(b.id) : position;
    });
  return List.unmodifiable(images);
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

int _listHash<T>(List<T> values) => Object.hashAll(values);
