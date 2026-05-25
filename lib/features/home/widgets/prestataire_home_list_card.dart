import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/geo/geo_point.dart';
import '../../../core/geo/geo_utils.dart';
import '../../../core/models/domain/user/prestataire_profile.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../theme/home_styles.dart';

/// Carte compacte pour listes horizontales d’accueil (proches, mieux notés).
class PrestataireHomeListCard extends StatelessWidget {
  const PrestataireHomeListCard({
    super.key,
    required this.profile,
    this.distanceOrigin,
  });

  final PrestataireProfile profile;

  /// Si fourni et que le profil a des coordonnées, affiche la distance.
  final GeoPoint? distanceOrigin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final salon = profile.nomSalon?.trim();
    final title = (salon != null && salon.isNotEmpty) ? salon : 'Salon';
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

    return Material(
      color: theme.colorScheme.surface.withValues(
        alpha: isDark ? 0.9 : 0.98,
      ),
      elevation: isDark ? 0 : 1,
      shadowColor: theme.colorScheme.primary.withValues(alpha: 0.12),
      borderRadius: HomeStyles.cardBorderRadius,
      child: InkWell(
        onTap: () => context.pushPrestataireDetail(profile.id),
        borderRadius: HomeStyles.cardBorderRadius,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: HomeStyles.cardBorderRadius,
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.16),
            ),
          ),
          child: SizedBox(
            width: HomeStyles.listCardWidth,
            height: HomeStyles.listCardHeight,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppAvatar(
                        displayName: title,
                        radius: 24,
                      ),
                      const Spacer(),
                      if (profile.isVerified)
                        Icon(
                          Icons.verified_rounded,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  if (ville != null && ville.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
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
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const Spacer(),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (rating != null)
                        _InfoChip(
                          icon: Icons.star_rounded,
                          label: rating.toStringAsFixed(1),
                          emphasized: true,
                        ),
                      if (!km.isInfinite && !km.isNaN)
                        _InfoChip(
                          icon: Icons.near_me_outlined,
                          label: DiscHome.nearbyKm(km),
                        ),
                    ],
                  ),
                ],
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            size: 14,
            color: emphasized ? primary : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w600,
              color: emphasized ? primary : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
