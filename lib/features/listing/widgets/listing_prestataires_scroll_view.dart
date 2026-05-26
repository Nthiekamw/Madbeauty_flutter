import 'package:flutter/material.dart';

import '../../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../../shared/layout/discovery_responsive.dart';
import 'prestataire_catalog_list_card.dart';

/// Liste / grille virtualisée des prestataires (recherche).
class ListingPrestatairesScrollView extends StatelessWidget {
  const ListingPrestatairesScrollView({
    super.key,
    required this.controller,
    required this.entries,
    required this.header,
    this.footer,
    required this.onRefresh,
  });

  final ScrollController controller;
  final List<PrestataireCatalogEntry> entries;
  final Widget header;
  final Widget? footer;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final layout = DiscoveryResponsive.of(context);
    final hPad = layout.horizontalPadding;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: layout.contentMaxWidth),
          child: CustomScrollView(
            controller: controller,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 0),
                sliver: SliverToBoxAdapter(child: header),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 24),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: layout.catalogGridColumns,
                    crossAxisSpacing: DiscoveryResponsive.catalogGridSpacing,
                    mainAxisSpacing: DiscoveryResponsive.catalogGridSpacing,
                    mainAxisExtent: layout.catalogGridTileHeight(),
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => PrestataireCatalogListCard(
                      entry: entries[index],
                      compact: true,
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
