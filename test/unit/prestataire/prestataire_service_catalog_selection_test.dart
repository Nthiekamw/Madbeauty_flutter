import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/core/constants/prestataire/prestataire_service_catalog.dart';
import 'package:madbeauty/features/prestataire/models/prestataire_service_catalog_selection.dart';

void main() {
  test('catalog invalide sans service principal', () {
    final s = PrestataireServiceCatalogSelection();
    expect(s.isValid, isFalse);
  });

  test('catalog valide avec coiffure et spécialité', () {
    final s = PrestataireServiceCatalogSelection(
      selectedMains: {PrestaMainService.coiffure},
      specialtyIdsByMain: {
        PrestaMainService.coiffure: {'coiffure_tresses'},
      },
    );
    expect(s.isValid, isTrue);
    expect(
      s.allCategoryIds,
      contains(PrestataireServiceCatalog.tressesCategoryId),
    );
  });
}
