import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/blog_models.dart';
import 'media_gallery.dart';

typedef EditDialogResult = ({
  String text,
  List<XFile> pendingImages,
  Set<int> removedImageIds,
});

class EditCommentDialog extends StatefulWidget {
  const EditCommentDialog({
    super.key,
    required this.comment,
    required this.picker,
    this.onDeleteImage,
  });

  final BlogComment comment;
  final ImagePicker picker;
  final void Function(int commentId, ContentImage image)? onDeleteImage;

  @override
  State<EditCommentDialog> createState() => EditCommentDialogState();
}

class EditCommentDialogState extends State<EditCommentDialog> {
  late final TextEditingController _controller;
  final List<XFile> _pendingImages = [];
  final Set<int> _removedImageIds = {};
  String? _editError;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.comment.body ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit comment'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('comment_edit_field'),
              controller: _controller,
              minLines: 2,
              maxLines: 5,
            ),

            if (_editError != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _editError!,
                  key: const Key('comment_edit_error'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],

            if (widget.comment.images
                .where((img) => !_removedImageIds.contains(img.id))
                .isNotEmpty) ...[
              const SizedBox(height: 12),
              MediaGallery(
                images: widget.comment.images
                    .where((img) => !_removedImageIds.contains(img.id))
                    .toList(),
                compact: true,
                onRemove: widget.onDeleteImage == null
                    ? null
                    : (image) => setState(() {
                        _removedImageIds.add(image.id);
                        _editError = null;
                      }),
              ),
            ],

            if (_pendingImages.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 104,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (var i = 0; i < _pendingImages.length; i++)
                        Padding(
                          padding: EdgeInsets.only(
                            right: i < _pendingImages.length - 1 ? 10 : 0,
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: AspectRatio(
                                  aspectRatio: 1.35,
                                  child: Image.network(
                                    _pendingImages[i].path,
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
                                  onPressed: () => setState(
                                    () => _pendingImages.removeAt(i),
                                  ),
                                  icon: const Icon(Icons.close),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.scrim,
                                    foregroundColor: Theme.of(
                                      context,
                                    ).colorScheme.onInverseSurface,
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
                      final files = await widget.picker.pickMultiImage();
                      if (files.isNotEmpty) {
                        setState(() {
                          _pendingImages.addAll(files);
                          _editError = null;
                        });
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
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final hasExistingImage = widget.comment.images.any(
              (image) => !_removedImageIds.contains(image.id),
            );
            if (_controller.text.trim().isEmpty &&
                !hasExistingImage &&
                _pendingImages.isEmpty) {
              setState(
                () => _editError =
                    'A comment must include text or at least one image.',
              );
              return;
            }
            Navigator.pop(context, (
              text: _controller.text.trim(),
              pendingImages: List<XFile>.of(_pendingImages),
              removedImageIds: Set<int>.of(_removedImageIds),
            ));
          },
          child: const Text('Save comment'),
        ),
      ],
    );
  }
}
