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
    this.showAvailableBadge = false,
  });

  final PrestataireCatalogEntry entry;
  final CatalogCardDensity density;
  final double? distanceKm;
  final bool showAvailableBadge;

  bool get _compact => density == CatalogCardDensity.compact;

  @override
  Widget build(BuildContext context) {
    if (_compact) {
      return _VerticalCatalogCard(entry: entry, compact: true);
    }
    return _ExpandedCatalogCard(
      entry: entry,
      distanceKm: distanceKm,
      showAvailableBadge: showAvailableBadge,
    );
  }
}

/// Pleine largeur : photo à gauche, infos détaillées à droite.
class _ExpandedCatalogCard extends StatelessWidget {
  const _ExpandedCatalogCard({
    required this.entry,
    this.distanceKm,
    this.showAvailableBadge = false,
  });

  final PrestataireCatalogEntry entry;
  final double? distanceKm;
  final bool showAvailableBadge;

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
    final cp = profile.codePostal?.trim();
    final location = [
      if (ville != null && ville.isNotEmpty) ville,
      if (cp != null && cp.isNotEmpty) cp,
    ].join(' Â· ');
    final teaser = _teaserText(profile.description, profile.bio);
    final rating = profile.noteMoyenne;
    const photoWidth = 112.0;

    return Material(
      color: AppColors.transparent,
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
              color: primary.withValues(alpha: isDark ? 0.14 : 0.1),
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: photoWidth,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      PrestataireCardPhotoHeader(
                        prestataireId: profile.id,
                        height: 132,
                        borderRadius: BorderRadius.only(
                          topLeft: cardRadius.topLeft,
                          bottomLeft: cardRadius.bottomLeft,
                        ),
                        fallbackDisplayName: safeDisplay,
                        fallbackAvatarUrl: entry.avatarUrl,
                        compactBadge: false,
                      ),
                      if (showAvailableBadge)
                        const Positioned(
                          left: 6,
                          bottom: 6,
                          child: _AvailableBadge(),
                        )
                      else if (rating != null)
                        Positioned(
                          left: 6,
                          bottom: 6,
                          child: _RatingBadge(rating: rating, compact: false),
                        ),
                    ],
                  ),
                ),
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
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontFamily: AppFonts.display,
                                  fontWeight: FontWeight.w800,
                                  height: 1.15,
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
                            ),
                          ),
                        ],
                        if (location.isNotEmpty ||
                            (distanceKm != null &&
                                distanceKm!.isFinite &&
                                distanceKm! < 500)) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  [
                                    if (location.isNotEmpty) location,
                                    if (distanceKm != null &&
                                        distanceKm!.isFinite &&
                                        distanceKm! < 500)
                                      DiscClientWorkspace.distanceKm(
                                        distanceKm!,
                                      ),
                                  ].join(' Â· '),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
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
                                size: 16,
                                color: AppColors.starAmber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                rating.toStringAsFixed(1),
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
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
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton(
                            onPressed: () =>
                                context.pushPrestataireDetail(profile.id),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(0, 36),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
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
          ),
        ),
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
                                    size: 13,
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
                                  size: 10,
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
                                      fontSize: 10,
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
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontFamily: AppFonts.display,
                                  fontWeight: FontWeight.w800,
                                  height: 1.15,
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
                                    fontSize: 12,
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
                        fontSize: compact ? 10.5 : null,
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

class _AvailableBadge extends StatelessWidget {
  const _AvailableBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.availableBadge,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        DiscClientWorkspace.availableBadge,
        style: const TextStyle(
          fontFamily: AppFonts.body,
          fontWeight: FontWeight.w700,
          fontSize: 10,
          color: AppColors.white,
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
              fontSize: compact ? 10 : 12,
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

