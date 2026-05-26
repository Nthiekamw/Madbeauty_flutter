import 'package:flutter/material.dart';

/// Filtre rapide prédéfini de l’écran recherche / catalogue.
enum ListingQuickFilterKind {
  all,
  availableOnly,
  nearby,
  topRated,
  styleQuery,
}

class ListingQuickFilter {
  const ListingQuickFilter({
    required this.id,
    required this.label,
    required this.icon,
    required this.kind,
    this.query,
  });

  final String id;
  final String label;
  final IconData icon;
  final ListingQuickFilterKind kind;

  /// Pour [ListingQuickFilterKind.styleQuery] (aligné sur les inspirations accueil).
  final String? query;

  /// Filtres mis en avant — thèmes coiffure + tri + disponibilité.
  static const List<ListingQuickFilter> featured = [
    ListingQuickFilter(
      id: 'all',
      label: 'Tout',
      icon: Icons.grid_view_rounded,
      kind: ListingQuickFilterKind.all,
    ),
    ListingQuickFilter(
      id: 'dispo',
      label: 'Dispo',
      icon: Icons.event_available_rounded,
      kind: ListingQuickFilterKind.availableOnly,
    ),
    ListingQuickFilter(
      id: 'nearby',
      label: 'Proches',
      icon: Icons.near_me_rounded,
      kind: ListingQuickFilterKind.nearby,
    ),
    ListingQuickFilter(
      id: 'top',
      label: 'Top notés',
      icon: Icons.star_rounded,
      kind: ListingQuickFilterKind.topRated,
    ),
    ListingQuickFilter(
      id: 'tresses',
      label: 'Tresses',
      icon: Icons.waves_rounded,
      kind: ListingQuickFilterKind.styleQuery,
      query: 'Tresses',
    ),
    ListingQuickFilter(
      id: 'locks',
      label: 'Locks',
      icon: Icons.all_inclusive_rounded,
      kind: ListingQuickFilterKind.styleQuery,
      query: 'Locks',
    ),
    ListingQuickFilter(
      id: 'afro',
      label: 'Coiffure afro',
      icon: Icons.face_retouching_natural_outlined,
      kind: ListingQuickFilterKind.styleQuery,
      query: 'Coiffure afro',
    ),
    ListingQuickFilter(
      id: 'coupe',
      label: 'Coupe',
      icon: Icons.content_cut_rounded,
      kind: ListingQuickFilterKind.styleQuery,
      query: 'Coupe',
    ),
    ListingQuickFilter(
      id: 'entretien',
      label: 'Entretien',
      icon: Icons.spa_outlined,
      kind: ListingQuickFilterKind.styleQuery,
      query: 'Entretien',
    ),
    ListingQuickFilter(
      id: 'coloration',
      label: 'Coloration',
      icon: Icons.palette_outlined,
      kind: ListingQuickFilterKind.styleQuery,
      query: 'Coloration',
    ),
  ];
}
