import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/blog_models.dart';
import 'media_gallery.dart';

class CommentThread extends StatefulWidget {
  const CommentThread({
    super.key,
    required this.comments,
    this.postId = 0,
    this.currentUserId,
    this.onCreate,
    this.onUpdate,
    this.onDelete,
    this.onUploadImage,
    this.onDeleteImage,
    this.commentsLoading = false,
    this.onRetryComments,
    this.isBusy = false,
    this.error,
    this.onLogin,
  });

  final List<BlogComment> comments;
  final int postId;
  final String? currentUserId;
  final Future<String?> Function(int postId, String? body)? onCreate;
  final Future<String?> Function(int id, String body)? onUpdate;
  final Future<String?> Function(int id)? onDelete;
  final void Function(int commentId, XFile file, int position)? onUploadImage;
  final void Function(int commentId, ContentImage image)? onDeleteImage;
  final bool commentsLoading;
  final VoidCallback? onRetryComments;
  final bool isBusy;
  final String? error;
  final VoidCallback? onLogin;

  @override
  State<CommentThread> createState() => _CommentThreadState();
}

class _CommentThreadState extends State<CommentThread> {
  final _controller = TextEditingController();
  final _picker = ImagePicker();
  final List<XFile> _pendingImages = [];
  int? _pendingCreatePostId;
  String? _composerError;

  @override
  void didUpdateWidget(covariant CommentThread oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_pendingCreatePostId != null &&
        widget.comments.length > oldWidget.comments.length &&
        widget.onUploadImage != null) {
      final existingIds = oldWidget.comments.map((c) => c.id).toSet();
      for (final comment in widget.comments) {
        if (!existingIds.contains(comment.id) &&
            comment.postId == _pendingCreatePostId) {
          for (var i = 0; i < _pendingImages.length; i++) {
            widget.onUploadImage!(comment.id, _pendingImages[i], i);
          }
          _pendingImages.clear();
          _pendingCreatePostId = null;
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (widget.onCreate == null || widget.isBusy) return;
    if (_controller.text.trim().isEmpty && _pendingImages.isEmpty) return;
    setState(() => _composerError = null);
    final text = _controller.text.trim();
    final error = await widget.onCreate!(
      widget.postId,
      text.isEmpty ? null : text,
    );
    if (!mounted) return;
    if (error != null) {
      setState(() => _composerError = error);
    } else {
      if (_pendingImages.isNotEmpty) _pendingCreatePostId = widget.postId;
      _controller.clear();
    }
  }

  Future<void> _pickImages() async {
    final files = await _picker.pickMultiImage();
    if (files.isNotEmpty) setState(() => _pendingImages.addAll(files));
  }

  Future<void> _editComment(BlogComment comment) async {
    if (widget.onUpdate == null || widget.isBusy) return;
    final controller = TextEditingController(text: comment.body ?? '');
    final pendingEditImages = <XFile>[];
    final removedEditImageIds = <int>{};
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit comment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const Key('comment_edit_field'),
                controller: controller,
                minLines: 2,
                maxLines: 5,
              ),

              if (comment.images
                  .where((img) => !removedEditImageIds.contains(img.id))
                  .isNotEmpty) ...[
                const SizedBox(height: 12),
                MediaGallery(
                  images: comment.images
                      .where((img) => !removedEditImageIds.contains(img.id))
                      .toList(),
                  compact: true,
                  parentCommentId: comment.id,
                  parentLabel: 'comment ${comment.id}',
                  onRemove: widget.onDeleteImage == null
                      ? null
                      : (image) {
                          removedEditImageIds.add(image.id);
                          widget.onDeleteImage!(comment.id, image);
                          (dialogContext as Element).markNeedsBuild();
                        },
                ),
              ],

              if (pendingEditImages.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 104,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (var i = 0; i < pendingEditImages.length; i++)
                          Padding(
                            padding: EdgeInsets.only(
                              right: i < pendingEditImages.length - 1 ? 10 : 0,
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: AspectRatio(
                                    aspectRatio: 1.35,
                                    child: Image.network(
                                      pendingEditImages[i].path,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => ColoredBox(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surfaceContainerHighest,
                                        child: const Icon(
                                          Icons.image_not_supported_outlined,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: IconButton(
                                    onPressed: () {
                                      pendingEditImages.removeAt(i);
                                      (dialogContext as Element)
                                          .markNeedsBuild();
                                    },
                                    icon: const Icon(Icons.close),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.black54,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],

              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        final files = await _picker.pickMultiImage();
                        if (files.isNotEmpty) {
                          pendingEditImages.addAll(files);
                          (dialogContext as Element).markNeedsBuild();
                        }
                      },
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: const Text('Add images'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Save comment'),
          ),
        ],
      ),
    );

    if (result == null || result.trim().isEmpty || !mounted) return;
    final error = await widget.onUpdate!(comment.id, result);
    if (mounted) setState(() => _composerError = error);
    if (error == null &&
        pendingEditImages.isNotEmpty &&
        widget.onUploadImage != null) {
      for (var i = 0; i < pendingEditImages.length; i++) {
        widget.onUploadImage!(
          comment.id,
          pendingEditImages[i],
          comment.images.length + i,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Icon(
                Icons.forum_outlined,
                size: 20,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Comments',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        if (widget.commentsLoading) ...{
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: LinearProgressIndicator(),
          ),
        },

        if (widget.error != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  widget.error!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
              if (widget.onRetryComments != null)
                TextButton.icon(
                  onPressed: widget.commentsLoading
                      ? null
                      : widget.onRetryComments,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Retry'),
                ),
            ],
          ),

        if (widget.currentUserId == null && widget.onLogin != null)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 32,
                    color: theme.colorScheme.secondary.withAlpha(80),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Log in to join the conversation',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: widget.onLogin,
                    child: const Text('Log in'),
                  ),
                ],
              ),
            ),
          ),

        if (_composerError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              _composerError!,
              style: TextStyle(color: theme.colorScheme.error, fontSize: 13),
            ),
          ),

