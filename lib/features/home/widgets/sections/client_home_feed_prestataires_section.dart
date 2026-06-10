import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../listing/providers/discovery_origin_provider.dart';
import '../../../../core/constants/prestataire/prestataire_service_catalog.dart';
import '../../models/home_feed_selection.dart';
import '../../providers/home_feed_provider.dart';
import '../../providers/home_prestataire_entries_provider.dart';
import '../../../../router/navigation_extensions.dart';
import '../shared/client_home_section_header.dart';
import '../catalog/prestataire_catalog_section_empty.dart';
import '../catalog/prestataire_home_horizontal_list.dart';

/// Zone résultats (recherche ou inspiration) sur l'accueil client.
class ClientHomeFeedPrestatairesSection extends ConsumerWidget {
  const ClientHomeFeedPrestatairesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(homeFeedSelectionProvider);
    if (selection == null) return const SizedBox.shrink();

    final async = ref.watch(homeFeedPrestataireEntriesProvider);
    final origin = ref.watch(discoveryOriginProvider);
    final theme = Theme.of(context);

    final title = switch (selection.source) {
      HomeFeedSource.search => DiscHome.feedSearchTitle(selection.query),
      HomeFeedSource.inspiration when selection.allServices =>
        DiscHome.feedAllTitle,
      HomeFeedSource.inspiration => DiscHome.feedInspirationTitle(
          selection.mainService != null
              ? PrestataireServiceCatalog.label(selection.mainService!)
              : selection.query,
        ),
    };
    final subtitle = switch (selection.source) {
      HomeFeedSource.search => DiscHome.feedSearchSub,
      HomeFeedSource.inspiration when selection.allServices =>
        DiscHome.feedAllSub,
      HomeFeedSource.inspiration => DiscHome.feedInspirationSub,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClientHomeSectionHeader(
          title: title,
          subtitle: subtitle,
          actionLabel: DiscHome.ctaSeeAll,
          onAction: () => context.goClientSearch(query: selection.query),
        ),
        const SizedBox(height: 14),
        async.when(
          data: (value) => value.isEmpty
              ? PrestataireCatalogSectionEmpty(
                  title: DiscHome.feedEmptyTitle,
                  body: DiscHome.feedEmptyBody,
                )
              : PrestataireHomeHorizontalList(
                  entries: value,
                  distanceOrigin: origin,
                ),
          error: (_, __) => Text(
            DiscHome.feedLoadFail,
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

