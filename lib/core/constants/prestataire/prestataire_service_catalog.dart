import 'package:flutter/material.dart';

/// Les 4 familles de services proposées à l’inscription prestataire.
enum PrestaMainService {
  coiffure,
  manucure,
  maquillage,
  pedicure,
}

/// Spécialité prédéfinie (liée à [categories_service] quand [categoryId] est renseigné).
class PrestaCatalogSpecialty {
  const PrestaCatalogSpecialty({
    required this.id,
    required this.label,
    this.categoryId,
  });

  final String id;
  final String label;

  /// Identifiant Supabase `categories_service.id` (null = libellé seul côté client).
  final String? categoryId;
}

/// Catalogue figé : 4 services + spécialités par service.
abstract final class PrestataireServiceCatalog {
  PrestataireServiceCatalog._();

  // IDs alignés sur supabase/migrations/20260512220000_categories_service_seed_types.sql
  static const coiffureAfroCategoryId =
      'a0000001-0001-4000-8000-000000000001';
  static const manucureCategoryId = 'a0000001-0001-4000-8000-000000000002';
  static const maquillageCategoryId = 'a0000001-0001-4000-8000-000000000003';
  static const pedicureCategoryId = 'a0000001-0001-4000-8000-000000000004';
  static const coupeCategoryId = 'a0000001-0001-4000-8000-000000000005';
  static const locksCategoryId = 'a0000001-0001-4000-8000-000000000006';
  static const soinCapillaireCategoryId =
      'a0000001-0001-4000-8000-000000000007';
  static const tressesCategoryId = 'a0000001-0001-4000-8000-000000000008';

  static const List<PrestaCatalogSpecialty> coiffureSpecialties = [
    PrestaCatalogSpecialty(
      id: 'coiffure_tresses',
      label: 'Tresses',
      categoryId: tressesCategoryId,
    ),
    PrestaCatalogSpecialty(
      id: 'coiffure_locks',
      label: 'Locks',
      categoryId: locksCategoryId,
    ),
    PrestaCatalogSpecialty(
      id: 'coiffure_coupe',
      label: 'Coupe',
      categoryId: coupeCategoryId,
    ),
    PrestaCatalogSpecialty(
      id: 'coiffure_soin',
      label: 'Soin capillaire',
      categoryId: soinCapillaireCategoryId,
    ),
    PrestaCatalogSpecialty(
      id: 'coiffure_afro',
      label: 'Coiffure afro',
      categoryId: coiffureAfroCategoryId,
    ),
  ];

  static const List<PrestaCatalogSpecialty> manucureSpecialties = [
    PrestaCatalogSpecialty(
      id: 'manucure_classique',
      label: 'Manucure classique',
      categoryId: manucureCategoryId,
    ),
    PrestaCatalogSpecialty(
      id: 'manucure_gel',
      label: 'Pose gel / résine',
    ),
    PrestaCatalogSpecialty(
      id: 'manucure_semi',
      label: 'Semi-permanent',
    ),
    PrestaCatalogSpecialty(
      id: 'manucure_nail_art',
      label: 'Nail art',
    ),
  ];

  static const List<PrestaCatalogSpecialty> maquillageSpecialties = [
    PrestaCatalogSpecialty(
      id: 'maquillage_jour',
      label: 'Maquillage jour',
      categoryId: maquillageCategoryId,
    ),
    PrestaCatalogSpecialty(
      id: 'maquillage_soir',
      label: 'Maquillage soirée / événement',
    ),
    PrestaCatalogSpecialty(
      id: 'maquillage_mariee',
      label: 'Mariée',
    ),
  ];

  static const List<PrestaCatalogSpecialty> pedicureSpecialties = [
    PrestaCatalogSpecialty(
      id: 'pedicure_classique',
      label: 'Pédicure classique',
      categoryId: pedicureCategoryId,
    ),
    PrestaCatalogSpecialty(
      id: 'pedicure_spa',
      label: 'Pédicure spa / soin',
    ),
    PrestaCatalogSpecialty(
      id: 'pedicure_vernis',
      label: 'Vernis semi-permanent pieds',
    ),
  ];

  static String label(PrestaMainService service) => switch (service) {
        PrestaMainService.coiffure => 'Coiffure',
        PrestaMainService.manucure => 'Manucure',
        PrestaMainService.maquillage => 'Maquillage',
        PrestaMainService.pedicure => 'Pédicure',
      };

  static IconData icon(PrestaMainService service) => switch (service) {
        PrestaMainService.coiffure => Icons.content_cut_rounded,
        PrestaMainService.manucure => Icons.back_hand_outlined,
        PrestaMainService.maquillage => Icons.face_retouching_natural_outlined,
        PrestaMainService.pedicure => Icons.spa_outlined,
      };

  static List<PrestaCatalogSpecialty> specialties(PrestaMainService service) =>
      switch (service) {
        PrestaMainService.coiffure => coiffureSpecialties,
        PrestaMainService.manucure => manucureSpecialties,
        PrestaMainService.maquillage => maquillageSpecialties,
        PrestaMainService.pedicure => pedicureSpecialties,
      };

  static PrestaMainService? mainForCategoryId(String categoryId) {
    for (final main in PrestaMainService.values) {
      for (final spec in specialties(main)) {
        if (spec.categoryId == categoryId) return main;
      }
    }
    return null;
  }

  static PrestaCatalogSpecialty? specialtyByCategoryId(String categoryId) {
    for (final main in PrestaMainService.values) {
      for (final spec in specialties(main)) {
        if (spec.categoryId == categoryId) return spec;
      }
    }
    return null;
  }

  static PrestaCatalogSpecialty? specialtyById(String specialtyId) {
    for (final main in PrestaMainService.values) {
      for (final spec in specialties(main)) {
        if (spec.id == specialtyId) return spec;
      }
    }
    return null;
  }

  static String defaultCategoryId(PrestaMainService main) => switch (main) {
        PrestaMainService.coiffure => coiffureAfroCategoryId,
        PrestaMainService.manucure => manucureCategoryId,
        PrestaMainService.maquillage => maquillageCategoryId,
        PrestaMainService.pedicure => pedicureCategoryId,
      };

  /// Tous les [categoryId] distincts sélectionnés (spécialités + défaut par service).
  static Set<String> collectCategoryIds({
    required Set<PrestaMainService> mains,
    required Map<PrestaMainService, Set<String>> specialtyIdsByMain,
    Map<PrestaMainService, List<String>> customSpecialtiesByMain = const {},
  }) {
    final ids = <String>{};
    for (final main in mains) {
      var linked = false;
      for (final specId in specialtyIdsByMain[main] ?? const {}) {
        final spec = specialtyById(specId);
        final cat = spec?.categoryId;
        if (cat != null && cat.isNotEmpty) {
          ids.add(cat);
          linked = true;
        }
      }
      final hasCustom = (customSpecialtiesByMain[main] ?? const [])
          .any((s) => s.trim().isNotEmpty);
      if (!linked || hasCustom) {
        ids.add(defaultCategoryId(main));
      }
    }
    return ids;
  }
}
