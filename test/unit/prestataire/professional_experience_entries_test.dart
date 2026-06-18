import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/features/prestataire/logic/professional_experience_entries.dart';

void main() {
  test('encode/decode multi experiences', () {
    final entries = [
      const ProfessionalExperienceEntry(
        role: 'Coiffeuse / coiffeur indépendant·e',
        years: '3 à 5 ans',
      ),
      const ProfessionalExperienceEntry(
        role: 'Maquilleuse professionnelle',
        years: '1 à 2 ans',
      ),
    ];

    final encoded = ProfessionalExperienceCodec.encode(entries);
    expect(encoded.professional.startsWith('mb_exp:v1:'), isTrue);

    final decoded = ProfessionalExperienceCodec.decode(
      encoded.professional,
      encoded.yearsSummary,
    );
    expect(decoded.length, 2);
    expect(decoded.first.role, entries.first.role);
    expect(decoded.last.years, entries.last.years);
  });

  test('decode legacy single experience', () {
    final decoded = ProfessionalExperienceCodec.decode(
      'Salon de coiffure',
      '5 à 10 ans',
    );
    expect(decoded.length, 1);
    expect(decoded.first.role, 'Salon de coiffure');
    expect(decoded.first.years, '5 à 10 ans');
  });
}
