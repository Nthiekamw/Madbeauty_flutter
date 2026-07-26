import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/core/models/domain/catalog/produit_boutique.dart';

void main() {
  group('clampCartQuantity', () {
    test('illimité (max null) garde la quantité demandée', () {
      expect(clampCartQuantity(3, null), 3);
      expect(clampCartQuantity(0, null), 1);
    });

    test('rupture (max 0) renvoie 0', () {
      expect(clampCartQuantity(2, 0), 0);
    });

    test('plafond au stock disponible', () {
      expect(clampCartQuantity(5, 2), 2);
      expect(clampCartQuantity(1, 4), 1);
    });
  });

  group('ProduitBoutiqueStock', () {
    ProduitBoutique base({
      bool illimite = false,
      int qty = 0,
    }) {
      return ProduitBoutique(
        id: 'p1',
        prestataireId: 'presta',
        nom: 'Shampoing',
        stockIllimite: illimite,
        stockQty: qty,
      );
    }

    test('isInStock / isOutOfStock / isLowStock', () {
      expect(base(illimite: true).isInStock, isTrue);
      expect(base(qty: 0).isOutOfStock, isTrue);
      expect(base(qty: 2).isLowStock, isTrue);
      expect(base(qty: 4).isLowStock, isFalse);
    });

    test('clampOrderQty', () {
      expect(base(illimite: true).clampOrderQty(9), 9);
      expect(base(qty: 0).clampOrderQty(2), 0);
      expect(base(qty: 3).clampOrderQty(5), 3);
    });
  });
}
