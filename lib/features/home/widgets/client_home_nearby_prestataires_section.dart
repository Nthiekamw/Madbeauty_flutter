import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../listing/providers/discovery_origin_provider.dart';
import '../providers/nearby_prestataires_provider.dart';
import '../../../router/navigation_extensions.dart';
import 'client_home_section_header.dart';
import 'prestataire_catalog_section_empty.dart';
import 'prestataire_home_horizontal_list.dart';

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
        ClientHomeSectionHeader(
          title: DiscHome.nearbyTitle,
          subtitle: usesClientLocation
              ? DiscHome.nearbySubWithLocation
              : DiscHome.nearbySubNoLocation,
          actionLabel: DiscHome.ctaSeeAll,
          onAction: () => context.goClientSearch(),
        ),
        const SizedBox(height: 14),
        async.when(
          data: (value) => value.isEmpty
              ? PrestataireCatalogSectionEmpty(
                  title: DiscHome.nearbyEmptyTitle,
                  body: DiscHome.nearbyEmptyBody,
                )
              : PrestataireHomeHorizontalList(
                  profiles: value,
                  distanceOrigin: origin,
                ),
          error: (_, __) => Text(
            DiscHome.nearbyLoadFail,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          loading: () => const PrestataireHomeHorizontalListSkeleton(),
        ),
      ],
    );
  }
}

