import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../router/navigation_extensions.dart';
import '../../providers/home_prestataire_entries_provider.dart';
import '../shared/client_home_section_header.dart';
import '../../../../shared/widgets/discovery/content/discovery_section_error.dart';
import '../catalog/prestataire_catalog_section_empty.dart';
import '../catalog/prestataire_home_trending_list.dart';

/// Tendances cette semaine — toujours affichée, indépendante du filtre inspiration.
class ClientHomeFeedPrestatairesSection extends ConsumerWidget {
  const ClientHomeFeedPrestatairesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(homeFeedPrestataireEntriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClientHomeSectionHeader(
          title: DiscHome.trendingTitle,
          compact: true,
          actionLabel: DiscHome.ctaSeeAll,
          onAction: () => context.goClientSearch(),
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
            return PrestataireHomeTrendingList(entries: value);
          },
          error: (_, __) => DiscoverySectionError(
            message: DiscHome.feedLoadFail,
            onRetry: () => ref.invalidate(homeFeedPrestataireEntriesProvider),
          ),
          loading: () => const SizedBox(
            height: 196,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        ),
      ],
    );
  }
}
