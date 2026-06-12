import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_config.dart';
import '../../core/config/share_link_config.dart';
import '../supabase/supabase_service.dart';

/// Résultat du traitement d'un deep link auth Supabase.
class AuthDeepLinkResult {
  const AuthDeepLinkResult({
    required this.handled,
    this.passwordRecovery = false,
  });

  final bool handled;
  final bool passwordRecovery;
}

/// Traite les deep links auth Supabase (PKCE `code`, `token_hash`, recovery…).
abstract final class AuthDeepLinkHandler {
  AuthDeepLinkHandler._();

  static const _authHosts = {
    'login-callback',
    'stripe-connect-return',
    'stripe-connect-refresh',
    'subscription-return',
    'client-payment-return',
  };

  static bool isAuthCallbackUri(Uri uri) {
    if (uri.scheme != ShareLinkConfig.customScheme) return false;
    if (!_authHosts.contains(uri.host)) return false;
    final params = normalizedQueryParameters(uri);
    return params.containsKey('code') ||
        params.containsKey('token_hash') ||
        params.containsKey('error') ||
        params.containsKey('error_description') ||
        params.containsKey('access_token');
  }

  static bool isPasswordRecoveryUri(Uri uri) {
    final type = normalizedQueryParameters(uri)['type']?.trim().toLowerCase();
    return type == 'recovery';
  }

  /// Fusionne query + fragment (format courant des e-mails Supabase).
  static Map<String, String> normalizedQueryParameters(Uri uri) {
    final normalized = _normalizeUri(uri);
    return Map<String, String>.from(normalized.queryParameters);
  }

  static Uri _normalizeUri(Uri uri) {
    final raw = uri.toString();
    if (uri.hasQuery) {
      return Uri.parse(raw.replaceAll('#', '&'));
    }
    return Uri.parse(raw.replaceAll('#', '?'));
  }

  static OtpType otpTypeFromQuery(String raw) {
    return switch (raw.trim().toLowerCase()) {
      'signup' => OtpType.signup,
      'email' => OtpType.email,
      'recovery' => OtpType.recovery,
      'invite' => OtpType.invite,
      'magiclink' => OtpType.magiclink,
      'email_change' || 'emailchange' => OtpType.emailChange,
      _ => OtpType.signup,
    };
  }

  /// Retourne le détail du traitement (session ouverte, recovery, etc.).
  static Future<AuthDeepLinkResult> handle(Uri uri) async {
    if (!AppConfig.hasSupabase || !isAuthCallbackUri(uri)) {
      return const AuthDeepLinkResult(handled: false);
    }

    final normalized = _normalizeUri(uri);
    final params = normalized.queryParameters;
    final recoveryFromUri = isPasswordRecoveryUri(uri);
    final auth = SupabaseService.client.auth;

    AuthChangeEvent? authEvent;
    final eventCompleter = Completer<AuthChangeEvent?>();
    final subscription = auth.onAuthStateChange.listen((data) {
      authEvent ??= data.event;
      if (!eventCompleter.isCompleted) {
        eventCompleter.complete(data.event);
      }
    });

    try {
      if (params.containsKey('code') ||
          params.containsKey('access_token') ||
          params.containsKey('error') ||
          params.containsKey('error_description')) {
        await auth.getSessionFromUrl(normalized);
      } else {
        final tokenHash = params['token_hash']?.trim();
        final typeRaw = params['type']?.trim();
        if (tokenHash == null || tokenHash.isEmpty || typeRaw == null) {
          return const AuthDeepLinkResult(handled: false);
        }

        final email = params['email']?.trim();
        await auth.verifyOTP(
          type: otpTypeFromQuery(typeRaw),
          tokenHash: tokenHash,
          email: email?.isNotEmpty == true ? email : null,
        );
      }

      final sessionOpened = auth.currentSession != null;
      if (!sessionOpened) {
        return const AuthDeepLinkResult(handled: false);
      }

      AuthChangeEvent? capturedEvent = authEvent;
      if (capturedEvent == null) {
        capturedEvent = await eventCompleter.future.timeout(
          const Duration(seconds: 2),
          onTimeout: () => null,
        );
      }

      final passwordRecovery = recoveryFromUri ||
          capturedEvent == AuthChangeEvent.passwordRecovery;

      return AuthDeepLinkResult(
        handled: true,
        passwordRecovery: passwordRecovery,
      );
    } on AuthException catch (e, st) {
      if (kDebugMode) {
        debugPrint('AuthDeepLinkHandler: ${e.message}\n$st');
      }
      return const AuthDeepLinkResult(handled: false);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('AuthDeepLinkHandler: $e\n$st');
      }
      return const AuthDeepLinkResult(handled: false);
    } finally {
      await subscription.cancel();
    }
  }
}
