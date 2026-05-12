import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../providers/top_rated_prestataires_provider.dart';
import 'prestataire_catalog_section_empty.dart';
import 'prestataire_home_list_card.dart';
import 'prestataire_horizontal_list_skeleton.dart';

/// Liste horizontale « Mieux notés » (tri [note_moyenne], données Supabase).
class ClientHomeTopRatedPrestatairesSection extends ConsumerWidget {
  const ClientHomeTopRatedPrestatairesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(topRatedPrestatairesProvider);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DiscoveryStrings.homeTopRatedTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          DiscoveryStrings.homeTopRatedSubtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        async.when(
          data: (value) => value.isEmpty
              ? PrestataireCatalogSectionEmpty(
                  title: DiscoveryStrings.homeTopRatedEmptyTitle,
                  body: DiscoveryStrings.homeTopRatedEmptyBody,
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
                      );
                    },
                  ),
                ),
          error: (_, __) => Text(
            DiscoveryStrings.homeNearbyPrestatairesLoadError,
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
