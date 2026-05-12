import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/geo/discovery_reference.dart';
import '../../../core/geo/geo_utils.dart';
import '../../../core/models/domain/user/prestataire_profile.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/widgets/app_avatar.dart';

/// Carte compacte pour listes horizontales d’accueil (proches, mieux notés).
class PrestataireHomeListCard extends StatelessWidget {
  const PrestataireHomeListCard({
    super.key,
    required this.profile,
    this.showDistanceFromReference = false,
  });

  final PrestataireProfile profile;
  final bool showDistanceFromReference;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final salon = profile.nomSalon?.trim();
    final title = (salon != null && salon.isNotEmpty) ? salon : 'Salon';
    final ville = profile.ville?.trim();
    final la = profile.latitude;
    final lo = profile.longitude;
    final km = showDistanceFromReference && la != null && lo != null
        ? haversineDistanceKm(
            lat1: kDiscoveryReferenceLatitude,
            lon1: kDiscoveryReferenceLongitude,
            lat2: la,
            lon2: lo,
          )
        : double.infinity;

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => context.pushPrestataireDetail(profile.id),
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 168,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppAvatar(
                      displayName: title,
                      radius: 22,
                    ),
                    if (profile.isVerified) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.verified,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (ville != null && ville.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    ville,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const Spacer(),
                if (profile.noteMoyenne != null) ...[
                  Text(
                    '★ ${profile.noteMoyenne!.toStringAsFixed(1)}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                if (!km.isInfinite && !km.isNaN)
                  Text(
                    DiscoveryStrings.homeNearbyPrestatairesDistanceKm(km),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
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
