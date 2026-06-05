import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/prestataire/models/prestataire_subscription_status.dart';

class StripePrestaSubscriptionException implements Exception {
  const StripePrestaSubscriptionException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

class StripePrestaCheckoutResult {
  const StripePrestaCheckoutResult({
    required this.url,
    required this.tier,
    required this.interval,
  });

  final String url;
  final String tier;
  final String interval;
}

/// Checkout abonnement prestataire (Stripe Checkout hébergé).
class StripePrestaSubscriptionService {
  StripePrestaSubscriptionService(this._client);

  final SupabaseClient _client;

  Future<StripePrestaCheckoutResult> createCheckout({
    required String tier,
    required String interval,
  }) async {
    final response = await _invoke(
      'create_prestataire_subscription_checkout',
      body: {'tier': tier, 'interval': interval},
    );
    final data = _expectMap(response.data);
    final url = data['url'] as String?;
    if (url == null || url.isEmpty) {
      throw const StripePrestaSubscriptionException(
        'Lien de paiement indisponible',
      );
    }
    return StripePrestaCheckoutResult(
      url: url,
      tier: data['tier'] as String? ?? tier,
      interval: data['interval'] as String? ?? interval,
    );
  }

  Future<String> createBillingPortalUrl() async {
    final response = await _invoke('create_prestataire_billing_portal');
    final data = _expectMap(response.data);
    final url = data['url'] as String?;
    if (url == null || url.isEmpty) {
      throw const StripePrestaSubscriptionException(
        'Portail de facturation indisponible',
      );
    }
    return url;
  }

  Future<PrestataireSubscriptionStatus> syncFromStripe() async {
    final response = await _invoke('sync_prestataire_subscription');
    final data = _expectMap(response.data);
    final sub = data['subscription'];
    if (sub is Map) {
      return PrestataireSubscriptionStatus.fromRow(
        Map<String, dynamic>.from(sub),
      );
    }
    return PrestataireSubscriptionStatus.empty();
  }

  Future<PrestataireSubscriptionStatus> fetchStatus() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return PrestataireSubscriptionStatus.empty();

    final row = await _client
        .from('prestataire_profiles')
        .select(
          'subscription_status, subscription_tier, subscription_interval, '
          'subscription_current_period_end, stripe_subscription_id',
        )
        .eq('user_id', userId)
        .maybeSingle();

    if (row == null) return PrestataireSubscriptionStatus.empty();
    return PrestataireSubscriptionStatus.fromRow(
      Map<String, dynamic>.from(row),
    );
  }

  Future<FunctionResponse> _invoke(
    String name, {
    Object? body,
  }) async {
    try {
      return await _client.functions.invoke(name, body: body);
    } on FunctionException catch (e) {
      throw _mapError(e.status, e.details);
    }
  }

  Map<String, dynamic> _expectMap(Object? raw) {
    final map = _asMap(raw);
    if (map != null) return map;
    throw const StripePrestaSubscriptionException('Réponse serveur invalide');
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

  static StripePrestaSubscriptionException _mapError(
    int status,
    Object? raw,
  ) {
    final map = _asMap(raw);
    final code = map?['code'] as String?;
    final error = map?['error'] as String? ?? map?['message'] as String?;

    switch (code) {
      case 'subscription_already_active':
        return StripePrestaSubscriptionException(
          error ?? 'Abonnement déjà actif',
          code: code,
        );
      case 'tier_mismatch':
        return StripePrestaSubscriptionException(
          error ?? 'Palier incorrect pour ton nombre de services',
          code: code,
        );
      case 'stripe_not_configured':
        return StripePrestaSubscriptionException(
          error ?? 'Paiement non configuré sur le serveur',
          code: code,
        );
    }

    if (error != null && error.trim().isNotEmpty) {
      return StripePrestaSubscriptionException(error.trim(), code: code);
    }
    if (status == 401 || status == 403) {
      return const StripePrestaSubscriptionException('Session expirée');
    }
    return const StripePrestaSubscriptionException(
      'Impossible de démarrer le paiement',
    );
  }
}
