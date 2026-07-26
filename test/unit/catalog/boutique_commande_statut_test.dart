import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/core/models/domain/catalog/boutique_commande.dart';

void main() {
  group('BoutiqueCommandeStatut', () {
    test('parses db values', () {
      expect(
        BoutiqueCommandeStatut.fromDb('preparing'),
        BoutiqueCommandeStatut.preparing,
      );
      expect(
        BoutiqueCommandeStatut.fromDb('pay_on_site').dbValue,
        'pay_on_site',
      );
    });

    test('nextForPrestataire follows fulfillment flow', () {
      expect(
        BoutiqueCommandeStatut.paid.nextForPrestataire,
        BoutiqueCommandeStatut.preparing,
      );
      expect(
        BoutiqueCommandeStatut.preparing.nextForPrestataire,
        BoutiqueCommandeStatut.ready,
      );
      expect(
        BoutiqueCommandeStatut.ready.nextForPrestataire,
        isNull,
      );
      expect(BoutiqueCommandeStatut.ready.canClientConfirmReceipt, isTrue);
      expect(BoutiqueCommandeStatut.completed.nextForPrestataire, isNull);
      expect(BoutiqueCommandeStatut.canceled.nextForPrestataire, isNull);
    });
  });
}
