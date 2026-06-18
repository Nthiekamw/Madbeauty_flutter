import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/core/constants/prestataire/prestataire_service_catalog.dart';
import 'package:madbeauty/core/models/domain/catalog/service_beaute.dart';
import 'package:madbeauty/features/prestataire/logic/prestataire_services_grouping.dart';

void main() {
  group('buildPrestataireSpecialtyGroups', () {
    test('regroupe par famille de service', () {
      final groups = buildPrestataireSpecialtyGroups(
        categoryIds: {
          PrestataireServiceCatalog.tressesCategoryId,
          PrestataireServiceCatalog.manucureCategoryId,
        },
        services: const [],
      );

      expect(groups.length, 2);
      expect(groups[0].serviceTitle, 'Coiffure');
      expect(groups[0].specialtyNames, contains('Tresses'));
      expect(groups[1].serviceTitle, 'Manucure');
    });
  });

  group('groupServicesByMain', () {
    test('classe les prestations sous Coiffure et Manucure', () {
      final groups = groupServicesByMain(
        [
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
        ],
        otherGroupTitle: 'Autres',
      );

      expect(groups.length, 2);
      expect(groups[0].title, 'Coiffure');
      expect(groups[0].services.single.nom, 'Tresses box');
      expect(groups[1].title, 'Manucure');
    });
  });
}
