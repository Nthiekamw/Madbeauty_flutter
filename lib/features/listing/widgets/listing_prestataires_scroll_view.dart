import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../models/listing_catalog_layout.dart';
import '../providers/catalog_availability_index_provider.dart';
import '../providers/discovery_origin_provider.dart';
import 'prestataire_catalog_list_card.dart';

/// Liste / grille virtualisée des prestataires (recherche).
class ListingPrestatairesScrollView extends ConsumerWidget {
  const ListingPrestatairesScrollView({
    super.key,
    required this.controller,
    required this.entries,
    required this.layout,
    required this.header,
    this.footer,
    required this.onRefresh,
  });

  final ScrollController controller;
  final List<PrestataireCatalogEntry> entries;
  final ListingCatalogLayout layout;
  final Widget header;
  final Widget? footer;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = DiscoveryResponsive.of(context);
    final hPad = responsive.horizontalPadding;
    final origin = ref.watch(discoveryOriginProvider);
    final availability = ref.watch(catalogAvailabilityIndexProvider).value ??
        const <String, bool>{};

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: responsive.contentMaxWidth),
          child: CustomScrollView(
            controller: controller,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(hPad, 2, hPad, 0),
                sliver: SliverToBoxAdapter(child: header),
              ),
              if (layout == ListingCatalogLayout.expanded)
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(hPad, 6, hPad, 20),
                  sliver: SliverList.separated(
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final km = entry.distanceKmFrom(origin);
                      return PrestataireCatalogListCard(
                        entry: entry,
                        density: CatalogCardDensity.expanded,
                        distanceKm: km.isFinite ? km : null,
                        showAvailableBadge:
                            availability[entry.profile.id] == true,
                      );
                    },
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 16),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: DiscoveryResponsive.catalogGridSpacing,
                      mainAxisSpacing: DiscoveryResponsive.catalogGridSpacing,
                      mainAxisExtent: responsive.catalogGridTileHeight(),
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => PrestataireCatalogListCard(
                        entry: entries[index],
                        density: CatalogCardDensity.compact,
                      ),
                      childCount: entries.length,
                    ),
                  ),
                ),
              if (footer != null)
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 24),
                  sliver: SliverToBoxAdapter(child: footer!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

