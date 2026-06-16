import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/core/constants/prestataire/prestataire_service_catalog.dart';
import 'package:madbeauty/features/prestataire/logic/prestataire_hub_validation.dart';
import 'package:madbeauty/features/prestataire/models/prestataire_service_catalog_selection.dart';
import 'package:madbeauty/features/prestataire/models/prestataire_service_field_set.dart';

void main() {
  test('validateServices autorise une prestation configurée en avance wizard', () {
    final catalog = PrestataireServiceCatalogSelection(
      selectedMains: {PrestaMainService.manucure},
      specialtyIdsByMain: {
        PrestaMainService.manucure: {
          PrestataireServiceCatalog.specialties(PrestaMainService.manucure)
              .first
              .id,
        },
      },
    );
    final configured = PrestataireServiceFieldSet(
      nom: PrestataireServiceCatalog.specialties(PrestaMainService.manucure)
          .first
          .label,
      categorieId: PrestataireServiceCatalog.defaultCategoryId(
        PrestaMainService.manucure,
      ),
      prix: '80',
      duree: '60',
    );
    final pending = PrestataireServiceFieldSet(
      nom: 'Autre spécialité',
      categorieId: PrestataireServiceCatalog.defaultCategoryId(
        PrestaMainService.manucure,
      ),
    );

    final wizardResult = PrestataireHubValidation.validateServices(
      catalogSelection: catalog,
      services: [configured, pending],
      requireAllPriced: false,
    );
    expect(wizardResult.valid, isTrue);

    final saveResult = PrestataireHubValidation.validateServices(
      catalogSelection: catalog,
      services: [configured, pending],
      requireAllPriced: true,
    );
    expect(saveResult.valid, isFalse);
  });
}
