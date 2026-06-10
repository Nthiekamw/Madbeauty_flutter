import 'package:flutter/material.dart';

import '../../../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import 'catalog_list_card/catalog_list_card_expanded.dart';
import 'catalog_list_card/catalog_list_card_vertical.dart';

export 'catalog_list_card/catalog_list_card_shared.dart'
    show kCatalogMaxChipsCompact, kCatalogMaxChipsExpanded;

enum CatalogCardDensity { compact, expanded }

/// Carte catalogue (grille 2 col. ou liste étendue pleine largeur).
class PrestataireCatalogListCard extends StatelessWidget {
  const PrestataireCatalogListCard({
    super.key,
    required this.entry,
    this.density = CatalogCardDensity.compact,
    this.distanceKm,
    this.onCollapse,
  });

  final PrestataireCatalogEntry entry;
  final CatalogCardDensity density;
  final double? distanceKm;
  final VoidCallback? onCollapse;

  bool get _compact => density == CatalogCardDensity.compact;

  @override
  Widget build(BuildContext context) {
    if (_compact) {
      return VerticalCatalogListCard(entry: entry, compact: true);
    }
    return ExpandedCatalogListCard(
      entry: entry,
      distanceKm: distanceKm,
      onCollapse: onCollapse,
    );
  }
}
