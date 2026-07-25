import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/features/cart/models/boutique_cart_state.dart';

void main() {
  group('BoutiqueCartState revalidate helpers', () {
    test('copyWith updates price and keeps quantity', () {
      const line = BoutiqueCartLine(
        produitId: 'p1',
        nom: 'Shampooing',
        prix: 10,
        quantite: 2,
      );
      final next = line.copyWith(prix: 12.5, nom: 'Shampooing XL');
      expect(next.prix, 12.5);
      expect(next.nom, 'Shampooing XL');
      expect(next.quantite, 2);
      expect(next.lineTotal, 25);
    });

    test('empty cart after all lines removed', () {
      const cart = BoutiqueCartState(
        prestataireId: 'presta',
        prestataireName: 'Salon',
        lines: [
          BoutiqueCartLine(
            produitId: 'p1',
            nom: 'A',
            prix: 5,
            quantite: 1,
          ),
        ],
      );
      expect(cart.isNotEmpty, isTrue);
      expect(BoutiqueCartState.empty.isEmpty, isTrue);
    });
  });
}
