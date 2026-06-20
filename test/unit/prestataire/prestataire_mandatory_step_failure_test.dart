import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/core/constants/prestataire/prestataire_service_catalog.dart';
import 'package:madbeauty/features/prestataire/logic/prestataire_hub_validation.dart';
import 'package:madbeauty/features/prestataire/models/prestataire_service_catalog_selection.dart';
import 'package:madbeauty/features/prestataire/models/prestataire_service_field_set.dart';

void main() {
  test('firstMandatoryStepFailure renvoie un message précis pour les services', () {
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

    final failure = PrestataireHubValidation.firstMandatoryStepFailure(
      validateVitrineFn: () => const PrestataireHubFieldErrors(),
      validateLocationFn: () => const PrestataireHubFieldErrors(),
      validateServicesFn: () {
        final result = PrestataireHubValidation.validateServices(
          catalogSelection: catalog,
          services: [configured, pending],
        );
        return PrestataireHubFieldErrors(
          servicesError: result.errors.servicesError,
          pricingError: result.errors.pricingError,
        );
      },
      validateHorairesFn: () => const PrestataireHubFieldErrors(),
      applyErrors: (_) {},
    );

    expect(failure, isNotNull);
    expect(failure!.step, 2);
    expect(failure.message, contains('Mes services'));
    expect(failure.message, contains('Renseigne un prix valide'));
  });
}
