import '../../../core/constants/prestataire/prestataire_service_catalog.dart';
import '../../../services/supabase/prestataire/profile_form/prestataire_profile_form_service.dart';

/// Sélection catalogue (4 services + spécialités) pour l'onboarding prestataire.
class PrestataireServiceCatalogSelection {
  PrestataireServiceCatalogSelection({
    Set<PrestaMainService>? selectedMains,
    Map<PrestaMainService, Set<String>>? specialtyIdsByMain,
    Map<PrestaMainService, List<String>>? customSpecialtiesByMain,
  })  : selectedMains = Set<PrestaMainService>.from(selectedMains ?? const {}),
        specialtyIdsByMain = {
          for (final e in (specialtyIdsByMain ?? const {}).entries)
            e.key: Set<String>.from(e.value),
        },
        customSpecialtiesByMain = {
          for (final e in (customSpecialtiesByMain ?? const {}).entries)
            e.key: List<String>.from(e.value),
        };

  final Set<PrestaMainService> selectedMains;
  final Map<PrestaMainService, Set<String>> specialtyIdsByMain;
  final Map<PrestaMainService, List<String>> customSpecialtiesByMain;

  Map<String, dynamic> toJson() => {
        'selectedMains': selectedMains.map((m) => m.name).toList(),
        'specialtyIdsByMain': {
          for (final entry in specialtyIdsByMain.entries)
            entry.key.name: entry.value.toList(),
        },
        'customSpecialtiesByMain': {
          for (final entry in customSpecialtiesByMain.entries)
            entry.key.name: List<String>.from(entry.value),
        },
      };

  factory PrestataireServiceCatalogSelection.fromJson(
    Map<String, dynamic> json,
  ) {
    PrestaMainService? mainFromName(String name) {
      for (final main in PrestaMainService.values) {
        if (main.name == name) return main;
      }
      return null;
    }

    final mains = <PrestaMainService>{};
    for (final raw in json['selectedMains'] as List? ?? const []) {
      final main = mainFromName(raw.toString());
      if (main != null) mains.add(main);
    }

    final specsByMain = <PrestaMainService, Set<String>>{};
    final specsRaw = json['specialtyIdsByMain'];
    if (specsRaw is Map) {
      for (final entry in specsRaw.entries) {
        final main = mainFromName(entry.key.toString());
        if (main == null) continue;
        specsByMain[main] = (entry.value as List? ?? const [])
            .map((e) => e.toString())
            .toSet();
      }
    }

    final customByMain = <PrestaMainService, List<String>>{};
    final customRaw = json['customSpecialtiesByMain'];
    if (customRaw is Map) {
      for (final entry in customRaw.entries) {
        final main = mainFromName(entry.key.toString());
        if (main == null) continue;
        customByMain[main] = (entry.value as List? ?? const [])
            .map((e) => e.toString())
            .toList();
      }
    }

    return PrestataireServiceCatalogSelection(
      selectedMains: mains,
      specialtyIdsByMain: specsByMain,
      customSpecialtiesByMain: customByMain,
    );
  }

