import 'package:flutter/material.dart';

import '../../../core/geo/geo_point.dart';
import '../../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../../shared/layout/discovery_responsive.dart';
import 'prestataire_home_list_card.dart';
import 'prestataire_horizontal_list_skeleton.dart';

/// Liste horizontale virtualisée de cartes prestataire (accueil).
class PrestataireHomeHorizontalList extends StatelessWidget {
  const PrestataireHomeHorizontalList({
    super.key,
    required this.entries,
    this.distanceOrigin,
    this.limit,
  });

  final List<PrestataireCatalogEntry> entries;
  final GeoPoint? distanceOrigin;
  final int? limit;

  @override
  Widget build(BuildContext context) {
    final layout = DiscoveryResponsive.of(context);
    final maxItems = limit ?? layout.homeHorizontalPreviewLimit;
    final visible = entries.length <= maxItems
        ? entries
        : entries.sublist(0, maxItems);

    return SizedBox(
      height: layout.homeListCardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: visible.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return PrestataireHomeListCard(
            entry: visible[index],
            distanceOrigin: distanceOrigin,
            cardWidth: layout.homeListCardWidth,
            cardHeight: layout.homeListCardHeight,
            photoHeight: layout.homeListPhotoHeight,
          );
        },
      ),
    );
  }
}

/// Squelette responsive pour [PrestataireHomeHorizontalList].
class PrestataireHomeHorizontalListSkeleton extends StatelessWidget {
  const PrestataireHomeHorizontalListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final layout = DiscoveryResponsive.of(context);
    return PrestataireHorizontalListSkeleton(
      height: layout.homeListCardHeight,
      cardWidth: layout.homeListCardWidth,
    );
  }
}
