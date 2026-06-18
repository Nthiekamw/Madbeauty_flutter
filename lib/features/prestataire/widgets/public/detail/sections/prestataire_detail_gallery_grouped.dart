import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../core/models/domain/catalog/photo_realisation.dart';
import '../../../../../../core/models/domain/catalog/realisation_media_type.dart';
import '../../../../../../shared/layout/discovery_responsive.dart';
import '../../../../../../shared/theme/app_colors.dart';
import '../../../../../../shared/theme/discovery_styles.dart';
import '../../../../../../shared/widgets/gallery/fullscreen_realisation_gallery.dart';
import '../../../../../../shared/widgets/prestataire/realisation_media_cover.dart';
import '../../../../logic/realisation_gallery_grouping.dart';
import 'prestataire_detail_service_group_header.dart';

class PrestataireDetailGalleryGrouped extends StatelessWidget {
  const PrestataireDetailGalleryGrouped({
    super.key,
    required this.sections,
  });

  final List<RealisationPhotosServiceSection> sections;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final thumbWidth = DiscoveryResponsive.of(context).homeListCardWidth
        .clamp(108.0, 130.0);

    final allPhotos = sections
        .expand((s) => s.specialtyGroups)
        .expand((g) => g.photos)
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < sections.length; i++) ...[
          PrestataireDetailServiceGroupHeader(
            title: sections[i].serviceTitle,
            main: sections[i].main,
            compact: i == 0,
          ),
          for (final group in sections[i].specialtyGroups) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                group.specialtyLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            SizedBox(
              height: thumbWidth * 1.05,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: group.photos.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final photo = group.photos[index];
                  final globalIndex = allPhotos.indexOf(photo);
                  return _GalleryThumb(
                    photo: photo,
                    width: thumbWidth,
                    onTap: () => FullscreenRealisationGallery.open(
                      context,
                      items: allPhotos,
                      initialIndex: globalIndex < 0 ? index : globalIndex,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ],
    );
  }
}

class _GalleryThumb extends StatelessWidget {
  const _GalleryThumb({
    required this.photo,
    required this.width,
    required this.onTap,
  });

  final PhotoRealisation photo;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final radius = DiscoveryStyles.cardBorderRadius;

    return SizedBox(
      width: width,
      child: Material(
        color: AppColors.cardSurfaceFor(theme.brightness),
        elevation: isDark ? 0 : 1,
        shadowColor: AppColors.brandBrown.withValues(alpha: 0.08),
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: theme.colorScheme.outline.withValues(
                  alpha: isDark ? 0.2 : 0.08,
                ),
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                RealisationMediaCover(
                  mediaType: photo.mediaType,
                  imageUrl: photo.url,
                  playVideoPreview: photo.mediaType.isVideo,
                  showPlayBadge: photo.mediaType.isVideo,
                  playIconSize: 28,
                ),
                if (photo.mediaType.isVideo)
                  Positioned(
                    left: 6,
                    bottom: 6,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.videocam_rounded,
                              size: 10,
                              color: AppColors.white,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              DiscPrestaForm.hubGalleryVideoBadge,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
