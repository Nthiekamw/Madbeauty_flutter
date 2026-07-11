import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/core/logic/address/address_search_query_parser.dart';

void main() {
  group('AddressSearchQueryParser.parseBelgian', () {
    test('extracts house number, street, postal code and municipality', () {
      final parsed = AddressSearchQueryParser.parseBelgian(
        '150 rue de Montigny 6000 Charleroi',
      );

      expect(parsed.houseNumber, '150');
      expect(parsed.postCode, '6000');
      expect(parsed.municipalityName, 'Charleroi');
      expect(parsed.streetNamePattern, '*rue de Montigny*');
    });

    test('supports comma-separated municipality', () {
      final parsed = AddressSearchQueryParser.parseBelgian(
        '150 rue de Montigny, Charleroi 6000',
      );

      expect(parsed.postCode, '6000');
      expect(parsed.houseNumber, '150');
      expect(parsed.municipalityName, 'Charleroi');
    });
  });

  group('AddressSearchQueryParser.parseCanadianPostalCode', () {
    test('finds Canadian postal code in query', () {
      expect(
        AddressSearchQueryParser.parseCanadianPostalCode(
          '100 Queen St W Toronto ON M5H 2N2',
        ),
        'M5H 2N2',
      );
    });
  });
}
