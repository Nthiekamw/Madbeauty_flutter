import 'package:flutter/material.dart';

import '../../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/discovery_styles.dart';
import '../../../shared/utils/text_normalizer.dart';
import '../../prestataire/widgets/shared/prestataire_card_photo_header.dart';

const int _kMaxChips = 2;

/// Carte catalogue (liste verticale / grille recherche).
class PrestataireCatalogListCard extends StatelessWidget {
  const PrestataireCatalogListCard({
    super.key,
    required this.entry,
    this.compact = false,
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
    final photoH = compact ? 88.0 : DiscoveryStyles.catalogCardPhotoHeight;

    return Material(
      color: Colors.transparent,
      borderRadius: cardRadius,
      child: InkWell(
        onTap: () => context.pushPrestataireDetail(profile.id),
        borderRadius: cardRadius,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: cardRadius,
            color: theme.colorScheme.surface.withValues(
              alpha: isDark ? 0.92 : 0.98,
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
                      left: 8,
                      bottom: 8,
                      child: _RatingBadge(
                        rating: rating,
                        compact: compact,
                      ),
                    ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    compact ? 10 : 14,
                    compact ? 8 : 12,
                    compact ? 10 : 14,
                    compact ? 6 : 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              safeDisplay,
                              maxLines: compact ? 1 : 2,
                              overflow: TextOverflow.ellipsis,
                              style: (compact
                                      ? theme.textTheme.titleSmall
                                      : theme.textTheme.titleMedium)
                                  ?.copyWith(
                                fontFamily: AppFonts.display,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                                fontSize: compact ? 13 : null,
                              ),
                            ),
                          ),
                          if (profile.isVerified)
                            Padding(
                              padding: const EdgeInsets.only(left: 4, top: 1),
                              child: Icon(
                                Icons.verified_rounded,
                                color: primary,
                                size: compact ? 14 : 16,
                              ),
                            ),
                        ],
                      ),
                      if (ville != null && ville.isNotEmpty) ...[
                        SizedBox(height: compact ? 3 : 6),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: compact ? 11 : 14,
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
                                  fontSize: compact ? 10 : 12,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (!compact && entry.specialtyNames.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 5,
                          runSpacing: 5,
                          children: [
                            ...entry.specialtyNames.take(_kMaxChips).map(
                                  (n) => _SpecialtyChip(label: n),
                                ),
                            if (entry.specialtyNames.length > _kMaxChips)
                              _SpecialtyChip(
                                label:
                                    '+${entry.specialtyNames.length - _kMaxChips}',
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
                  horizontal: compact ? 10 : 14,
                  vertical: compact ? 7 : 10,
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
                        fontSize: compact ? 11 : null,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: compact ? 15 : 18,
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

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating, required this.compact});

  final double rating;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: compact ? 12 : 14,
            color: const Color(0xFFFBBF24),
          ),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 10 : 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecialtyChip extends StatelessWidget {
  const _SpecialtyChip({required this.label, this.muted = false});

  final String label;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: muted
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7)
            : theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelSmall?.copyWith(
          fontFamily: AppFonts.body,
          fontWeight: FontWeight.w600,
          color: muted
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
