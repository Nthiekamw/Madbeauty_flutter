import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../providers/home_prestataire_entries_provider.dart';
import 'client_home_section_header.dart';
import 'prestataire_catalog_section_empty.dart';
import 'prestataire_home_horizontal_list.dart';

/// Liste horizontale « Mieux notés » (tri [note_moyenne], données Supabase).
class ClientHomeTopRatedPrestatairesSection extends ConsumerWidget {
  const ClientHomeTopRatedPrestatairesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(topRatedPrestataireEntriesProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClientHomeSectionHeader(
          title: DiscHome.topRatedTitle,
          subtitle: DiscHome.topRatedSub,
          actionLabel: DiscHome.ctaSeeAll,
          onAction: () => context.goClientSearch(),
        ),
        const SizedBox(height: 14),
        async.when(
          data: (value) => value.isEmpty
              ? PrestataireCatalogSectionEmpty(
                  title: DiscHome.topRatedEmptyTitle,
                  body: DiscHome.topRatedEmptyBody,
                )
              : PrestataireHomeHorizontalList(entries: value),
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

