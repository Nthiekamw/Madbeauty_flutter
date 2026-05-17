import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../listing/providers/discovery_origin_provider.dart';
import '../providers/nearby_prestataires_provider.dart';
import 'prestataire_catalog_section_empty.dart';
import 'prestataire_home_list_card.dart';
import 'prestataire_horizontal_list_skeleton.dart';

/// Liste horizontale « Prestataires proches » (données Supabase).
class ClientHomeNearbyPrestatairesSection extends ConsumerWidget {
  const ClientHomeNearbyPrestatairesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(nearbyPrestatairesProvider);
    final origin = ref.watch(discoveryOriginProvider);
    final usesClientLocation = ref.watch(discoveryUsesClientLocationProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DiscHome.nearbyTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          usesClientLocation
              ? DiscHome.nearbySubWithLocation
              : DiscHome.nearbySubNoLocation,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        async.when(
          data: (value) => value.isEmpty
              ? PrestataireCatalogSectionEmpty(
                  title: DiscHome.nearbyEmptyTitle,
                  body: DiscHome.nearbyEmptyBody,
                )
              : SizedBox(
                  height: 172,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: value.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return PrestataireHomeListCard(
                        profile: value[index],
                        distanceOrigin: origin,
                      );
                    },
                  ),
                ),
          error: (_, __) => Text(
            DiscHome.nearbyLoadFail,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          loading: () => const PrestataireHorizontalListSkeleton(),
        ),
      ],
    );
  }
}
