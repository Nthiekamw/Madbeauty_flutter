import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/core/constants/prestataire/prestataire_service_catalog.dart';
import 'package:madbeauty/features/prestataire/logic/prestataire_hub_save_pipeline.dart';
import 'package:madbeauty/features/prestataire/models/prestataire_service_catalog_selection.dart';
import 'package:madbeauty/features/prestataire/models/prestataire_service_field_set.dart';
import 'package:madbeauty/features/prestataire/widgets/profile/steps/services/service_wizard_shine.dart';
import 'package:madbeauty/services/supabase/prestataire/profile_form/prestataire_profile_form_service.dart';

void main() {
  group('parsePrestataireServicePrice', () {
    test('accepte un entier simple', () {
      expect(parsePrestataireServicePrice('36'), 36);
    });

    test('accepte virgule et symbole euro', () {
      expect(parsePrestataireServicePrice('36,50 €'), 36.5);
    });
  });

  group('toServiceFormData', () {
    test('conserve prix et id si le nom en base diffère légèrement', () {
      const serviceId = 'svc-123';
      final catalog = PrestataireServiceCatalogSelection(
        selectedMains: {PrestaMainService.manucure},
        specialtyIdsByMain: {
          PrestaMainService.manucure: {'manucure_gel'},
        },
      );
      final spec = PrestataireServiceCatalog.specialtyById('manucure_gel')!;

      final generated = catalog.toServiceFormData(
        existing: [
          PrestataireServiceFormData(
            id: serviceId,
            nom: 'Pose gel',
            categorieId: PrestataireServiceCatalog.defaultCategoryId(
              PrestaMainService.manucure,
            ),
            prix: 36,
            dureeMinutes: 60,
          ),
        ],
      );

      expect(generated, hasLength(1));
      expect(generated.first.id, serviceId);
      expect(generated.first.nom, spec.label);
      expect(generated.first.prix, 36);
    });
  });

  group('syncServicesFromCatalog', () {
    test('conserve le prix saisi après resynchronisation catalogue', () {
      final catalog = PrestataireServiceCatalogSelection(
        selectedMains: {PrestaMainService.manucure},
        specialtyIdsByMain: {
          PrestaMainService.manucure: {'manucure_gel'},
        },
      );
      final services = [
        PrestataireServiceFieldSet(
          id: 'svc-123',
          nom: 'Pose gel',
          categorieId: PrestataireServiceCatalog.defaultCategoryId(
            PrestaMainService.manucure,
          ),
          prix: '36',
          duree: '60',
        ),
      ];

      PrestataireHubSavePipeline.syncServicesFromCatalog(
        services: services,
        catalogSelection: catalog,
      );

      expect(services, hasLength(1));
      expect(services.first.prixController.text, '36');
      expect(parsePrestataireServicePrice(services.first.prixController.text), 36);
    });
  });
}
