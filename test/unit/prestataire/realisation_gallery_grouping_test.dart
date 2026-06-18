import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/core/constants/prestataire/prestataire_service_catalog.dart';
import 'package:madbeauty/core/models/domain/catalog/photo_realisation.dart';
import 'package:madbeauty/core/models/domain/catalog/service_beaute.dart';
import 'package:madbeauty/features/prestataire/logic/realisation_gallery_grouping.dart';
import 'package:madbeauty/features/prestataire/models/pending_realisation_upload.dart';
import 'package:madbeauty/features/prestataire/models/prestataire_service_catalog_selection.dart';
import 'package:madbeauty/services/supabase/storage/storage_service.dart';

void main() {
  group('buildRealisationGallerySlots', () {
    test('crée un slot par spécialité catalogue', () {
      final selection = PrestataireServiceCatalogSelection(
        selectedMains: {PrestaMainService.coiffure},
        specialtyIdsByMain: {
          PrestaMainService.coiffure: {'coiffure_tresses'},
        },
      );

      final slots = buildRealisationGallerySlots(catalogSelection: selection);

      expect(slots.length, 1);
      expect(slots.single.specialtyLabel, 'Tresses');
      expect(
        slots.single.categorieId,
        PrestataireServiceCatalog.tressesCategoryId,
      );
    });

    test('distingue deux spécialités custom sous la même catégorie', () {
      final selection = PrestataireServiceCatalogSelection(
        selectedMains: {PrestaMainService.coiffure},
        customSpecialtiesByMain: {
          PrestaMainService.coiffure: ['Locks entretien', 'Locks création'],
        },
      );

      final slots = buildRealisationGallerySlots(catalogSelection: selection);

      expect(slots.length, 2);
      expect(slots.map((s) => s.specialtyLabel), contains('Locks entretien'));
      expect(slots.map((s) => s.specialtyLabel), contains('Locks création'));
      expect(
        slots.every(
          (s) =>
              s.categorieId == PrestataireServiceCatalog.coiffureAfroCategoryId,
        ),
        isTrue,
      );
    });
  });

  group('realisationPhotoMatchesSlot', () {
    test('utilise la caption quand plusieurs slots partagent categorie_id', () {
      final slots = [
        RealisationGallerySlot(
          categorieId: PrestataireServiceCatalog.coiffureAfroCategoryId,
          specialtyLabel: 'Locks entretien',
          main: PrestaMainService.coiffure,
        ),
        RealisationGallerySlot(
          categorieId: PrestataireServiceCatalog.coiffureAfroCategoryId,
          specialtyLabel: 'Locks création',
          main: PrestaMainService.coiffure,
        ),
      ];

      final photo = PhotoRealisation(
        id: 'p1',
        prestataireId: 'presta',
        url: 'https://example.com/a.jpg',
        createdAt: DateTime.utc(2026, 1, 1),
        categorieId: PrestataireServiceCatalog.coiffureAfroCategoryId,
        caption: 'Locks création',
      );

      expect(
        realisationPhotoMatchesSlot(photo, slots[1], allSlots: slots),
        isTrue,
      );
      expect(
        realisationPhotoMatchesSlot(photo, slots[0], allSlots: slots),
        isFalse,
      );
    });
  });

  group('groupRealisationPhotosByService', () {
    test('regroupe les photos par service puis spécialité', () {
      final services = [
        ServiceBeaute(
          id: '1',
          prestataireId: 'p1',
          nom: 'Tresses box',
          categorieId: PrestataireServiceCatalog.tressesCategoryId,
          dureeMinutes: 120,
          prix: 80,
        ),
        ServiceBeaute(
          id: '2',
          prestataireId: 'p1',
          nom: 'Manucure gel',
          categorieId: PrestataireServiceCatalog.manucureCategoryId,
          dureeMinutes: 60,
          prix: 35,
        ),
      ];

      final photos = <PhotoRealisation>[
        PhotoRealisation(
          id: 'p1',
          prestataireId: 'p1',
          url: 'https://example.com/tresses.jpg',
          createdAt: DateTime.utc(2026, 1, 1),
          categorieId: PrestataireServiceCatalog.tressesCategoryId,
        ),
        PhotoRealisation(
          id: 'p2',
          prestataireId: 'p1',
          url: 'https://example.com/manucure.jpg',
          createdAt: DateTime.utc(2026, 1, 2),
          categorieId: PrestataireServiceCatalog.manucureCategoryId,
        ),
      ];

      final sections = groupRealisationPhotosByService(
        photos: photos,
        services: services,
        catalogSelection: catalogSelectionFromCategoryIds({
          PrestataireServiceCatalog.tressesCategoryId,
          PrestataireServiceCatalog.manucureCategoryId,
        }),
        categoryIds: {
          PrestataireServiceCatalog.tressesCategoryId,
          PrestataireServiceCatalog.manucureCategoryId,
        },
        uncategorizedServiceTitle: 'Autres',
        uncategorizedSpecialtyLabel: 'Non classées',
      );

      expect(sections.length, 2);
      expect(sections[0].serviceTitle, 'Coiffure');
      expect(sections[0].specialtyGroups.single.photos.single.id, 'p1');
      expect(sections[1].serviceTitle, 'Manucure');
      expect(sections[1].specialtyGroups.single.photos.single.id, 'p2');
    });
  });

  group('pendingUploadMatchesSlot', () {
    test('associe un upload en attente à son slot', () {
      const slot = RealisationGallerySlot(
        categorieId: 'cat-locks',
        specialtyLabel: 'Locks',
        main: PrestaMainService.coiffure,
      );
      final upload = PendingRealisationUpload(
        file: StorageUploadFile(
          bytes: Uint8List(1),
          fileName: 'a.jpg',
          mimeType: 'image/jpeg',
        ),
        categorieId: 'cat-locks',
        specialtyLabel: 'Locks',
      );

      expect(
        pendingUploadMatchesSlot(upload, slot, allSlots: [slot]),
        isTrue,
      );
    });
  });
}
