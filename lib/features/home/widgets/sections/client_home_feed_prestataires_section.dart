import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/prestataire/prestataire_service_catalog.dart';
import '../../../listing/providers/discovery_origin_provider.dart';
import '../../models/home_feed_selection.dart';
import '../../providers/home_feed_provider.dart';
import '../../providers/home_prestataire_entries_provider.dart';
import '../../../../router/navigation_extensions.dart';
import '../shared/client_home_section_header.dart';
import '../../../../shared/widgets/discovery/content/discovery_section_error.dart';
import '../catalog/prestataire_catalog_section_empty.dart';
import '../catalog/prestataire_home_horizontal_list.dart';
import '../catalog/prestataire_home_trending_list.dart';

/// Tendances / résultats filtrés sur l'accueil client.
class ClientHomeFeedPrestatairesSection extends ConsumerWidget {
  const ClientHomeFeedPrestatairesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(homeFeedSelectionProvider);
    if (selection == null || !selection.showsFeedSection) {
      return const SizedBox.shrink();
    }

    final async = ref.watch(homeFeedPrestataireEntriesProvider);
    final origin = ref.watch(discoveryOriginProvider);

    final title = switch (selection.source) {
      HomeFeedSource.search => DiscHome.feedSearchTitle(selection.query),
      HomeFeedSource.inspiration when selection.allServices =>
        DiscHome.trendingTitle,
      HomeFeedSource.inspiration => DiscHome.feedInspirationTitle(
          selection.mainService != null
              ? PrestataireServiceCatalog.label(selection.mainService!)
              : selection.query,
        ),
    };

    final useTrendingLayout =
        selection.source == HomeFeedSource.inspiration && selection.allServices;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClientHomeSectionHeader(
          title: title,
          compact: true,
          actionLabel: DiscHome.ctaSeeAll,
          onAction: () => context.goClientSearch(query: selection.query),
        ),
        const SizedBox(height: 10),
        async.when(
          data: (value) {
            if (value.isEmpty) {
              return PrestataireCatalogSectionEmpty(
                compact: true,
                title: DiscHome.feedEmptyTitle,
                body: DiscHome.feedEmptyBody,
              );
            }
            if (useTrendingLayout) {
              return PrestataireHomeTrendingList(entries: value);
            }
            return PrestataireHomeHorizontalList(
              entries: value,
              distanceOrigin: origin,
            );
          },
          error: (_, __) => DiscoverySectionError(
            message: DiscHome.feedLoadFail,
            onRetry: () => ref.invalidate(homeFeedPrestataireEntriesProvider),
          ),
          loading: () => SizedBox(
            height: useTrendingLayout ? 196 : 220,
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        ),
      ],
    );
  }
}
