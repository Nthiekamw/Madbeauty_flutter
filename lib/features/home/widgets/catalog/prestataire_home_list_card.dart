import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/geo/geo_point.dart';
import '../../../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../../../router/navigation_extensions.dart';
import '../../../../shared/layout/discovery_responsive.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/utils/text_normalizer.dart';
import '../../../prestataire/widgets/shared/prestataire_card_photo_header.dart';
import '../../theme/home_styles.dart';

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
    this.showDistanceOnPhoto = false,
    this.showRatingOnPhoto = false,
  });

  final PrestataireCatalogEntry entry;
  final GeoPoint? distanceOrigin;
  final double? cardWidth;
  final double? cardHeight;
  final double? photoHeight;
  /// Typographie réduite (grille catalogue).
  final bool dense;
  final bool showDistanceOnPhoto;
  final bool showRatingOnPhoto;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final layout = DiscoveryResponsive.of(context);
    final profile = entry.profile;
    final title = normalizeSingleLineText(entry.displayName);
    final safeTitle = title.isEmpty ? 'Salon' : title;
    final specialty = entry.specialtyNames.isNotEmpty
        ? entry.specialtyNames.first
        : null;
    final ville = profile.ville?.trim();
    final origin = distanceOrigin;
    final km = origin != null ? entry.distanceKmFrom(origin) : double.infinity;
    final distanceLabel = (!km.isInfinite && !km.isNaN)
        ? DiscHome.nearbyKm(km)
        : null;
    final rating = profile.noteMoyenne;
    final radius = HomeStyles.cardBorderRadius;
    final w = cardWidth ?? layout.homeListCardWidth;
    final h = cardHeight ?? layout.homeListCardHeight;
    final rawPhotoH = photoHeight ?? layout.homeListPhotoHeightFor(h);
    // Garde au moins 1 px pour la zone texte (évite overflow / Expanded négatif).
    final photoH = rawPhotoH.clamp(0.0, (h - 1).clamp(0.0, h));
    final textZoneH = (h - photoH).clamp(0.0, h);
    final textPadH = dense ? 6.0 : 8.0;
    final titleSize = layout.homeListTitleFontSize(w);
    final bodySize = layout.homeListBodyFontSize(w);

    return SizedBox(
      width: w,
      height: h,
      child: Material(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PhotoSection(
                  profileId: profile.id,
                  width: w,
                  radius: radius,
                  safeTitle: safeTitle,
                  avatarUrl: entry.avatarUrl,
                  showDistanceOnPhoto: showDistanceOnPhoto,
                  showRatingOnPhoto: showRatingOnPhoto,
                  distanceLabel: distanceLabel,
                  rating: rating,
                  height: photoH,
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      textPadH,
                      dense ? 2 : 3,
                      textPadH,
                      dense ? 2 : 3,
                    ),
                    child: ClipRect(
                      child: _CardTextBody(
                        theme: theme,
                        isDark: isDark,
                        safeTitle: safeTitle,
                        isVerified: profile.isVerified,
                        specialty: specialty,
                        rating: rating,
                        reviewCount: entry.reviewCount,
                        ville: ville,
                        km: km,
                        dense: dense,
                        titleSize: titleSize,
                        bodySize: bodySize,
                        textZoneHeight: textZoneH,
                        showDistanceOnPhoto: showDistanceOnPhoto,
                        showRatingOnPhoto: showRatingOnPhoto,
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

class _PhotoSection extends StatelessWidget {
  const _PhotoSection({
    required this.profileId,
    required this.width,
    required this.radius,
    required this.safeTitle,
    required this.avatarUrl,
    required this.showDistanceOnPhoto,
    required this.showRatingOnPhoto,
    required this.distanceLabel,
    required this.rating,
    required this.height,
  });

  final String profileId;
  final double width;
  final BorderRadius radius;
  final String safeTitle;
  final String? avatarUrl;
  final bool showDistanceOnPhoto;
  final bool showRatingOnPhoto;
  final String? distanceLabel;
  final double? rating;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        children: [
          PrestataireCardPhotoHeader(
            prestataireId: profileId,
            height: height,
            width: width,
            borderRadius: BorderRadius.only(
              topLeft: radius.topLeft,
              topRight: radius.topRight,
            ),
            fallbackDisplayName: safeTitle,
            fallbackAvatarUrl: avatarUrl,
            compactBadge: true,
            microOverlay: true,
            coverAlignment: const Alignment(0, -0.12),
          ),
          if (showDistanceOnPhoto && distanceLabel != null)
            Positioned(
              left: 5,
              bottom: 5,
              child: _PhotoPill(
                icon: Icons.near_me_rounded,
                label: distanceLabel!,
              ),
            ),
          if (showRatingOnPhoto && rating != null)
            Positioned(
              left: 5,
              bottom: 5,
              child: _PhotoPill(
                icon: Icons.star_rounded,
                label: rating!.toStringAsFixed(1),
                iconColor: AppColors.starRating,
              ),
            ),
        ],
      ),
    );
  }
}

class _CardTextBody extends StatelessWidget {
  const _CardTextBody({
    required this.theme,
    required this.isDark,
    required this.safeTitle,
    required this.isVerified,
    required this.specialty,
    required this.rating,
    required this.reviewCount,
    required this.ville,
    required this.km,
    required this.titleSize,
    required this.bodySize,
    required this.textZoneHeight,
    this.dense = false,
    this.showDistanceOnPhoto = false,
    this.showRatingOnPhoto = false,
  });

  final ThemeData theme;
  final bool isDark;
  final String safeTitle;
  final bool isVerified;
  final String? specialty;
  final double? rating;
  final int? reviewCount;
  final String? ville;
  final double km;
  final double titleSize;
  final double bodySize;
  final double textZoneHeight;
  final bool dense;
  final bool showDistanceOnPhoto;
  final bool showRatingOnPhoto;

  Color get _titleColor => isDark
      ? AppColors.white.withValues(alpha: 0.96)
      : theme.colorScheme.onSurface;

  Color get _bodyColor => isDark
      ? AppColors.white.withValues(alpha: 0.82)
      : theme.colorScheme.onSurfaceVariant;

  @override
  Widget build(BuildContext context) {
    final showSpecialty = specialty != null && specialty!.isNotEmpty;
    final locationLine =
        showDistanceOnPhoto ? null : _locationLine();
    final showRating = !showRatingOnPhoto && rating != null;
    final tightText = textZoneHeight < 52;
    final showRatingLine = showRating && !(tightText && showSpecialty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                safeTitle,
                maxLines: dense || tightText ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w800,
                  color: _titleColor,
                  height: 1.1,
                  fontSize: titleSize,
                ),
              ),
            ),
            if (isVerified)
              Padding(
                padding: EdgeInsets.only(left: dense ? 2 : 3),
                child: Icon(
                  Icons.verified_rounded,
                  color: theme.colorScheme.primary,
                  size: (titleSize + 2).clamp(12.0, 16.0),
                ),
              ),
          ],
        ),
        if (showSpecialty) ...[
          const SizedBox(height: 1),
          Text(
            specialty!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: _bodyColor,
              fontSize: bodySize,
              height: 1.1,
            ),
          ),
        ],
        if (showRatingLine) ...[
          const SizedBox(height: 1),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.star_rounded,
                size: (bodySize + 2).clamp(11.0, 14.0),
                color: AppColors.starRating,
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  DiscHome.ratingWithReviews(rating!, reviewCount),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w700,
                    color: _titleColor,
                    height: 1.1,
                    fontSize: bodySize,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (locationLine != null && !tightText) ...[
          const SizedBox(height: 1),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: (bodySize + 1).clamp(10.0, 13.0),
                color: _bodyColor,
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  locationLine,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _bodyColor,
                    fontSize: bodySize,
                    height: 1.1,
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

class _PhotoPill extends StatelessWidget {
  const _PhotoPill({
    required this.icon,
    required this.label,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 8, color: iconColor ?? AppColors.white),
            const SizedBox(width: 2),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 8,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
