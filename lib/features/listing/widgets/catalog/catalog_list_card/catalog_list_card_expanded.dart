import 'package:flutter/material.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../../../../router/navigation_extensions.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_fonts.dart';
import '../../../../../shared/theme/discovery_styles.dart';
import '../../../../../shared/utils/text_normalizer.dart';
import '../../../../prestataire/widgets/shared/prestataire_card_photo_header.dart';
import 'catalog_list_card_shared.dart';

/// Pleine largeur : photo à gauche, infos détaillées à droite.
class ExpandedCatalogListCard extends StatelessWidget {
  const ExpandedCatalogListCard({
    super.key,
    required this.entry,
    this.distanceKm,
    this.onCollapse,
  });

  final PrestataireCatalogEntry entry;
  final double? distanceKm;
  final VoidCallback? onCollapse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final profile = entry.profile;
    final cardRadius = DiscoveryStyles.catalogListCardBorderRadius;
    final display = normalizeSingleLineText(entry.displayName);
    final safeDisplay = display.isEmpty ? 'Salon' : display;
    final salon = profile.nomSalon?.trim();
    final showSalon =
        salon != null && salon.isNotEmpty && salon != safeDisplay;
    final ville = profile.ville?.trim();
    final specialty = entry.specialtyNames.isNotEmpty
        ? entry.specialtyNames.first
        : null;
    final teaser = catalogCardTeaserText(profile.description, profile.bio);
    final rating = profile.noteMoyenne;
    const photoWidth = 132.0;
    const minPhotoHeight = 136.0;

    return Material(
      color: theme.colorScheme.surfaceContainerHigh.withValues(
        alpha: isDark ? 1 : 0.98,
      ),
      elevation: isDark ? 0 : 1,
      shadowColor: primary.withValues(alpha: 0.08),
      borderRadius: cardRadius,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          InkWell(
            onTap: () => context.pushPrestataireDetail(profile.id),
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: photoWidth),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    safeDisplay,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        theme.textTheme.titleSmall?.copyWith(
                                      fontFamily: AppFonts.display,
                                      fontWeight: FontWeight.w800,
                                      height: 1.15,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ),
                                if (profile.isVerified)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Icon(
                                      Icons.verified_rounded,
                                      color: primary,
                                      size: 18,
                                    ),
                                  ),
                              ],
                            ),
                            if (showSalon) ...[
                              const SizedBox(height: 2),
                              Text(
                                salon,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                            if (specialty != null && specialty.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                specialty,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                            if (ville != null && ville.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 11,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      catalogCardLocationLabel(
                                        ville,
                                        distanceKm,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                        fontSize: 10,
                                        height: 1.05,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (rating != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    size: 14,
                                    color: AppColors.starRating,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DiscHome.ratingWithReviews(
                                      rating,
                                      entry.reviewCount,
                                    ),
                                    style:
                                        theme.textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: theme.colorScheme.onSurface,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (entry.specialtyNames.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 5,
                                runSpacing: 5,
                                children: [
                                  ...entry.specialtyNames
                                      .take(kCatalogMaxChipsExpanded)
                                      .map(
                                        (n) => CatalogCardSpecialtyChip(
                                          label: n,
                                        ),
                                      ),
                                  if (entry.specialtyNames.length >
                                      kCatalogMaxChipsExpanded)
                                    CatalogCardSpecialtyChip(
                                      label:
                                          '+${entry.specialtyNames.length - kCatalogMaxChipsExpanded}',
                                      muted: true,
                                    ),
                                ],
                              ),
                            ],
                            if (teaser != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                teaser,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  height: 1.35,
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: OutlinedButton(
                                onPressed: () => context
                                    .pushPrestataireDetail(profile.id),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: theme.colorScheme.primary,
                                  side: BorderSide(
                                    color: theme.colorScheme.primary
                                        .withValues(alpha: 0.55),
                                  ),
                                  minimumSize: const Size(0, 32),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  textStyle: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: const Text('Voir le profil'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  bottom: 0,
                  width: photoWidth,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final h = constraints.maxHeight;
                      final photoHeight =
                          h.isFinite && h > 0 ? h : minPhotoHeight;
                      return PrestataireCardPhotoHeader(
                        prestataireId: profile.id,
                        height: photoHeight,
                        width: photoWidth,
                        borderRadius: BorderRadius.only(
                          topLeft: cardRadius.topLeft,
                          bottomLeft: cardRadius.bottomLeft,
                        ),
                        fallbackDisplayName: safeDisplay,
                        fallbackAvatarUrl: entry.avatarUrl,
                        compactBadge: true,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (onCollapse != null)
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: theme.colorScheme.surface.withValues(alpha: 0.94),
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onCollapse,
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.close_fullscreen_rounded,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
