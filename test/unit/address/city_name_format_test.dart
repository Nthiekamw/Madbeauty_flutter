import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/core/logic/text/city_name_format.dart';

void main() {
  group('formatCityName', () {
    test('capitalise une ville simple', () {
      expect(formatCityName('paris'), 'Paris');
      expect(formatCityName('PARIS'), 'Paris');
      expect(formatCityName('  lyon  '), 'Lyon');
    });

    test('capitalise les segments séparés par un tiret', () {
      expect(formatCityName('saint-étienne'), 'Saint-Étienne');
      expect(formatCityName('SAINT-DENIS'), 'Saint-Denis');
    });

    test('capitalise les mots composés', () {
      expect(formatCityName('le havre'), 'Le Havre');
      expect(formatCityName('aix-en-provence'), 'Aix-En-Provence');
    });

    test('gère les apostrophes', () {
      expect(formatCityName("l'isle-d'abeau"), "L'Isle-D'Abeau");
    });

    test('retourne une chaîne vide pour une entrée vide', () {
      expect(formatCityName(''), '');
      expect(formatCityName('   '), '');
    });
  });
}
