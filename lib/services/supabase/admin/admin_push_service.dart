import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';
import '../supabase_service.dart';

enum AdminPushAudience {
  all('all'),
  client('client'),
  prestataire('prestataire'),
  prestataireIncomplete('prestataire_incomplete'),
  user('user');

  const AdminPushAudience(this.value);
  final String value;
}

enum AdminPushNavTarget {
  none('none'),
  clientHome('client_home'),
  clientReservations('client_reservations'),
  clientSearch('client_search'),
  clientMessages('client_messages'),
  prestataireDashboard('prestataire_dashboard'),
  prestataireSubscription('prestataire_subscription'),
  prestataireProfileEdit('prestataire_profile_edit'),
  booking('booking');

  const AdminPushNavTarget(this.value);
  final String value;
}

class AdminPushPreview {
  const AdminPushPreview({required this.recipients});

  final int recipients;
}

class AdminPushSendResult {
  const AdminPushSendResult({
    required this.recipients,
    required this.sent,
    required this.failed,
    this.credentialError,
    this.firstError,
  });

  final int recipients;
  final int sent;
  final int failed;
  final String? credentialError;
  final String? firstError;
}

class AdminPushService {
  AdminPushService(this._client);

  final SupabaseClient _client;

  factory AdminPushService.fromEnv() =>
      AdminPushService(SupabaseService.client);

  Future<AdminPushPreview> previewRecipients({
    required AdminPushAudience audience,
    String? userId,
    bool excludeBanned = true,
  }) async {
    return SupabaseErrorHandler.run(
      operation: 'adminPush.previewRecipients',
      action: () async {
        final data = await _invoke(
          audience: audience,
          userId: userId,
          excludeBanned: excludeBanned,
          dryRun: true,
        );
        return AdminPushPreview(
          recipients: _intField(data, 'recipients'),
        );
      },
    );
  }

  Future<AdminPushSendResult> sendPush({
    required String title,
    required String body,
    required AdminPushAudience audience,
    String? userId,
    bool excludeBanned = true,
    AdminPushNavTarget nav = AdminPushNavTarget.none,
    String? prestataireId,
    String? serviceId,
  }) async {
    return SupabaseErrorHandler.run(
      operation: 'adminPush.sendPush',
      action: () async {
        final data = await _invoke(
          title: title,
          body: body,
          audience: audience,
          userId: userId,
          excludeBanned: excludeBanned,
          nav: nav,
          prestataireId: prestataireId,
          serviceId: serviceId,
          dryRun: false,
        );
        return AdminPushSendResult(
          recipients: _intField(data, 'recipients'),
          sent: _intField(data, 'sent'),
          failed: _intField(data, 'failed'),
          credentialError: data['credentialError'] as String?,
          firstError: data['firstError'] as String?,
        );
      },
    );
  }

  Future<Map<String, dynamic>> _invoke({
    String? title,
    String? body,
    required AdminPushAudience audience,
    String? userId,
    bool excludeBanned = true,
    AdminPushNavTarget nav = AdminPushNavTarget.none,
    String? prestataireId,
    String? serviceId,
    required bool dryRun,
  }) async {
    final res = await _client.functions.invoke(
      'admin_send_push',
      body: {
        if (title != null) 'title': title,
        if (body != null) 'body': body,
        'audience': audience.value,
        if (userId != null && userId.isNotEmpty) 'userId': userId,
        'excludeBanned': excludeBanned,
        'nav': nav.value,
        if (prestataireId != null && prestataireId.isNotEmpty)
          'prestataireId': prestataireId,
        if (serviceId != null && serviceId.isNotEmpty) 'serviceId': serviceId,
        'dryRun': dryRun,
      },
    );
    final data = res.data;
    if (data is! Map) {
      throw const FormatException('Réponse push admin invalide');
    }
    final map = Map<String, dynamic>.from(data);
    final error = map['error'];
    if (error != null) {
      throw Exception(error.toString());
    }
    if (map['ok'] != true) {
      throw Exception('Envoi push refusé');
    }
    return map;
  }

  int _intField(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }
}