        if (widget.comments.isEmpty &&
            !widget.commentsLoading &&
            widget.currentUserId != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No comments yet. Be the first!',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
            ),
          ),

        ...widget.comments.expand(
          (comment) => [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: theme.colorScheme.secondary.withAlpha(
                        25,
                      ),
                      child: Text(
                        (comment.author?.displayName ?? 'A')[0].toUpperCase(),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              comment.author?.displayName ?? 'Anonymous',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (widget.currentUserId == comment.authorId) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withAlpha(
                                    15,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'you',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),

                        if (comment.body != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            comment.body!,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],

                        if (comment.images.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          MediaGallery(
                            images: comment.images,
                            compact: true,
                            parentCommentId: comment.id,
                            parentLabel: 'comment ${comment.id}',
                          ),
                        ],
                      ],
                    ),
                  ),

                  if (widget.currentUserId == comment.authorId)
                    Wrap(
                      spacing: 0,
                      children: [
                        IconButton(
                          onPressed: widget.isBusy
                              ? null
                              : () => _editComment(comment),
                          tooltip: 'Edit comment',
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          visualDensity: VisualDensity.compact,
                        ),
                        IconButton(
                          onPressed: widget.isBusy
                              ? null
                              : () => widget.onDelete?.call(comment.id),
                          tooltip: 'Delete comment',
                          icon: const Icon(Icons.delete_outline, size: 18),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const Divider(height: 4),
          ],
        ),

        if (widget.onCreate != null) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            minLines: 1,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Add a thoughtful comment',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
            ),
            style: theme.textTheme.bodyMedium,
          ),

          if (_pendingImages.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _pendingImages.length,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (context, index) => Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 1.35,
                        child: Image.network(
                          _pendingImages[index].path,
                          fit: BoxFit.cover,
                          width: 108,
                          errorBuilder: (_, _, _) => ColoredBox(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            child: const Icon(
                              Icons.image_not_supported_outlined,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: InkWell(
                        onTap: () =>
                            setState(() => _pendingImages.removeAt(index)),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(2),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 8),

          Row(
            children: [
              IconButton(
                onPressed: widget.isBusy ? null : _pickImages,
                icon: const Icon(Icons.add_photo_alternate_outlined, size: 20),
                tooltip: 'Add images',
                visualDensity: VisualDensity.compact,
              ),
              const Spacer(),
              FilledButton(
                onPressed: widget.isBusy ? null : _submit,
                child: const Text('Post comment'),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
