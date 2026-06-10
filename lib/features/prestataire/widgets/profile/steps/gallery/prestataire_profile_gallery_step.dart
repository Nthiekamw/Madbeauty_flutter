import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../core/models/domain/catalog/photo_realisation.dart';
import '../../../../../../shared/theme/app_fonts.dart';
import '../../../../../../shared/theme/discovery_styles.dart';
import '../../../../../../shared/theme/app_colors.dart';
import '../../hub/prestataire_hub_layout.dart';

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
    this.maxPhotos = 10,
    this.embeddedInHub = false,
  });

  final List<PhotoRealisation> photos;
  final List<Uint8List> pendingPreviews;
  final String? errorText;
  final bool uploading;
  final double? uploadProgress;
  final VoidCallback onPick;
  final ValueChanged<PhotoRealisation> onRemoveExisting;
  final ValueChanged<int> onRemovePending;
  final int maxPhotos;
  final bool embeddedInHub;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final total = photos.length + pendingPreviews.length;
    final canAdd = total < maxPhotos && !uploading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (embeddedInHub)
          PrestataireHubMetricBanner(
            icon: Icons.photo_library_outlined,
            label: 'Photos ajoutées',
            value: '$total / $maxPhotos',
            progress: maxPhotos > 0 ? total / maxPhotos : 0,
          )
        else
          Row(
            children: [
              Expanded(
                child: Text(
                  '$total / $maxPhotos photos',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w700,
                    color: primary,
                  ),
                ),
              ),
              if (total == 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer.withValues(
                      alpha: 0.6,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    DiscPrestaForm.hubBadgeRecommended,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        SizedBox(height: embeddedInHub ? 12 : 12),
        if (total == 0)
          _GalleryEmptyState(onPick: canAdd ? onPick : null)
        else ...[
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: total + (canAdd ? 1 : 0),
            itemBuilder: (context, index) {
              if (canAdd && index == total) {
                return _AddPhotoTile(onTap: onPick);
              }
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
          if (canAdd) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text(DiscPrestaForm.hubGalleryPick),
            ),
          ],
        ],
        if (uploading && uploadProgress != null) ...[
          const SizedBox(height: 12),
          LinearProgressIndicator(value: uploadProgress),
          const SizedBox(height: 6),
          Text(
            DiscPrestaForm.hubGalleryUploading,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
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

class _GalleryEmptyState extends StatelessWidget {
  const _GalleryEmptyState({required this.onPick});

  final VoidCallback? onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: primary.withValues(alpha: 0.06),
        border: Border.all(color: primary.withValues(alpha: 0.2), width: 1.2),
      ),
      child: Column(
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 48,
            color: primary.withValues(alpha: 0.85),
          ),
          const SizedBox(height: 12),
          Text(
            DiscPrestaForm.hubGalleryEmpty,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DiscPrestaForm.hubGalleryHint,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text(DiscPrestaForm.hubGalleryPick),
          ),
        ],
      ),
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Material(
      color: primary.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: DiscoveryStyles.chipBorderRadius,
        side: BorderSide(color: primary.withValues(alpha: 0.35), width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: primary, size: 28),
            const SizedBox(height: 4),
            Text(
              'Ajouter',
              style: theme.textTheme.labelSmall?.copyWith(
                color: primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({this.imageUrl, this.memoryBytes, required this.onRemove});

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
            const ColoredBox(color: AppColors.scrimDark12),
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
      color: AppColors.scrimDark54,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        iconSize: 18,
        onPressed: onPressed,
        icon: const Icon(Icons.close, color: AppColors.white),
      ),
    );
  }
}
