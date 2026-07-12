import 'dart:convert';

import '../../../router/app_routes.dart';
import '../../../services/storage/local_cache_service.dart';

/// Réservation en attente (lien partagé → connexion / inscription).
class PendingBookingIntent {
  const PendingBookingIntent({
    required this.prestataireId,
    this.serviceId,
    this.initialDay,
  });

  final String prestataireId;
  final String? serviceId;
  final String? initialDay;

  static const _prestataireKey = 'prestataireId';
  static const _serviceKey = 'serviceId';
  static const _dayKey = 'initialDay';

  static PendingBookingIntent? read() {
    final raw = LocalCacheService.instance.pendingBookingIntentJson;
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final map = Map<String, dynamic>.from(decoded);
      final id = (map[_prestataireKey] as String?)?.trim();
      if (id == null || id.isEmpty) return null;
      return PendingBookingIntent(
        prestataireId: id,
        serviceId: (map[_serviceKey] as String?)?.trim(),
        initialDay: (map[_dayKey] as String?)?.trim(),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> remember({
    required String prestataireId,
    String? serviceId,
    String? initialDay,
  }) async {
    final id = prestataireId.trim();
    if (id.isEmpty) return;
    final payload = <String, String>{_prestataireKey: id};
    final service = serviceId?.trim();
    if (service != null && service.isNotEmpty) {
      payload[_serviceKey] = service;
    }
    final day = initialDay?.trim();
    if (day != null && day.isNotEmpty) {
      payload[_dayKey] = day;
    }
    await LocalCacheService.instance.setPendingBookingIntentJson(
      jsonEncode(payload),
    );
  }

  static Future<void> clear() =>
      LocalCacheService.instance.clearPendingBookingIntent();

  static Future<String?> consumeBookingPath() async {
    final intent = read();
    if (intent == null) return null;
    await clear();
    return intent.bookingPath;
  }

  String get bookingPath {
    final params = <String, String>{'prestataireId': prestataireId};
    final service = serviceId?.trim();
    if (service != null && service.isNotEmpty) {
      params['serviceId'] = service;
    }
    final day = initialDay?.trim();
    if (day != null && day.isNotEmpty) {
      params['date'] = day;
    }
    return Uri(path: AppRoutes.booking, queryParameters: params).toString();
  }
}
