import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/domain/catalog/photo_realisation.dart';
import '../../../../shared/theme/discovery_styles.dart';

class PrestataireProfileGalleryStep extends StatelessWidget {
  const PrestataireProfileGalleryStep({
    super.key,
    required this.photos,
    required this.pendingPreviews,
    required this.errorText,
    required this.uploading,
    required this.uploadProgress,
    required this.onPick,
    required this.onRemoveExisting,
    required this.onRemovePending,
  });

  final List<PhotoRealisation> photos;
  final List<Uint8List> pendingPreviews;
  final String? errorText;
  final bool uploading;
  final double? uploadProgress;
  final VoidCallback onPick;
  final ValueChanged<PhotoRealisation> onRemoveExisting;
  final ValueChanged<int> onRemovePending;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = photos.length + pendingPreviews.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DiscPrestaCompletion.galleryHint,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          DiscPrestaCompletion.gallerySkipHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: uploading ? null : onPick,
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: const Text(DiscPrestaCompletion.galleryPick),
        ),
        if (uploading && uploadProgress != null) ...[
          const SizedBox(height: 12),
          LinearProgressIndicator(value: uploadProgress),
          const SizedBox(height: 6),
          Text(
            DiscPrestaCompletion.galleryUploading,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 16),
        if (total == 0)
          Text(
            DiscPrestaCompletion.galleryEmpty,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: total,
            itemBuilder: (context, index) {
              final isPending = index >= photos.length;
              if (isPending) {
                final pendingIndex = index - photos.length;
                return _PhotoTile(
                  memoryBytes: pendingPreviews[pendingIndex],
                  onRemove: () => onRemovePending(pendingIndex),
                );
              }
              final photo = photos[index];
              return _PhotoTile(
                imageUrl: photo.url,
                onRemove: () => onRemoveExisting(photo),
              );
            },
          ),
        if (errorText != null) ...[
          const SizedBox(height: 10),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    this.imageUrl,
    this.memoryBytes,
    required this.onRemove,
  });

  final String? imageUrl;
  final Uint8List? memoryBytes;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final bytes = memoryBytes;
    final url = imageUrl;

    return ClipRRect(
      borderRadius: DiscoveryStyles.chipBorderRadius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (bytes != null)
            Image.memory(bytes, fit: BoxFit.cover)
          else if (url != null)
            Image.network(url, fit: BoxFit.cover)
          else
            const ColoredBox(color: Colors.black12),
          Positioned(
            top: 4,
            right: 4,
            child: _RemoveButton(onPressed: onRemove),
          ),
        ],
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        iconSize: 18,
        onPressed: onPressed,
        icon: const Icon(Icons.close, color: Colors.white),
      ),
    );
  }
}
