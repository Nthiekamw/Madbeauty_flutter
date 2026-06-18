import 'package:madbeauty/core/logic/address/postal_address.dart';
import 'package:test/test.dart';

void main() {
  group('PostalAddress', () {
    test('formattedLine compose voie, cp/ville et pays', () {
      const address = PostalAddress(
        voieType: 'Rue',
        voieNom: 'de la Paix',
        numero: '12',
        codePostal: '75001',
        ville: 'Paris',
        pays: 'France',
      );

      expect(address.streetLine, '12 rue de la Paix');
      expect(address.formattedLine, '12 rue de la Paix, 75001 Paris, France');
    });

    test('tryParse reprend une adresse structurée', () {
      final parsed = PostalAddress.tryParse(
        '8 allée des Roses, 31000 Toulouse, France',
      );

      expect(parsed.numero, '8');
      expect(parsed.voieType, 'Allée');
      expect(parsed.voieNom, 'des Roses');
      expect(parsed.codePostal, '31000');
      expect(parsed.ville, 'Toulouse');
      expect(parsed.pays, 'France');
    });
  });
}
