import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

class StripeClientPaymentException implements Exception {
  const StripeClientPaymentException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

/// Portail Stripe client (cartes enregistrées pour les réservations).
class StripeClientPaymentService {
  StripeClientPaymentService(this._client);

  final SupabaseClient _client;

  Future<String> createBillingPortalUrl() async {
    final response = await _invoke('create_client_billing_portal');
    final data = _expectMap(response.data);
    final url = data['url'] as String?;
    if (url == null || url.isEmpty) {
      throw const StripeClientPaymentException(
        'Portail de paiement indisponible',
      );
    }
    return url;
  }

  Future<FunctionResponse> _invoke(String name) async {
    try {
      return await _client.functions.invoke(name);
    } on FunctionException catch (e) {
      throw _mapError(e.status, e.details);
    }
  }

  Map<String, dynamic> _expectMap(Object? raw) {
    final map = _asMap(raw);
    if (map != null) return map;
    throw const StripeClientPaymentException('Réponse serveur invalide');
  }

  static Map<String, dynamic>? _asMap(Object? raw) {
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return null;
  }

  static StripeClientPaymentException _mapError(int status, Object? raw) {
    final map = _asMap(raw);
    final code = map?['code'] as String?;
    final error = map?['error'] as String? ?? map?['message'] as String?;

    if (error != null && error.trim().isNotEmpty) {
      return StripeClientPaymentException(error.trim(), code: code);
    }
    if (status == 401 || status == 403) {
      return const StripeClientPaymentException('Session expirée');
    }
    return const StripeClientPaymentException(
      'Impossible d’ouvrir le portail de paiement',
    );
  }
}
