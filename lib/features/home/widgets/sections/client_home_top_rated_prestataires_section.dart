import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../router/navigation_extensions.dart';
import '../../providers/home_prestataire_entries_provider.dart';
import '../shared/client_home_section_header.dart';
import '../../../../shared/widgets/discovery/content/discovery_section_error.dart';
import '../catalog/prestataire_catalog_section_empty.dart';
import '../catalog/prestataire_home_horizontal_list.dart';

/// Liste horizontale « Mieux notés » (tri [note_moyenne], données Supabase).
class ClientHomeTopRatedPrestatairesSection extends ConsumerWidget {
  const ClientHomeTopRatedPrestatairesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(topRatedPrestataireEntriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClientHomeSectionHeader(
          title: DiscHome.topRatedTitle,
          compact: true,
          actionLabel: DiscHome.ctaSeeAll,
          onAction: () => context.goClientSearch(),
        ),
        const SizedBox(height: 10),
        async.when(
          data: (value) => value.isEmpty
              ? PrestataireCatalogSectionEmpty(
                  compact: true,
                  title: DiscHome.topRatedEmptyTitle,
                  body: DiscHome.topRatedEmptyBody,
                )
              : PrestataireHomeHorizontalList(
                  entries: value,
                  showRatingOnPhoto: true,
                ),
          error: (_, __) => DiscoverySectionError(
            message: DiscHome.topRatedLoadFail,
            onRetry: () => ref.invalidate(topRatedPrestataireEntriesProvider),
          ),
          loading: () => const PrestataireHomeHorizontalListSkeleton(),
        ),
      ],
    );
  }
}