  /// Reconstruit la sélection à partir de services brouillon (rétrocompatibilité).
  factory PrestataireServiceCatalogSelection.fromServiceDrafts(
    Iterable<({String nom, String? categorieId})> drafts,
  ) {
    final mains = <PrestaMainService>{};
    final specsByMain = <PrestaMainService, Set<String>>{};
    final customByMain = <PrestaMainService, List<String>>{};

    for (final draft in drafts) {
      final nom = draft.nom.trim();
      if (nom.isEmpty) continue;

      final catId = draft.categorieId?.trim();
      if (catId != null && catId.isNotEmpty) {
        final spec = PrestataireServiceCatalog.specialtyByCategoryId(catId);
        if (spec != null) {
          final main = PrestataireServiceCatalog.mainForSpecialty(spec);
          mains.add(main);
          specsByMain.putIfAbsent(main, () => {}).add(spec.id);
          continue;
        }
        final main = PrestataireServiceCatalog.mainForCategoryId(catId);
        if (main != null) {
          mains.add(main);
          customByMain.putIfAbsent(main, () => []).add(nom);
          continue;
        }
      }

      PrestaCatalogSpecialty? matched;
      for (final spec in PrestataireServiceCatalog.allSpecialties) {
        if (spec.label.toLowerCase() == nom.toLowerCase()) {
          matched = spec;
          break;
        }
      }
      if (matched != null) {
        final main = PrestataireServiceCatalog.mainForSpecialty(matched);
        mains.add(main);
        specsByMain.putIfAbsent(main, () => {}).add(matched.id);
      } else {
        final main =
            _guessMainFromSuggestionLabel(nom) ?? PrestaMainService.coiffure;
        mains.add(main);
        customByMain.putIfAbsent(main, () => []).add(nom);
      }
    }

    return PrestataireServiceCatalogSelection(
      selectedMains: mains,
      specialtyIdsByMain: specsByMain,
      customSpecialtiesByMain: customByMain,
    );
  }

  factory PrestataireServiceCatalogSelection.fromProfileData({
    required Set<String> selectedCategoryIds,
    required List<PrestataireServiceFormData> services,
    List<String> legacySuggestionLabels = const [],
  }) {
    final mains = <PrestaMainService>{};
    final specsByMain = <PrestaMainService, Set<String>>{};
    final customByMain = <PrestaMainService, List<String>>{};

    for (final catId in selectedCategoryIds) {
      final main = PrestataireServiceCatalog.mainForCategoryId(catId);
      if (main == null) continue;
      mains.add(main);
      final spec = PrestataireServiceCatalog.specialtyByCategoryId(catId);
      if (spec != null) {
        specsByMain.putIfAbsent(main, () => {}).add(spec.id);
      }
    }

    for (final label in legacySuggestionLabels) {
      final trimmed = label.trim();
      if (trimmed.isEmpty) continue;
      final main = _guessMainFromSuggestionLabel(trimmed) ??
          PrestaMainService.coiffure;
      mains.add(main);
      customByMain.putIfAbsent(main, () => []).add(trimmed);
    }

    return PrestataireServiceCatalogSelection(
      selectedMains: mains,
      specialtyIdsByMain: specsByMain,
      customSpecialtiesByMain: customByMain,
    );
  }

