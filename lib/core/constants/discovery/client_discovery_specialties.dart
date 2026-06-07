import 'package:flutter/material.dart';

import '../prestataire/prestataire_service_catalog.dart';

/// Spécialité catalogue exposée côté client (inspirations + filtres recherche).
class ClientDiscoverySpecialty {
  const ClientDiscoverySpecialty({
    required this.specialty,
  });

  final PrestaCatalogSpecialty specialty;

  String get id => specialty.id;
  String get label => specialty.label;
  String? get categoryId => specialty.categoryId;
  IconData get icon => PrestataireServiceCatalog.specialtyIcon(specialty);

  /// Texte de recherche / inspiration (libellé catalogue).
  String get searchQuery => specialty.label;
}

/// Source unique : spécialités prestataire → inspirations accueil & filtres recherche.
abstract final class ClientDiscoverySpecialties {
  ClientDiscoverySpecialties._();

  static List<ClientDiscoverySpecialty> get all => [
        for (final spec in PrestataireServiceCatalog.allSpecialties)
          ClientDiscoverySpecialty(specialty: spec),
      ];

  static ClientDiscoverySpecialty? byId(String specialtyId) {
    for (final item in all) {
      if (item.id == specialtyId) return item;
    }
    return null;
  }
}
