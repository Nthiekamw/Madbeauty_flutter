import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../../../core/constants/prestataire/prestataire_service_catalog.dart';
import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../core/models/domain/catalog/photo_realisation.dart';
import '../../../../../../core/models/domain/catalog/realisation_media_type.dart';
import '../../../../../../shared/theme/app_fonts.dart';
import '../../../../../../shared/theme/discovery_styles.dart';
import '../../../../../../shared/theme/app_colors.dart';
import '../../../../../../shared/widgets/prestataire/realisation_media_cover.dart';
import '../../../../logic/realisation_gallery_grouping.dart';
import '../../../../models/pending_realisation_upload.dart';
import '../../../public/detail/sections/prestataire_detail_service_group_header.dart';
import '../../hub/prestataire_hub_layout.dart';

import 'realisation_gallery_policy_banner.dart';

class PrestataireProfileGalleryStep extends StatelessWidget {
  const PrestataireProfileGalleryStep({
    super.key,
    required this.photos,
    required this.pendingUploads,
    required this.slots,
    required this.errorText,
    required this.uploading,
    required this.uploadProgress,
    required this.onPickForSlot,
    required this.onPickVideoForSlot,
    required this.onRemoveExisting,
    required this.onRemovePending,
    this.maxPhotos = 10,
    this.embeddedInHub = false,
  });

  final List<PhotoRealisation> photos;
  final List<PendingRealisationUpload> pendingUploads;
  final List<RealisationGallerySlot> slots;
  final String? errorText;
  final bool uploading;
  final double? uploadProgress;
  final ValueChanged<RealisationGallerySlot> onPickForSlot;
  final ValueChanged<RealisationGallerySlot> onPickVideoForSlot;
  final ValueChanged<PhotoRealisation> onRemoveExisting;
  final ValueChanged<PendingRealisationUpload> onRemovePending;
  final int maxPhotos;
  final bool embeddedInHub;

  int get _totalMediaCount => photos.length + pendingUploads.length;

  bool get _canAddMore => _totalMediaCount < maxPhotos && !uploading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = _totalMediaCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const RealisationGalleryPolicyBanner(),
        const SizedBox(height: 12),
        Text(
          DiscPrestaForm.galleryPolicyScanHint,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 10),
        if (embeddedInHub)
          PrestataireHubMetricBanner(
            icon: Icons.perm_media_outlined,
            label: DiscPrestaForm.hubGalleryMediaAdded,
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
                    color: theme.colorScheme.primary,
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
        const SizedBox(height: 12),
        Text(
          DiscPrestaForm.hubGalleryBySpecialtyHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        if (slots.isEmpty)
          _NeedsServicesState()
        else
          ..._buildServiceSections(context),
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

  List<Widget> _buildServiceSections(BuildContext context) {
    final sections = <Widget>[];
    var sectionIndex = 0;

    for (final main in PrestaMainService.values) {
      final mainSlots = slots.where((s) => s.main == main).toList();
      if (mainSlots.isEmpty) continue;

      sections.add(
        PrestataireDetailServiceGroupHeader(
          title: PrestataireServiceCatalog.label(main),
          main: main,
          compact: sectionIndex == 0,
        ),
      );
      sectionIndex++;

      for (final slot in mainSlots) {
        sections.add(
          _SpecialtyGallerySection(
            slot: slot,
            photos: photos
                .where(
                  (p) => realisationPhotoMatchesSlot(
                    p,
                    slot,
                    allSlots: slots,
                  ),
                )
                .toList(),
            pendingUploads: pendingUploads
                .where(
                  (u) => pendingUploadMatchesSlot(
                    u,
                    slot,
                    allSlots: slots,
                  ),
                )
                .toList(),
            canAdd: _canAddMore,
            onPickPhotos: () => onPickForSlot(slot),
            onPickVideo: () => onPickVideoForSlot(slot),
            onRemoveExisting: onRemoveExisting,
            onRemovePending: onRemovePending,
          ),
        );
      }
    }

    return sections;
  }
}

class _NeedsServicesState extends StatelessWidget {
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
            Icons.category_outlined,
            size: 48,
            color: primary.withValues(alpha: 0.85),
          ),
          const SizedBox(height: 12),
          Text(
            DiscPrestaForm.galleryNeedsServices,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecialtyGallerySection extends StatelessWidget {
  const _SpecialtyGallerySection({
    required this.slot,
    required this.photos,
    required this.pendingUploads,
    required this.canAdd,
    required this.onPickPhotos,
    required this.onPickVideo,
    required this.onRemoveExisting,
    required this.onRemovePending,
  });

  final RealisationGallerySlot slot;
  final List<PhotoRealisation> photos;
  final List<PendingRealisationUpload> pendingUploads;
  final bool canAdd;
  final VoidCallback onPickPhotos;
  final VoidCallback onPickVideo;
  final ValueChanged<PhotoRealisation> onRemoveExisting;
  final ValueChanged<PendingRealisationUpload> onRemovePending;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = photos.length + pendingUploads.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            slot.specialtyLabel,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          if (total == 0 && !canAdd)
            Text(
              DiscPrestaForm.hubGalleryEmpty,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            SizedBox(
              height: 108,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: total + (canAdd ? 1 : 0),
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  if (canAdd && index == total) {
                    return _AddMediaTile(
                      onPickPhotos: onPickPhotos,
                      onPickVideo: onPickVideo,
                    );
                  }
                  final isPending = index >= photos.length;
                  if (isPending) {
                    final upload = pendingUploads[index - photos.length];
                    return SizedBox(
                      width: 108,
                      child: _MediaTile(
                        mediaType: upload.file.mediaType,
                        memoryBytes:
                            upload.file.isVideo ? null : upload.file.bytes,
                        localVideoPath:
                            upload.file.isVideo ? upload.file.localPath : null,
                        onRemove: () => onRemovePending(upload),
                      ),
                    );
                  }
                  final photo = photos[index];
                  return SizedBox(
                    width: 108,
                    child: _MediaTile(
                      mediaType: photo.mediaType,
                      imageUrl: photo.url,
                      onRemove: () => onRemoveExisting(photo),
                    ),
                  );
                },
              ),
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

    return SizedBox(
      width: 108,
      child: Material(
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
