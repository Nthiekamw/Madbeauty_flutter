import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/discovery_styles.dart';
import '../../../shared/utils/text_normalizer.dart';
import '../../prestataire/widgets/shared/prestataire_card_photo_header.dart';

const int _kMaxChipsCompact = 2;
const int _kMaxChipsExpanded = 4;

enum CatalogCardDensity { compact, expanded }

/// Carte catalogue (grille 2 col. ou liste étendue pleine largeur).
class PrestataireCatalogListCard extends StatelessWidget {
  const PrestataireCatalogListCard({
    super.key,
    required this.entry,
    this.density = CatalogCardDensity.compact,
    this.distanceKm,
    this.onCollapse,
  });

  final PrestataireCatalogEntry entry;
  final CatalogCardDensity density;
  final double? distanceKm;
  final VoidCallback? onCollapse;

  bool get _compact => density == CatalogCardDensity.compact;

  @override
  Widget build(BuildContext context) {
    if (_compact) {
      return _VerticalCatalogCard(entry: entry, compact: true);
    }
    return _ExpandedCatalogCard(
      entry: entry,
      distanceKm: distanceKm,
      onCollapse: onCollapse,
    );
  }
}

/// Pleine largeur : photo à gauche, infos détaillées à droite.
class _ExpandedCatalogCard extends StatelessWidget {
  const _ExpandedCatalogCard({
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
    final teaser = _teaserText(profile.description, profile.bio);
    final rating = profile.noteMoyenne;
    const photoWidth = 118.0;
    const minPhotoHeight = 120.0;

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
                                      _locationLabel(ville, distanceKm),
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
                                      .take(_kMaxChipsExpanded)
                                      .map((n) => _SpecialtyChip(label: n)),
                                  if (entry.specialtyNames.length >
                                      _kMaxChipsExpanded)
                                    _SpecialtyChip(
                                      label:
                                          '+${entry.specialtyNames.length - _kMaxChipsExpanded}',
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

  String? _teaserText(String? description, String? bio) {
    final d = description?.trim();
    if (d != null && d.isNotEmpty) return d;
    final b = bio?.trim();
    if (b != null && b.isNotEmpty) return b;
    return null;
  }
}

class _VerticalCatalogCard extends StatelessWidget {
  const _VerticalCatalogCard({
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
    const compactPhotoH = 76.0;
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
                      child: _RatingBadge(
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
                                    fontSize: 11.5,
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
                                  .take(_kMaxChipsCompact)
                                  .map((n) => _SpecialtyChip(label: n)),
                              if (entry.specialtyNames.length >
                                  _kMaxChipsCompact)
                                _SpecialtyChip(
                                  label:
                                      '+${entry.specialtyNames.length - _kMaxChipsCompact}',
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
        color: AppColors.scrimDark55,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: compact ? 12 : 14,
            color: AppColors.starGold,
          ),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 9.5 : 11,
              color: AppColors.white,
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
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
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
          fontSize: 10,
          color: muted
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

String _locationLabel(String ville, double? distanceKm) {
  final hasKm = distanceKm != null &&
      distanceKm.isFinite &&
      distanceKm < 500;
  if (hasKm) {
    return '$ville · ${DiscClientWorkspace.distanceKm(distanceKm)}';
  }
  return ville;
}