  static PrestaMainService? _guessMainFromSuggestionLabel(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('manuc') || lower.contains('ongle')) {
      return PrestaMainService.manucure;
    }
    if (lower.contains('maquill')) return PrestaMainService.maquillage;
    if (lower.contains('pédic') || lower.contains('pedic')) {
      return PrestaMainService.pedicure;
    }
    if (lower.contains('coiff') ||
        lower.contains('tresse') ||
        lower.contains('lock')) {
      return PrestaMainService.coiffure;
    }
    return null;
  }

  bool get isValid {
    if (selectedMains.isEmpty) return false;
    for (final main in selectedMains) {
      final specs = specialtyIdsByMain[main] ?? const {};
      final custom = customSpecialtiesByMain[main] ?? const [];
      if (specs.isEmpty && custom.isEmpty) return false;
    }
    return true;
  }

  /// Nombre de prestations (spécialités + personnalisées) sélectionnées.
  int get specialtyCount {
    var count = 0;
    for (final main in selectedMains) {
      count += specialtyIdsByMain[main]?.length ?? 0;
      count += customSpecialtiesByMain[main]?.length ?? 0;
    }
    return count;
  }

  Set<String> get allCategoryIds => PrestataireServiceCatalog.collectCategoryIds(
        mains: selectedMains,
        specialtyIdsByMain: specialtyIdsByMain,
        customSpecialtiesByMain: customSpecialtiesByMain,
      );

  /// Retire une spécialité catalogue et nettoie la prestation si vide.
  void removeCatalogSpecialty(PrestaMainService main, String specialtyId) {
    specialtyIdsByMain[main]?.remove(specialtyId);
    _cleanupMainIfEmpty(main);
  }

  /// Retire une spécialité personnalisée et nettoie la prestation si vide.
  void removeCustomSpecialty(PrestaMainService main, String label) {
    customSpecialtiesByMain[main]?.remove(label);
    _cleanupMainIfEmpty(main);
  }

  void _cleanupMainIfEmpty(PrestaMainService main) {
    final specs = specialtyIdsByMain[main] ?? const {};
    final custom = customSpecialtiesByMain[main] ?? const [];
    if (specs.isEmpty && custom.isEmpty) {
      selectedMains.remove(main);
      specialtyIdsByMain.remove(main);
      customSpecialtiesByMain.remove(main);
    }
  }

  List<String> get allCustomLabels => [
        for (final main in selectedMains)
          ...customSpecialtiesByMain[main] ?? const [],
      ];

  /// Crée des entrées `services_beaute` minimales pour le catalogue (tarifs à affiner).
  List<PrestataireServiceFormData> toServiceFormData({
    List<PrestataireServiceFormData> existing = const [],
  }) {
    final existingByName = {
      for (final s in existing)
        s.nom.trim().toLowerCase(): s,
    };
    final existingById = {
      for (final s in existing)
        if (s.id != null && s.id!.trim().isNotEmpty) s.id!: s,
    };
    final out = <PrestataireServiceFormData>[];

    PrestataireServiceFormData? resolveExisting({
      required String nom,
      String? categorieId,
    }) {
      final key = nom.trim().toLowerCase();
      final direct = existingByName[key];
      if (direct != null) return direct;

      if (categorieId != null && categorieId.trim().isNotEmpty) {
        final sameCategory = existing
            .where((s) => s.categorieId == categorieId)
            .toList(growable: false);
        if (sameCategory.length == 1) return sameCategory.first;
      }

      for (final candidate in existing) {
        final existingKey = candidate.nom.trim().toLowerCase();
        if (existingKey.isEmpty) continue;
        if (existingKey == key ||
            existingKey.contains(key) ||
            key.contains(existingKey)) {
          return candidate;
        }
      }
      return null;
    }

    void addIfNew({
      required String nom,
      String? categorieId,
      String? existingId,
      double prix = 0,
      int dureeMinutes = 60,
    }) {
      final prev = resolveExisting(nom: nom, categorieId: categorieId);
      final resolvedId = prev?.id ?? existingId;
      if (resolvedId != null && existingById.containsKey(resolvedId)) {
        // Évite de réutiliser deux fois la même ligne existante.
        existingById.remove(resolvedId);
      }
      out.add(
        PrestataireServiceFormData(
          id: resolvedId,
          nom: nom,
          categorieId: categorieId ?? prev?.categorieId,
          prix: prev?.prix ?? prix,
          dureeMinutes: prev?.dureeMinutes ?? dureeMinutes,
          description: prev?.description ?? '',
        ),
      );
    }

    for (final main in selectedMains) {
      for (final specId in specialtyIdsByMain[main] ?? const {}) {
        final spec = PrestataireServiceCatalog.specialtyById(specId);
        if (spec == null) continue;
        addIfNew(
          nom: spec.label,
          categorieId: spec.categoryId ??
              _defaultCategoryIdForMain(main),
        );
      }
      for (final custom in customSpecialtiesByMain[main] ?? const []) {
        final label = custom.trim();
        if (label.isEmpty) continue;
        addIfNew(
          nom: label,
          categorieId: _defaultCategoryIdForMain(main),
        );
      }
    }

    return out;
  }

  static String _defaultCategoryIdForMain(PrestaMainService main) =>
      PrestataireServiceCatalog.defaultCategoryId(main);
}

