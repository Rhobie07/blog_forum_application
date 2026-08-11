import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/blog_models.dart';

String publicStorageUrl(String storagePath) {
  try {
    return Supabase.instance.client.storage
        .from('post-images')
        .getPublicUrl(storagePath);
  } catch (_) {
    return storagePath;
  }
}

class MediaGallery extends StatelessWidget {
  const MediaGallery({
    super.key,
    required this.images,
    this.compact = false,
    this.parentPostId,
    this.parentCommentId,
    this.parentLabel,
    this.onRemove,
    this.removeEnabled = true,
    this.imageFit = BoxFit.cover,
  });

  final List<ContentImage> images;
  final bool compact;
  final int? parentPostId;
  final int? parentCommentId;
  final String? parentLabel;
  final ValueChanged<ContentImage>? onRemove;
  final bool removeEnabled;
  final BoxFit imageFit;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();
    final ordered = [...images]
      ..sort((a, b) => a.position.compareTo(b.position));
    return SizedBox(
      height: compact ? 104 : 260,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < ordered.length; i++)
              Padding(
                padding: EdgeInsets.only(
                  right: i < ordered.length - 1 ? 10 : 0,
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AspectRatio(
                        aspectRatio: compact ? 1.35 : 1.2,
                        child: Image.network(
                          publicStorageUrl(ordered[i].storagePath),
                          fit: imageFit,
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
                    if (onRemove != null)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          tooltip: removeEnabled
                              ? 'Remove image for this comment'
                              : 'Removing image for this comment',
                          onPressed: removeEnabled
                              ? () => onRemove!(ordered[i])
                              : null,
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
    );
  }
}
