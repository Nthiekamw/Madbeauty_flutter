import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/core/constants/prestataire/prestataire_service_catalog.dart';
import 'package:madbeauty/features/prestataire/models/prestataire_service_catalog_selection.dart';

void main() {
  group('PrestataireServiceCatalogSelection', () {
    test('toJson/fromJson roundtrip', () {
      final original = PrestataireServiceCatalogSelection(
        selectedMains: {PrestaMainService.coiffure, PrestaMainService.manucure},
        specialtyIdsByMain: {
          PrestaMainService.coiffure: {'coiffure_tresses'},
          PrestaMainService.manucure: {'manucure_classique'},
        },
        customSpecialtiesByMain: {
          PrestaMainService.coiffure: ['Coloration'],
        },
      );

      final restored =
          PrestataireServiceCatalogSelection.fromJson(original.toJson());

      expect(restored.selectedMains, original.selectedMains);
      expect(restored.specialtyIdsByMain, original.specialtyIdsByMain);
      expect(restored.customSpecialtiesByMain, original.customSpecialtiesByMain);
    });

    test('fromServiceDrafts rebuilds catalog from legacy hub services', () {
      final restored = PrestataireServiceCatalogSelection.fromServiceDrafts([
        (
          nom: 'Tresses',
          categorieId: PrestataireServiceCatalog.tressesCategoryId,
        ),
        (nom: 'Pose gel / résine', categorieId: null),
      ]);

      expect(restored.selectedMains, contains(PrestaMainService.coiffure));
      expect(
        restored.specialtyIdsByMain[PrestaMainService.coiffure],
        contains('coiffure_tresses'),
      );
      expect(restored.selectedMains, contains(PrestaMainService.manucure));
      expect(
        restored.specialtyIdsByMain[PrestaMainService.manucure],
        contains('manucure_gel'),
      );
    });
  });
}
