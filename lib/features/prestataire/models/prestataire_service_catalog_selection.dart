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
    final out = <PrestataireServiceFormData>[];

    void addIfNew({
      required String nom,
      String? categorieId,
      String? existingId,
      double prix = 0,
      int dureeMinutes = 60,
    }) {
      final key = nom.trim().toLowerCase();
      final prev = existingByName[key];
      out.add(
        PrestataireServiceFormData(
          id: prev?.id ?? existingId,
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

