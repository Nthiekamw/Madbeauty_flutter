import 'package:flutter_test/flutter_test.dart';

import 'package:madbeauty/core/logic/catalog/pack_booking_duration.dart';
import 'package:madbeauty/core/models/domain/catalog/pack_item.dart';
import 'package:madbeauty/core/models/domain/catalog/pack_item_type.dart';
import 'package:madbeauty/core/models/domain/catalog/service_beaute.dart';

void main() {
  group('computePackDurationMinutes', () {
    test('sums service durations × qty', () {
      final services = {
        's1': const ServiceBeaute(
          id: 's1',
          prestataireId: 'p',
          nom: 'A',
          dureeMinutes: 60,
        ),
        's2': const ServiceBeaute(
          id: 's2',
          prestataireId: 'p',
          nom: 'B',
          dureeMinutes: 45,
        ),
      };
      final items = [
        const PackItem(
          id: '1',
          packId: 'pack',
          itemType: PackItemType.service,
          serviceId: 's1',
          quantite: 1,
        ),
        const PackItem(
          id: '2',
          packId: 'pack',
          itemType: PackItemType.service,
          serviceId: 's2',
          quantite: 2,
        ),
        const PackItem(
          id: '3',
          packId: 'pack',
          itemType: PackItemType.produit,
          produitId: 'prod',
          quantite: 3,
        ),
      ];
      expect(
        computePackDurationMinutes(items: items, servicesById: services),
        60 + 45 * 2,
      );
    });

    test('returns 0 without services', () {
      expect(
        computePackDurationMinutes(
          items: const [
            PackItem(
              id: '1',
              packId: 'pack',
              itemType: PackItemType.produit,
              produitId: 'p',
            ),
          ],
          servicesById: const {},
        ),
        0,
      );
    });
  });

  group('slotFitsDurationInPlage', () {
    test('accepts slot that fits', () {
      expect(
        slotFitsDurationInPlage(
          startMinutes: 9 * 60,
          durationMinutes: 90,
          plageStartMinutes: 9 * 60,
          plageEndMinutes: 12 * 60,
        ),
        isTrue,
      );
    });

    test('rejects slot overflowing plage', () {
      expect(
        slotFitsDurationInPlage(
          startMinutes: 11 * 60,
          durationMinutes: 90,
          plageStartMinutes: 9 * 60,
          plageEndMinutes: 12 * 60,
        ),
        isFalse,
      );
    });
  });

  group('intervalsOverlap', () {
    test('detects overlap', () {
      final a = DateTime(2026, 7, 26, 10);
      final b = DateTime(2026, 7, 26, 11);
      final c = DateTime(2026, 7, 26, 10, 30);
      final d = DateTime(2026, 7, 26, 12);
      expect(
        intervalsOverlap(aStart: a, aEnd: b, bStart: c, bEnd: d),
        isTrue,
      );
      expect(
        intervalsOverlap(aStart: a, aEnd: b, bStart: b, bEnd: d),
        isFalse,
      );
    });
  });
}
