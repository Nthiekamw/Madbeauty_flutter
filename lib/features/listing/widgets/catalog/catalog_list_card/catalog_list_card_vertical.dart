import 'package:flutter/material.dart';

import '../../../../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../../../../router/navigation_extensions.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_fonts.dart';
import '../../../../../shared/theme/discovery_styles.dart';
import '../../../../../shared/utils/text_normalizer.dart';
import '../../../../prestataire/widgets/shared/prestataire_card_photo_header.dart';
import 'catalog_list_card_shared.dart';

/// Carte catalogue verticale (grille compacte ou variante non-compacte).
class VerticalCatalogListCard extends StatelessWidget {
  const VerticalCatalogListCard({
    super.key,
    required this.entry,
    required this.compact,
  });

  final PrestataireCatalogEntry entry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final profile = entry.profile;
    final ville = profile.ville?.trim();
    final url = entry.avatarUrl;
    final display = normalizeSingleLineText(entry.displayName);
    final safeDisplay = display.isEmpty ? 'Salon' : display;
    final rating = profile.noteMoyenne;
    final cardRadius = DiscoveryStyles.catalogListCardBorderRadius;
    const compactPhotoH = 92.0;
    final photoH =
        compact ? compactPhotoH : DiscoveryStyles.catalogCardPhotoHeight;

    return Material(
      color: AppColors.transparent,
      borderRadius: cardRadius,
      child: InkWell(
        onTap: () => context.pushPrestataireDetail(profile.id),
        borderRadius: cardRadius,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: cardRadius,
            color: theme.colorScheme.surfaceContainerHigh.withValues(
              alpha: isDark ? 1 : 0.98,
            ),
            border: Border.all(
              color: primary.withValues(alpha: isDark ? 0.12 : 0.1),
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.07),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  PrestataireCardPhotoHeader(
                    prestataireId: profile.id,
                    height: photoH,
                    borderRadius: BorderRadius.only(
                      topLeft: cardRadius.topLeft,
                      topRight: cardRadius.topRight,
                    ),
                    fallbackDisplayName: safeDisplay,
                    fallbackAvatarUrl: url,
                    compactBadge: compact,
                  ),
                  if (rating != null)
                    Positioned(
                      left: compact ? 6 : 8,
                      bottom: compact ? 6 : 8,
                      child: CatalogCardRatingBadge(
                        rating: rating,
                        compact: compact,
                      ),
                    ),
                ],
              ),
              if (compact)
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 6, 8, 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  safeDisplay,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontFamily: AppFonts.display,
                                    fontWeight: FontWeight.w800,
                                    height: 1.1,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ),
                              if (profile.isVerified)
                                Padding(
                                  padding: const EdgeInsets.only(left: 2),
                                  child: Icon(
                                    Icons.verified_rounded,
                                    color: primary,
                                    size: 12,
                                  ),
                                ),
                            ],
                          ),
                          if (ville != null && ville.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  size: 9,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 2),
                                Expanded(
                                  child: Text(
                                    ville,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontSize: 9,
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
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
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontFamily: AppFonts.display,
                                  fontWeight: FontWeight.w800,
                                  height: 1.15,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                            if (profile.isVerified)
                              Padding(
                                padding: const EdgeInsets.only(left: 4, top: 1),
                                child: Icon(
                                  Icons.verified_rounded,
                                  color: primary,
                                  size: 16,
                                ),
                              ),
                          ],
                        ),
                        if (ville != null && ville.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 14,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  ville,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontSize: 11,
                                    height: 1.2,
                                  ),
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
                                  .take(kCatalogMaxChipsCompact)
                                  .map(
                                    (n) => CatalogCardSpecialtyChip(label: n),
                                  ),
                              if (entry.specialtyNames.length >
                                  kCatalogMaxChipsCompact)
                                CatalogCardSpecialtyChip(
                                  label:
                                      '+${entry.specialtyNames.length - kCatalogMaxChipsCompact}',
                                  muted: true,
                                ),
                            ],
                          ),
                        ],
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 8 : 14,
                  vertical: compact ? 5 : 10,
                ),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: isDark ? 0.07 : 0.04),
                  borderRadius: BorderRadius.only(
                    bottomLeft: cardRadius.bottomLeft,
                    bottomRight: cardRadius.bottomRight,
                  ),
                  border: Border(
                    top: BorderSide(
                      color: primary.withValues(alpha: isDark ? 0.1 : 0.07),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      compact ? 'Voir' : 'Voir le profil',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontFamily: AppFonts.body,
                        fontWeight: FontWeight.w700,
                        color: primary,
                        fontSize: compact ? 10 : null,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: compact ? 14 : 18,
                      color: primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
