import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/services/notifications/in_app_notification.dart';
import 'package:madbeauty/services/notifications/in_app_notification_audience.dart';

void main() {
  group('resolveInAppNotificationAudience', () {
    test('sépare client et prestataire pour les réservations', () {
      final client = InAppNotification(
        id: '1',
        title: 'Client',
        body: 'body',
        createdAt: DateTime.now(),
        actionType: 'client_booking_confirmed',
      );
      final presta = InAppNotification(
        id: '2',
        title: 'Presta',
        body: 'body',
        createdAt: DateTime.now(),
        actionType: 'booking_pending',
      );

      expect(
        resolveInAppNotificationAudience(client),
        InAppNotificationAudience.client,
      );
      expect(
        resolveInAppNotificationAudience(presta),
        InAppNotificationAudience.prestataire,
      );
    });

    test('respecte le champ audience explicite', () {
      final n = InAppNotification(
        id: '3',
        title: 't',
        body: 'b',
        createdAt: DateTime.now(),
        actionType: 'booking_status',
        audience: InAppNotificationAudience.prestataire.wire,
      );

      expect(
        resolveInAppNotificationAudience(n),
        InAppNotificationAudience.prestataire,
      );
    });
  });

  group('filterInAppNotificationsForAudience', () {
    test('ne mélange pas les listes client / prestataire', () {
      final items = [
        InAppNotification(
          id: 'c',
          title: 'c',
          body: 'b',
          createdAt: DateTime.now(),
          audience: InAppNotificationAudience.client.wire,
        ),
        InAppNotification(
          id: 'p',
          title: 'p',
          body: 'b',
          createdAt: DateTime.now(),
          audience: InAppNotificationAudience.prestataire.wire,
        ),
      ];

      expect(
        filterInAppNotificationsForAudience(
          items,
          InAppNotificationAudience.client,
        ).map((e) => e.id).toList(),
        ['c'],
      );
      expect(
        filterInAppNotificationsForAudience(
          items,
          InAppNotificationAudience.prestataire,
        ).map((e) => e.id).toList(),
        ['p'],
      );
    });
  });
}
