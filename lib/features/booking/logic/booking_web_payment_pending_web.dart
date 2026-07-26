// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html' as html;

import 'booking_web_payment_pending_stub.dart';

export 'booking_web_payment_pending_stub.dart'
    show BookingWebPaymentPendingData;

/// Persistance sessionStorage du paiement en cours (retour 3DS).
abstract final class BookingWebPaymentPending {
  BookingWebPaymentPending._();

  static const _storageKey = 'madbeauty_booking_payment_pending';

  static void save(BookingWebPaymentPendingData data) {
    html.window.sessionStorage[_storageKey] = jsonEncode({
      'paymentIntentId': data.paymentIntentId,
      'prestataireId': data.prestataireId,
      if (data.serviceId != null && data.serviceId!.isNotEmpty)
        'serviceId': data.serviceId,
      if (data.packId != null && data.packId!.isNotEmpty) 'packId': data.packId,
      'dateHeureIso': data.dateHeureIso,
    });
  }

  static BookingWebPaymentPendingData? read() {
    final raw = html.window.sessionStorage[_storageKey];
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw);
      if (map is! Map) return null;
      final paymentIntentId = map['paymentIntentId'] as String?;
      final prestataireId = map['prestataireId'] as String?;
      final serviceId = map['serviceId'] as String?;
      final packId = map['packId'] as String?;
      final dateHeureIso = map['dateHeureIso'] as String?;
      if (paymentIntentId == null ||
          prestataireId == null ||
          dateHeureIso == null) {
        return null;
      }
      if ((packId == null || packId.isEmpty) &&
          (serviceId == null || serviceId.isEmpty)) {
        return null;
      }
      return BookingWebPaymentPendingData(
        paymentIntentId: paymentIntentId,
        prestataireId: prestataireId,
        serviceId: serviceId,
        packId: packId,
        dateHeureIso: dateHeureIso,
      );
    } catch (_) {
      return null;
    }
  }

  static void clear() {
    html.window.sessionStorage.remove(_storageKey);
  }
}
