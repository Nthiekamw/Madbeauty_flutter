import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/core/models/domain/catalog/pack_item.dart';
import 'package:madbeauty/core/models/domain/catalog/pack_item_type.dart';
import 'package:madbeauty/core/models/domain/catalog/pack_offre.dart';
import 'package:madbeauty/core/models/domain/catalog/pack_offre_detail.dart';
import 'package:madbeauty/core/models/domain/catalog/produit_boutique.dart';
import 'package:madbeauty/core/models/domain/catalog/service_beaute.dart';

void main() {
  group('computePackPrixCatalogue', () {
    test('sums services and products with quantities', () {
      const service = ServiceBeaute(
        id: 's1',
        prestataireId: 'p1',
        nom: 'Coiffure',
        prix: 50,
      );
      const produit = ProduitBoutique(
        id: 'pr1',
        prestataireId: 'p1',
        nom: 'Shampoing',
        prix: 20,
      );
      const items = [
        PackItem(
          id: 'i1',
          packId: 'pack1',
          itemType: PackItemType.service,
          serviceId: 's1',
          quantite: 1,
        ),
        PackItem(
          id: 'i2',
          packId: 'pack1',
          itemType: PackItemType.produit,
          produitId: 'pr1',
          quantite: 2,
        ),
      ];

      final total = computePackPrixCatalogue(
        items: items,
        servicesById: const {'s1': service},
        produitsById: const {'pr1': produit},
      );

      expect(total, 90);
    });
  });

  group('PackOffre.discountPercent', () {
    test('returns null when no discount', () {
      const pack = PackOffre(
        id: '1',
        prestataireId: 'p',
        titre: 'Pack',
        prixPack: 100,
      );
      expect(pack.discountPercent(100), isNull);
      expect(pack.discountPercent(80), isNull);
    });

    test('computes percent when pack cheaper than catalogue', () {
      const pack = PackOffre(
        id: '1',
        prestataireId: 'p',
        titre: 'Pack',
        prixPack: 80,
      );
      expect(pack.discountPercent(100), 20);
    });
  });
}
