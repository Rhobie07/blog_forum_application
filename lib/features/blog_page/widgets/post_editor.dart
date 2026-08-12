import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../models/blog_models.dart';
import 'media_gallery.dart';

class PostEditor extends StatefulWidget {
  const PostEditor({
    super.key,
    this.title,
    this.excerpt,
    this.content,
    this.postId,
    this.existingImages = const [],
    required this.onSubmit,
    this.onDeleteImage,
    this.isSaving = false,
  });

  final String? title;

  final String? excerpt;

  final String? content;

  final int? postId;

  final List<ContentImage> existingImages;

  final Future<String?> Function(
    String title,
    String excerpt,
    String content,
    List<XFile> images,
  )
  onSubmit;

  final void Function(ContentImage image)? onDeleteImage;

  final bool isSaving;

  @override
  State<PostEditor> createState() => _PostEditorState();
}

class _PostEditorState extends State<PostEditor> {
  late final TextEditingController _title = TextEditingController(
    text: widget.title ?? '',
  );

  late final TextEditingController _excerpt = TextEditingController(
    text: widget.excerpt ?? '',
  );

  late final TextEditingController _content = TextEditingController(
    text: widget.content ?? '',
  );

  String? _error;

  bool _saving = false;

  final _picker = ImagePicker();

  final List<XFile> _pendingFiles = [];

  final Set<int> _removedImageIds = {};

  @override
  void dispose() {
    _title.dispose();
    _excerpt.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final files = await _picker.pickMultiImage();
    if (files.isNotEmpty) {
      setState(() => _pendingFiles.addAll(files));
    }
  }

  void _removePending(int index) {
    setState(() => _pendingFiles.removeAt(index));
  }

  void _removeExistingImage(ContentImage image) {
    setState(() => _removedImageIds.add(image.id));
    widget.onDeleteImage?.call(image);
  }

  Future<void> _submit() async {
    if (_title.text.trim().isEmpty || _content.text.trim().isEmpty) {
      setState(() => _error = 'Title and content are required.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final error = await widget.onSubmit(
      _title.text,
      _excerpt.text,
      _content.text,
      List.unmodifiable(_pendingFiles),
    );
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _saving = false;
        _error = error;
      });
      return;
    }
    if (!mounted) return;
    context.pop();
  }

  List<Widget> get _existingImagesSection {
    final visible = widget.existingImages
        .where((i) => !_removedImageIds.contains(i.id))
        .toList();
    if (visible.isEmpty) return const [];
    return [
      const SizedBox(height: 12),
      MediaGallery(
        images: visible,
        compact: true,
        onRemove: _removeExistingImage,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      scrollable: true,
      title: Text(widget.postId != null ? 'Edit post' : 'New post'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _title,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Title'),
              ),

              SizedBox(height: 8),

              TextField(
                controller: _excerpt,
                decoration: const InputDecoration(labelText: 'Excerpt'),
              ),

              SizedBox(height: 8),

              TextField(
                controller: _content,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(labelText: 'Content'),
              ),
              ..._existingImagesSection,
              if (_pendingFiles.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 104,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _pendingFiles.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) => Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: AspectRatio(
                            aspectRatio: 1.35,
                            child: Image.network(
                              _pendingFiles[index].path,
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
                            onPressed: () => _removePending(index),
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
                ),
              ],
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _saving ? null : _pickImages,
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: const Text('Add images'),
                    ),
                  ],
                ),
              ),
              if (_error != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _error!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.isSaving || _saving ? null : () => context.pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: widget.isSaving || _saving ? null : _submit,
          child: Text(widget.isSaving || _saving ? 'Saving\u2026' : 'Save'),
        ),
      ],
    );
  }
}
