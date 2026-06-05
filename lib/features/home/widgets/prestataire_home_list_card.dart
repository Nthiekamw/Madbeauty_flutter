import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/geo/geo_point.dart';
import '../../../core/geo/geo_utils.dart';
import '../../../core/models/domain/user/prestataire_profile.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/utils/text_normalizer.dart';
import '../../prestataire/widgets/shared/prestataire_card_photo_header.dart';
import '../theme/home_styles.dart';

/// Carte compacte pour listes horizontales d'accueil (proches, mieux notés).
class PrestataireHomeListCard extends StatelessWidget {
  const PrestataireHomeListCard({
    super.key,
    required this.profile,
    this.distanceOrigin,
    this.cardWidth,
    this.cardHeight,
    this.photoHeight,
  });

  final PrestataireProfile profile;

  /// Si fourni et que le profil a des coordonnées, affiche la distance.
  final GeoPoint? distanceOrigin;
  final double? cardWidth;
  final double? cardHeight;
  final double? photoHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final salon = normalizeSingleLineText(profile.nomSalon);
    final title = salon.isNotEmpty ? salon : 'Salon';
    final ville = profile.ville?.trim();
    final la = profile.latitude;
    final lo = profile.longitude;
    final origin = distanceOrigin;
    final km = origin != null && la != null && lo != null
        ? haversineDistanceKm(
            lat1: origin.latitude,
            lon1: origin.longitude,
            lat2: la,
            lon2: lo,
          )
        : double.infinity;
    final rating = profile.noteMoyenne;
    final radius = HomeStyles.cardBorderRadius;
    final w = cardWidth ?? HomeStyles.listCardWidth;
    final h = cardHeight ?? HomeStyles.listCardHeight;
    final photoH = photoHeight ?? HomeStyles.listCardPhotoHeight;

    return Material(
      color: theme.colorScheme.surface.withValues(
        alpha: isDark ? 0.9 : 0.98,
      ),
      elevation: isDark ? 0 : 1,
      shadowColor: theme.colorScheme.primary.withValues(alpha: 0.12),
      borderRadius: radius,
      child: InkWell(
        onTap: () => context.pushPrestataireDetail(profile.id),
        borderRadius: radius,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.16),
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
                  fallbackDisplayName: title,
                  compactBadge: true,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontFamily: AppFonts.display,
                                  fontWeight: FontWeight.w700,
                                  height: 1.15,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            if (profile.isVerified)
                              Icon(
                                Icons.verified_rounded,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                          ],
                        ),
                        if (ville != null && ville.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 12,
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
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const Spacer(flex: 1),
                        Row(
                          children: [
                            if (rating != null)
                              Flexible(
                                child: _InfoChip(
                                  icon: Icons.star_rounded,
                                  label: rating.toStringAsFixed(1),
                                  emphasized: true,
                                ),
                              ),
                            if (rating != null &&
                                !km.isInfinite &&
                                !km.isNaN)
                              const SizedBox(width: 6),
                            if (!km.isInfinite && !km.isNaN)
                              Flexible(
                                child: _InfoChip(
                                  icon: Icons.near_me_outlined,
                                  label: DiscHome.nearbyKm(km),
                                ),
                              ),
                          ],
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
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    this.emphasized = false,
  });

  final IconData icon;
  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: emphasized
            ? primary.withValues(alpha: 0.12)
            : theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.8,
              ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: emphasized ? primary : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                fontFamily: AppFonts.body,
                fontWeight: FontWeight.w600,
                fontSize: 10,
                color:
                    emphasized ? primary : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

