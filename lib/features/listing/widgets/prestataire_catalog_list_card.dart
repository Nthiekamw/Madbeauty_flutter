import 'package:flutter/material.dart';

import '../../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/discovery_styles.dart';
import '../../prestataire/widgets/prestataire_card_photo_header.dart';

const int _kMaxChips = 3;

/// Carte catalogue (liste verticale) : réalisations, nom, spécialités, note, ville.
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
    final display = entry.displayName;
    final rating = profile.noteMoyenne;
    final screenW = MediaQuery.sizeOf(context).width;
    final isNarrow = screenW < 360;
    final dense = compact || isNarrow;
    final cardRadius = DiscoveryStyles.catalogListCardBorderRadius;
    final photoH = compact ? 92.0 : DiscoveryStyles.catalogCardPhotoHeight;

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
              color: primary.withValues(alpha: isDark ? 0.1 : 0.08),
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PrestataireCardPhotoHeader(
                prestataireId: profile.id,
                height: photoH,
                borderRadius: BorderRadius.only(
                  topLeft: cardRadius.topLeft,
                  topRight: cardRadius.topRight,
                ),
                fallbackDisplayName: display,
                fallbackAvatarUrl: url,
                compactBadge: compact,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  dense ? 8 : 14,
                  dense ? 8 : 12,
                  dense ? 8 : 14,
                  dense ? 6 : 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            display,
                            maxLines: compact ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                            style: (compact
                                    ? theme.textTheme.titleSmall
                                    : theme.textTheme.titleMedium)
                                ?.copyWith(
                              fontFamily: AppFonts.display,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                        ),
                        if (profile.isVerified)
                          Padding(
                            padding: const EdgeInsets.only(left: 6, top: 2),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.verified_rounded,
                                color: primary,
                                size: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (ville != null && ville.isNotEmpty) ...[
                      SizedBox(height: compact ? 4 : 6),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: compact ? 12 : 14,
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
                                fontSize: compact ? 11 : null,
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
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 8 : 14,
                  vertical: compact ? 6 : 10,
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
                    if (rating != null) ...[
                      Icon(
                        Icons.star_rounded,
                        size: compact ? 14 : 16,
                        color: const Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        rating.toStringAsFixed(1),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontFamily: AppFonts.body,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFF59E0B),
                          fontSize: compact ? 11 : null,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: compact ? 16 : 18,
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
