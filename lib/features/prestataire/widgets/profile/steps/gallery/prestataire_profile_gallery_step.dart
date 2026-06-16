import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../../../core/logic/media/realisation_image_moderator.dart';
import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../core/models/domain/catalog/photo_realisation.dart';
import '../../../../../../core/models/domain/catalog/realisation_media_type.dart';
import '../../../../../../services/supabase/storage/storage_service.dart';
import '../../../../../../shared/theme/app_fonts.dart';
import '../../../../../../shared/theme/discovery_styles.dart';
import '../../../../../../shared/theme/app_colors.dart';
import '../../../../../../shared/widgets/prestataire/realisation_media_cover.dart';
import '../../hub/prestataire_hub_layout.dart';

import 'realisation_gallery_policy_banner.dart';

class PrestataireProfileGalleryStep extends StatelessWidget {
  const PrestataireProfileGalleryStep({
    super.key,
    required this.photos,
    required this.pendingFiles,
    required this.errorText,
    required this.uploading,
    required this.uploadProgress,
    required this.onPick,
    required this.onPickVideo,
    required this.onRemoveExisting,
    required this.onRemovePending,
    this.maxPhotos = 10,
    this.embeddedInHub = false,
  });

  final List<PhotoRealisation> photos;
  final List<StorageUploadFile> pendingFiles;
  final String? errorText;
  final bool uploading;
  final double? uploadProgress;
  final VoidCallback onPick;
  final VoidCallback onPickVideo;
  final ValueChanged<PhotoRealisation> onRemoveExisting;
  final ValueChanged<int> onRemovePending;
  final int maxPhotos;
  final bool embeddedInHub;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final total = photos.length + pendingFiles.length;
    final canAdd = total < maxPhotos && !uploading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const RealisationGalleryPolicyBanner(),
        const SizedBox(height: 12),
        if (RealisationImageModerator.supportsOnDeviceScan) ...[
          Text(
            DiscPrestaForm.galleryPolicyScanHint,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (embeddedInHub)
          PrestataireHubMetricBanner(
            icon: Icons.perm_media_outlined,
            label: 'Médias ajoutés',
            value: '$total / $maxPhotos',
            progress: maxPhotos > 0 ? total / maxPhotos : 0,
          )
        else
          Row(
            children: [
              Expanded(
                child: Text(
                  '$total / $maxPhotos ${DiscPrestaForm.hubGalleryMediaCount}',
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
          _GalleryEmptyState(
            onPickPhotos: canAdd ? onPick : null,
            onPickVideo: canAdd ? onPickVideo : null,
          )
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
                return _AddMediaTile(onPickPhotos: onPick, onPickVideo: onPickVideo);
              }
              final isPending = index >= photos.length;
              if (isPending) {
                final pendingIndex = index - photos.length;
                final file = pendingFiles[pendingIndex];
                return _MediaTile(
                  mediaType: file.mediaType,
                  memoryBytes: file.isVideo ? null : file.bytes,
                  localVideoPath: file.isVideo ? file.localPath : null,
                  onRemove: () => onRemovePending(pendingIndex),
                );
              }
              final photo = photos[index];
              return _MediaTile(
                mediaType: photo.mediaType,
                imageUrl: photo.url,
                onRemove: () => onRemoveExisting(photo),
              );
            },
          ),
          if (canAdd) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPick,
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: const Text(DiscPrestaForm.hubGalleryPick),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPickVideo,
                    icon: const Icon(Icons.videocam_outlined),
                    label: const Text(DiscPrestaForm.hubGalleryPickVideo),
                  ),
                ),
              ],
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
  const _GalleryEmptyState({
    required this.onPickPhotos,
    required this.onPickVideo,
  });

  final VoidCallback? onPickPhotos;
  final VoidCallback? onPickVideo;

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
            Icons.perm_media_outlined,
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
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onPickPhotos,
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: const Text(DiscPrestaForm.hubGalleryPick),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickVideo,
                  icon: const Icon(Icons.videocam_outlined),
                  label: const Text(DiscPrestaForm.hubGalleryPickVideo),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddMediaTile extends StatelessWidget {
  const _AddMediaTile({
    required this.onPickPhotos,
    required this.onPickVideo,
  });

  final VoidCallback onPickPhotos;
  final VoidCallback onPickVideo;

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
        onTap: onPickPhotos,
        onLongPress: onPickVideo,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: primary, size: 28),
            const SizedBox(height: 4),
            Text(
              DiscPrestaForm.hubGalleryAddTile,
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

class _MediaTile extends StatelessWidget {
  const _MediaTile({
    required this.mediaType,
    this.imageUrl,
    this.memoryBytes,
    this.localVideoPath,
    required this.onRemove,
  });

  final RealisationMediaType mediaType;
  final String? imageUrl;
  final Uint8List? memoryBytes;
  final String? localVideoPath;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: DiscoveryStyles.chipBorderRadius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RealisationMediaCover(
            mediaType: mediaType,
            imageUrl: imageUrl,
            memoryBytes: memoryBytes,
            localVideoPath: localVideoPath,
            playVideoPreview: mediaType.isVideo,
            showPlayBadge: mediaType.isVideo,
          ),
          if (mediaType.isVideo)
            Positioned(
              left: 4,
              bottom: 4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  child: Text(
                    DiscPrestaForm.hubGalleryVideoBadge,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
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
