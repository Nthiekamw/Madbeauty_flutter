import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/geo/geo_point.dart';
import '../../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/utils/text_normalizer.dart';
import '../../prestataire/widgets/shared/prestataire_card_photo_header.dart';
import '../theme/home_styles.dart';

/// Carte prestataire pour listes horizontales de l'accueil client.
class PrestataireHomeListCard extends StatelessWidget {
  const PrestataireHomeListCard({
    super.key,
    required this.entry,
    this.distanceOrigin,
    this.cardWidth,
    this.cardHeight,
    this.photoHeight,
    this.dense = false,
  });

  final PrestataireCatalogEntry entry;
  final GeoPoint? distanceOrigin;
  final double? cardWidth;
  final double? cardHeight;
  final double? photoHeight;
  /// Typographie réduite (grille catalogue).
  final bool dense;

  /// Hauteur minimale réservée au bloc texte sous la photo.
  static const _minTextSectionHeight = 98.0;
  static const _minTextSectionHeightDense = 70.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final profile = entry.profile;
    final title = normalizeSingleLineText(entry.displayName);
    final safeTitle = title.isEmpty ? 'Salon' : title;
    final specialty = entry.specialtyNames.isNotEmpty
        ? entry.specialtyNames.first
        : null;
    final ville = profile.ville?.trim();
    final origin = distanceOrigin;
    final km = origin != null ? entry.distanceKmFrom(origin) : double.infinity;
    final rating = profile.noteMoyenne;
    final radius = HomeStyles.cardBorderRadius;
    final w = cardWidth ?? HomeStyles.listCardWidth;
    final h = cardHeight;
    final rawPhotoH = photoHeight ?? HomeStyles.listCardPhotoHeight;
    final minTextH = dense ? _minTextSectionHeightDense : _minTextSectionHeight;
    final photoH = h != null
        ? math.min(rawPhotoH, h - minTextH).clamp(dense ? 64.0 : 72.0, h * 0.58)
        : rawPhotoH;

    return Material(
      color: AppColors.cardSurfaceFor(theme.brightness),
      elevation: isDark ? 0 : 1,
      shadowColor: AppColors.brandBrown.withValues(alpha: 0.08),
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.pushPrestataireDetail(profile.id),
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: theme.colorScheme.outline.withValues(
                alpha: isDark ? 0.28 : 0.08,
              ),
            ),
          ),
          child: SizedBox(
            width: w,
            height: h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PrestataireCardPhotoHeader(
                  prestataireId: profile.id,
                  height: photoH,
                  width: w,
                  borderRadius: BorderRadius.only(
                    topLeft: radius.topLeft,
                    topRight: radius.topRight,
                  ),
                  fallbackDisplayName: safeTitle,
                  fallbackAvatarUrl: entry.avatarUrl,
                  compactBadge: true,
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      dense ? 8 : 10,
                      dense ? 4 : 6,
                      dense ? 8 : 10,
                      dense ? 5 : 8,
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: dense
                          ? SizedBox(
                              width: w - (dense ? 16 : 20),
                              child: _CardTextBody(
                                theme: theme,
                                safeTitle: safeTitle,
                                specialty: specialty,
                                rating: rating,
                                reviewCount: entry.reviewCount,
                                ville: ville,
                                km: km,
                                dense: true,
                              ),
                            )
                          : FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.topLeft,
                              child: SizedBox(
                                width: w - 20,
                                child: _CardTextBody(
                                  theme: theme,
                                  safeTitle: safeTitle,
                                  specialty: specialty,
                                  rating: rating,
                                  reviewCount: entry.reviewCount,
                                  ville: ville,
                                  km: km,
                                  dense: false,
                                ),
                              ),
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

class _CardTextBody extends StatelessWidget {
  const _CardTextBody({
    required this.theme,
    required this.safeTitle,
    required this.specialty,
    required this.rating,
    required this.reviewCount,
    required this.ville,
    required this.km,
    this.dense = false,
  });

  final ThemeData theme;
  final String safeTitle;
  final String? specialty;
  final double? rating;
  final int? reviewCount;
  final String? ville;
  final double km;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final showSpecialty =
        !dense && specialty != null && specialty!.isNotEmpty;
    final locationLine = _locationLine();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          safeTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          style: theme.textTheme.titleSmall?.copyWith(
            fontFamily: AppFonts.display,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
            height: 1.05,
            fontSize: dense ? 11 : 14,
          ),
        ),
        if (showSpecialty) ...[
          const SizedBox(height: 2),
          Text(
            specialty!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12,
              height: 1.1,
            ),
          ),
        ],
        if (!dense && rating != null) ...[
          const SizedBox(height: 3),
          Row(
            children: [
              Icon(
                Icons.star_rounded,
                size: 13,
                color: AppColors.starRating,
              ),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  DiscHome.ratingWithReviews(rating!, reviewCount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                    height: 1.05,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (locationLine != null) ...[
          SizedBox(height: dense ? 2 : 2),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: dense ? 10 : 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  locationLine,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: dense ? 8.5 : 11,
                    height: 1.05,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String? _locationLine() {
    if (ville == null || ville!.isEmpty) return null;
    final hasKm = !km.isInfinite && !km.isNaN;
    if (hasKm) {
      return '$ville · ${DiscClientWorkspace.distanceKm(km)}';
    }
    return ville;
  }
}
