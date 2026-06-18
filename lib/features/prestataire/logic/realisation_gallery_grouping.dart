import '../../../core/constants/prestataire/prestataire_service_catalog.dart';
import '../../../core/models/domain/catalog/photo_realisation.dart';
import '../../../core/models/domain/catalog/service_beaute.dart';
import '../models/pending_realisation_upload.dart';
import '../models/prestataire_service_catalog_selection.dart';
import '../models/prestataire_service_field_set.dart';
import 'prestataire_services_grouping.dart';

/// Cible d’upload : une spécialité rattachée à une famille de service.
class RealisationGallerySlot {
  const RealisationGallerySlot({
    required this.categorieId,
    required this.specialtyLabel,
    required this.main,
  });

  final String categorieId;
  final String specialtyLabel;
  final PrestaMainService main;

  String get serviceTitle => PrestataireServiceCatalog.label(main);

  String get slotKey => '${main.name}::$categorieId::$specialtyLabel'.toLowerCase();
}

bool realisationPhotoMatchesSlot(
  PhotoRealisation photo,
  RealisationGallerySlot slot, {
  required Iterable<RealisationGallerySlot> allSlots,
}) {
  if (photo.categorieId?.trim() != slot.categorieId) return false;
  final sameCategorySlots = allSlots
      .where((s) => s.categorieId == slot.categorieId)
      .toList();
  if (sameCategorySlots.length <= 1) return true;

  final caption = photo.caption?.trim();
  if (caption != null && caption.isNotEmpty) {
    return caption == slot.specialtyLabel;
  }

  // Photos legacy sans caption : rattachement à la spécialité catalogue.
  final catalogSpec =
      PrestataireServiceCatalog.specialtyByCategoryId(slot.categorieId);
  return catalogSpec != null && slot.specialtyLabel == catalogSpec.label;
}

bool pendingUploadMatchesSlot(
  PendingRealisationUpload upload,
  RealisationGallerySlot slot, {
  required Iterable<RealisationGallerySlot> allSlots,
}) {
  if (upload.categorieId != slot.categorieId) return false;
  if (upload.specialtyLabel != slot.specialtyLabel) return false;
  return true;
}

/// Section galerie publique : service → spécialité → médias.
class RealisationPhotosServiceSection {
  const RealisationPhotosServiceSection({
    required this.serviceTitle,
    required this.specialtyGroups,
    this.main,
  });

  final PrestaMainService? main;
  final String serviceTitle;
  final List<RealisationPhotosSpecialtyGroup> specialtyGroups;
}

class RealisationPhotosSpecialtyGroup {
  const RealisationPhotosSpecialtyGroup({
    required this.categorieId,
    required this.specialtyLabel,
    required this.photos,
  });

  final String categorieId;
  final String specialtyLabel;
  final List<PhotoRealisation> photos;
}

String _defaultCategoryIdForMain(PrestaMainService main) =>
    PrestataireServiceCatalog.defaultCategoryId(main);

/// Slots dérivés du catalogue prestataire (inscription / hub / devenir pro).
List<RealisationGallerySlot> buildRealisationGallerySlots({
  required PrestataireServiceCatalogSelection catalogSelection,
  List<PrestataireServiceFieldSet> serviceFields = const [],
  List<ServiceBeaute> publishedServices = const [],
}) {
  final seen = <String>{};
  final slots = <RealisationGallerySlot>[];

  void addSlot({
    required String categorieId,
    required String specialtyLabel,
    required PrestaMainService main,
  }) {
    final cid = categorieId.trim();
    final label = specialtyLabel.trim();
    if (cid.isEmpty || label.isEmpty) return;
    final key = '${main.name}::$cid::$label'.toLowerCase();
    if (seen.contains(key)) return;
    seen.add(key);
    slots.add(
      RealisationGallerySlot(
        categorieId: cid,
        specialtyLabel: label,
        main: main,
      ),
    );
  }

  for (final main in catalogSelection.selectedMains) {
    for (final specId in catalogSelection.specialtyIdsByMain[main] ?? const {}) {
      final spec = PrestataireServiceCatalog.specialtyById(specId);
      if (spec == null) continue;
      addSlot(
        categorieId: spec.categoryId ?? _defaultCategoryIdForMain(main),
        specialtyLabel: spec.label,
        main: main,
      );
    }
    for (final custom in catalogSelection.customSpecialtiesByMain[main] ?? const []) {
      final label = custom.trim();
      if (label.isEmpty) continue;
      addSlot(
        categorieId: _defaultCategoryIdForMain(main),
        specialtyLabel: label,
        main: main,
      );
    }
  }

  for (final field in serviceFields) {
    final cid = field.categorieId?.trim();
    final label = field.nomController.text.trim();
    if (cid == null || cid.isEmpty || label.isEmpty) continue;
    final main = PrestataireServiceCatalog.mainForCategoryId(cid) ??
        guessMainServiceFromLabel(label);
    if (main == null) continue;
    addSlot(categorieId: cid, specialtyLabel: label, main: main);
  }

  for (final service in publishedServices) {
    final cid = service.categorieId?.trim();
    final label = service.nom.trim();
    if (cid == null || cid.isEmpty || label.isEmpty) continue;
    final main = PrestataireServiceCatalog.mainForCategoryId(cid) ??
        guessMainServiceFromLabel(label);
    if (main == null) continue;
    addSlot(categorieId: cid, specialtyLabel: label, main: main);
  }

  slots.sort((a, b) {
    final mainCmp = a.main.index.compareTo(b.main.index);
    if (mainCmp != 0) return mainCmp;
    return a.specialtyLabel.compareTo(b.specialtyLabel);
  });

  return slots;
}

