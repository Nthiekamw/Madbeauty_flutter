import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_strings.dart';

/// Erreur métier Stripe Connect (message affichable).
class StripeConnectException implements Exception {
  const StripeConnectException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// État du compte Stripe Connect d’un prestataire.
class StripeConnectStatus {
  const StripeConnectStatus({
    this.accountId,
    required this.onboardingStatus,
    required this.chargesEnabled,
    required this.payoutsEnabled,
    required this.detailsSubmitted,
    required this.canAcceptPayments,
  });

  final String? accountId;
  final String onboardingStatus;
  final bool chargesEnabled;
  final bool payoutsEnabled;
  final bool detailsSubmitted;
  final bool canAcceptPayments;

  factory StripeConnectStatus.fromJson(Map<String, dynamic> json) {
    return StripeConnectStatus(
      accountId: json['accountId'] as String?,
      onboardingStatus:
          json['onboardingStatus'] as String? ?? 'not_started',
      chargesEnabled: json['chargesEnabled'] as bool? ?? false,
      payoutsEnabled: json['payoutsEnabled'] as bool? ?? false,
      detailsSubmitted: json['detailsSubmitted'] as bool? ?? false,
      canAcceptPayments: json['canAcceptPayments'] as bool? ?? false,
    );
  }
}

class StripeConnectOnboardingResult {
  const StripeConnectOnboardingResult({
    this.url,
    this.accountId,
    this.alreadyComplete = false,
  });

  final String? url;
  final String? accountId;
  final bool alreadyComplete;
}

class StripeConnectService {
  StripeConnectService(this._client);

  final SupabaseClient _client;

  Future<StripeConnectStatus> syncStatus() async {
    final response = await _invoke('prestataire_connect_sync');
    return StripeConnectStatus.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<StripeConnectOnboardingResult> startOnboarding() async {
    final response = await _invoke('prestataire_connect_onboarding');
    final data = Map<String, dynamic>.from(response.data as Map);
    return StripeConnectOnboardingResult(
      url: data['url'] as String?,
      accountId: data['accountId'] as String?,
      alreadyComplete: data['alreadyComplete'] as bool? ?? false,
    );
  }

  Future<FunctionResponse> _invoke(String name) async {
    try {
      return await _client.functions.invoke(name);
    } on FunctionException catch (e) {
      throw StripeConnectException(_messageFromFunction(e));
    }
  }

  static String _messageFromFunction(FunctionException e) {
    final map = _asMap(e.details);
    final server = map?['error'] as String? ?? map?['message'] as String?;
    if (server != null && server.trim().isNotEmpty) {
      return _friendlyMessage(server.trim());
    }

    if (e.status == 401 || e.status == 403) {
      return 'Session expirée. Reconnecte-toi puis réessaie.';
    }
    if (e.status == 404) {
      return 'Profil prestataire introuvable.';
    }
    return 'Erreur serveur Stripe Connect (${e.status}).';
  }

  /// Messages Stripe techniques → texte compréhensible.
  static String _friendlyMessage(String server) {
    final lower = server.toLowerCase();
    if (lower.contains('signed up for connect')) {
      return DiscStripeConnect.errPlatformConnectDisabled;
    }
    if (lower.contains('not a valid url')) {
      return DiscStripeConnect.errInvalidRedirectUrl;
    }
    return server;
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
}
