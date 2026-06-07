import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/geo/geo_point.dart';
import '../../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../home/widgets/prestataire_home_list_card.dart';
import '../models/listing_catalog_layout.dart';
import '../providers/discovery_origin_provider.dart';
import '../providers/listing_view_preferences_provider.dart';
import 'prestataire_catalog_list_card.dart';

/// Liste / grille virtualisée des prestataires (recherche).
class ListingPrestatairesScrollView extends ConsumerWidget {
  const ListingPrestatairesScrollView({
    super.key,
    required this.controller,
    required this.entries,
    required this.layout,
    required this.onRefresh,
    this.header,
    this.footer,
  });

  final ScrollController controller;
  final List<PrestataireCatalogEntry> entries;
  final ListingCatalogLayout layout;
  final Widget? header;
  final Widget? footer;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = DiscoveryResponsive.of(context);
    final hPad = responsive.horizontalPadding;
    final origin = ref.watch(discoveryOriginProvider);
    final expandedId = ref.watch(listingExpandedCardIdProvider);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: responsive.contentMaxWidth),
          child: CustomScrollView(
            controller: controller,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              if (header != null)
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(hPad, 2, hPad, 0),
                  sliver: SliverToBoxAdapter(child: header!),
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
                        key: ValueKey('catalog-list-${entry.profile.id}'),
                        entry: entry,
                        density: CatalogCardDensity.expanded,
                        distanceKm: km.isFinite ? km : null,
                      );
                    },
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, rowIndex) {
                        return _buildGridRow(
                          context: context,
                          ref: ref,
                          rowIndex: rowIndex,
                          entries: entries,
                          expandedId: expandedId,
                          origin: origin,
                          responsive: responsive,
                        );
                      },
                      childCount: _gridRowCount(entries, expandedId),
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

  int _gridRowCount(List<PrestataireCatalogEntry> entries, String? expandedId) {
    var rows = 0;
    var i = 0;
    while (i < entries.length) {
      if (entries[i].profile.id == expandedId) {
        rows += 1;
        i += 1;
        continue;
      }
      if (i + 1 < entries.length &&
          entries[i + 1].profile.id != expandedId) {
        rows += 1;
        i += 2;
      } else {
        rows += 1;
        i += 1;
      }
    }
    return rows;
  }

  Widget _buildGridRow({
    required BuildContext context,
    required WidgetRef ref,
    required int rowIndex,
    required List<PrestataireCatalogEntry> entries,
    required String? expandedId,
    required GeoPoint origin,
    required DiscoveryResponsive responsive,
  }) {
    var row = 0;
    var i = 0;
    while (i < entries.length) {
      if (entries[i].profile.id == expandedId) {
        if (row == rowIndex) {
          final entry = entries[i];
          final km = entry.distanceKmFrom(origin);
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: PrestataireCatalogListCard(
              key: ValueKey('catalog-expanded-${entry.profile.id}'),
              entry: entry,
              density: CatalogCardDensity.expanded,
              distanceKm: km.isFinite ? km : null,
              onCollapse: () => ref
                  .read(listingExpandedCardIdProvider.notifier)
                  .toggle(entry.profile.id),
            ),
          );
        }
        row += 1;
        i += 1;
        continue;
      }

      final hasPair = i + 1 < entries.length &&
          entries[i + 1].profile.id != expandedId;

      if (row == rowIndex) {
        final left = entries[i];
        final right = hasPair ? entries[i + 1] : null;
        final cellW = responsive.catalogGridCellWidth();
        final cardH = responsive.catalogGridTileHeight();
        final photoH = responsive.catalogGridPhotoHeight();

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _GridTile(
                  entry: left,
                  origin: origin,
                  cellW: cellW,
                  cardH: cardH,
                  photoH: photoH,
                  onExpand: () => ref
                      .read(listingExpandedCardIdProvider.notifier)
                      .toggle(left.profile.id),
                ),
              ),
              const SizedBox(width: DiscoveryResponsive.catalogGridSpacing),
              Expanded(
                child: right == null
                    ? const SizedBox.shrink()
                    : _GridTile(
                        entry: right,
                        origin: origin,
                        cellW: cellW,
                        cardH: cardH,
                        photoH: photoH,
                        onExpand: () => ref
                            .read(listingExpandedCardIdProvider.notifier)
                            .toggle(right.profile.id),
                      ),
              ),
            ],
          ),
        );
      }

      row += 1;
      i += hasPair ? 2 : 1;
    }

    return const SizedBox.shrink();
  }
}

class _GridTile extends StatelessWidget {
  const _GridTile({
    required this.entry,
    required this.origin,
    required this.cellW,
    required this.cardH,
    required this.photoH,
    required this.onExpand,
  });

  final PrestataireCatalogEntry entry;
  final GeoPoint origin;
  final double cellW;
  final double cardH;
  final double photoH;
  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        PrestataireHomeListCard(
          key: ValueKey('catalog-grid-${entry.profile.id}'),
          entry: entry,
          distanceOrigin: origin,
          cardWidth: cellW,
          cardHeight: cardH,
          photoHeight: photoH,
          dense: true,
        ),
        Positioned(
          top: 6,
          left: 6,
          child: Material(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onExpand,
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.open_in_full_rounded, size: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
