import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../listing/providers/discovery_origin_provider.dart' show discoveryOriginProvider;
import '../../providers/home_prestataire_entries_provider.dart';
import '../../../../router/navigation_extensions.dart';
import '../shared/client_home_section_header.dart';
import '../../../../shared/widgets/discovery/content/discovery_section_error.dart';
import '../catalog/prestataire_catalog_section_empty.dart';
import '../catalog/prestataire_home_horizontal_list.dart';

/// Liste horizontale « Prestataires proches » (données Supabase).
class ClientHomeNearbyPrestatairesSection extends ConsumerWidget {
  const ClientHomeNearbyPrestatairesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(nearbyPrestataireEntriesProvider);
    final origin = ref.watch(discoveryOriginProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClientHomeSectionHeader(
          title: DiscHome.nearbyTitle,
          compact: true,
          actionLabel: DiscHome.ctaSeeAll,
          onAction: () => context.goClientSearch(),
        ),
        const SizedBox(height: 10),
        async.when(
          data: (value) => value.isEmpty
              ? PrestataireCatalogSectionEmpty(
                  compact: true,
                  title: DiscHome.nearbyEmptyTitle,
                  body: DiscHome.nearbyEmptyBody,
                )
              : PrestataireHomeHorizontalList(
                  entries: value,
                  distanceOrigin: origin,
                  showDistanceOnPhoto: true,
                ),
          error: (_, __) => DiscoverySectionError(
            message: DiscHome.nearbyLoadFail,
            onRetry: () => ref.invalidate(nearbyPrestataireEntriesProvider),
          ),
          loading: () => const PrestataireHomeHorizontalListSkeleton(),
        ),
      ],
    );
  }
}

