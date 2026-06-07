import 'package:flutter/material.dart';

import '../../../core/constants/discovery/client_discovery_specialties.dart';

/// Filtre rapide prédéfini de l'écran recherche / catalogue.
enum ListingQuickFilterKind {
  all,
  availableOnly,
  nearby,
  topRated,
  styleQuery,
  categoryId,
}

class ListingQuickFilter {
  const ListingQuickFilter({
    required this.id,
    required this.label,
    required this.icon,
    required this.kind,
    this.query,
    this.categoryId,
  });

  final String id;
  final String label;
  final IconData icon;
  final ListingQuickFilterKind kind;

  /// Pour [ListingQuickFilterKind.styleQuery] (aligné sur les inspirations accueil).
  final String? query;

  /// Pour [ListingQuickFilterKind.categoryId] (famille de service).
  final String? categoryId;

  static const _utilityFilters = [
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
  ];

  static ListingQuickFilter fromDiscoverySpecialty(ClientDiscoverySpecialty item) {
    final cat = item.categoryId;
    if (cat != null && cat.isNotEmpty) {
      return ListingQuickFilter(
        id: 'spec_${item.id}',
        label: item.label,
        icon: item.icon,
        kind: ListingQuickFilterKind.categoryId,
        categoryId: cat,
        query: item.searchQuery,
      );
    }
    return ListingQuickFilter(
      id: 'spec_${item.id}',
      label: item.label,
      icon: item.icon,
      kind: ListingQuickFilterKind.styleQuery,
      query: item.searchQuery,
    );
  }

  /// Utilitaires + spécialités catalogue prestataire (source unique).
  static List<ListingQuickFilter> get featured => [
        ..._utilityFilters,
        ...ClientDiscoverySpecialties.all.map(fromDiscoverySpecialty),
      ];

  static List<ListingQuickFilter> get catalogTop => const [
        ListingQuickFilter(
          id: 'dispo',
          label: 'Disponibles aujourd\'hui',
          icon: Icons.schedule_rounded,
          kind: ListingQuickFilterKind.availableOnly,
        ),
        ListingQuickFilter(
          id: 'nearby',
          label: 'À proximité',
          icon: Icons.near_me_outlined,
          kind: ListingQuickFilterKind.nearby,
        ),
        ListingQuickFilter(
          id: 'top',
          label: 'Mieux notés',
          icon: Icons.star_outline_rounded,
          kind: ListingQuickFilterKind.topRated,
        ),
      ];

  static List<ListingQuickFilter> get utilityOnly =>
      List<ListingQuickFilter>.unmodifiable(_utilityFilters);

  static List<ListingQuickFilter> get specialtyOnly =>
      ClientDiscoverySpecialties.all.map(fromDiscoverySpecialty).toList();
}
