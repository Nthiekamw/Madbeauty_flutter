import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/core/logic/media/realisation_image_moderator.dart';

void main() {
  group('RealisationImageModerator.analyzeRecognizedText', () {
    test('autorise une photo sans texte détecté', () {
      final result = RealisationImageModerator.analyzeRecognizedText('');
      expect(result.isBlocked, isFalse);
    });

    test('bloque un flyer avec promo', () {
      final result = RealisationImageModerator.analyzeRecognizedText(
        'PROMO -20% sur toutes les tresses',
      );
      expect(result.isBlocked, isTrue);
      expect(result.violation, RealisationImageViolationType.contactOrPromoPattern);
    });

    test('bloke du texte générique', () {
      final result = RealisationImageModerator.analyzeRecognizedText('Salon VIP');
      expect(result.isBlocked, isTrue);
      expect(result.violation, RealisationImageViolationType.detectedText);
    });
  });
}