/// Regroupe les photos publiées par service puis spécialité.
List<RealisationPhotosServiceSection> groupRealisationPhotosByService({
  required List<PhotoRealisation> photos,
  required List<ServiceBeaute> services,
  required PrestataireServiceCatalogSelection catalogSelection,
  required Set<String> categoryIds,
  required String uncategorizedServiceTitle,
  required String uncategorizedSpecialtyLabel,
}) {
  if (photos.isEmpty) return const [];

  final slots = buildRealisationGallerySlots(
    catalogSelection: catalogSelection,
    publishedServices: services,
  );

  final byCategory = <String, List<PhotoRealisation>>{};
  final uncategorized = <PhotoRealisation>[];

  for (final photo in photos) {
    final cid = photo.categorieId?.trim();
    if (cid == null || cid.isEmpty) {
      uncategorized.add(photo);
      continue;
    }
    RealisationGallerySlot? slot;
    for (final candidate in slots) {
      if (realisationPhotoMatchesSlot(photo, candidate, allSlots: slots)) {
        slot = candidate;
        break;
      }
    }
    if (slot == null) {
      uncategorized.add(photo);
      continue;
    }
    byCategory.putIfAbsent(slot.slotKey, () => []).add(photo);
  }

  final sections = <RealisationPhotosServiceSection>[];
  final usedSlotKeys = <String>{};

  for (final main in PrestaMainService.values) {
    final mainSlots = slots.where((s) => s.main == main).toList();
    if (mainSlots.isEmpty) continue;

    final specialtyGroups = <RealisationPhotosSpecialtyGroup>[];
    for (final slot in mainSlots) {
      final items = byCategory[slot.slotKey];
      if (items == null || items.isEmpty) continue;
      usedSlotKeys.add(slot.slotKey);
      specialtyGroups.add(
        RealisationPhotosSpecialtyGroup(
          categorieId: slot.categorieId,
          specialtyLabel: slot.specialtyLabel,
          photos: items,
        ),
      );
    }

    if (specialtyGroups.isEmpty) continue;
    sections.add(
      RealisationPhotosServiceSection(
        main: main,
        serviceTitle: PrestataireServiceCatalog.label(main),
        specialtyGroups: specialtyGroups,
      ),
    );
  }

  final orphanPhotos = photos.where((photo) {
    if (photo.categorieId == null || photo.categorieId!.trim().isEmpty) {
      return false;
    }
    for (final slot in slots) {
      if (realisationPhotoMatchesSlot(photo, slot, allSlots: slots)) {
        return !usedSlotKeys.contains(slot.slotKey);
      }
    }
    return true;
  }).toList();

  if (orphanPhotos.isNotEmpty) {
    sections.add(
      RealisationPhotosServiceSection(
        serviceTitle: uncategorizedServiceTitle,
        specialtyGroups: [
          RealisationPhotosSpecialtyGroup(
            categorieId: '',
            specialtyLabel: uncategorizedSpecialtyLabel,
            photos: orphanPhotos,
          ),
        ],
      ),
    );
  }

  if (uncategorized.isNotEmpty) {
    sections.add(
      RealisationPhotosServiceSection(
        serviceTitle: uncategorizedServiceTitle,
        specialtyGroups: [
          RealisationPhotosSpecialtyGroup(
            categorieId: '',
            specialtyLabel: uncategorizedSpecialtyLabel,
            photos: uncategorized,
          ),
        ],
      ),
    );
  }

  return sections;
}

/// Sélection catalogue minimale à partir des catégories en base.
PrestataireServiceCatalogSelection catalogSelectionFromCategoryIds(
  Set<String> categoryIds,
) {
  return PrestataireServiceCatalogSelection.fromProfileData(
    selectedCategoryIds: categoryIds,
    services: const [],
  );
}
