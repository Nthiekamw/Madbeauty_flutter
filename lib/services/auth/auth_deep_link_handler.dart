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
    this.linkExpired = false,
  });

  final bool handled;
  final bool passwordRecovery;
  /// Lien PKCE expiré / déjà consommé (e-mail peut quand même être confirmé).
  final bool linkExpired;
}

/// Traite les deep links auth Supabase (PKCE `code`, `token_hash`, recovery…).
abstract final class AuthDeepLinkHandler {
  AuthDeepLinkHandler._();

  static const _authHosts = {
    'login-callback',
  };

  static bool isAuthCallbackUri(Uri uri) {
    if (_isWebAuthCallback(uri)) return true;
    if (uri.scheme != ShareLinkConfig.customScheme) return false;
    if (!_authHosts.contains(uri.host)) return false;
    final params = normalizedQueryParameters(uri);
    return params.containsKey('code') ||
        params.containsKey('token_hash') ||
        params.containsKey('error') ||
        params.containsKey('error_description') ||
        params.containsKey('access_token');
  }

  static bool _isWebAuthCallback(Uri uri) {
    if (uri.scheme != 'http' && uri.scheme != 'https') return false;
    final params = normalizedQueryParameters(uri);
    return params.containsKey('code') ||
        params.containsKey('token_hash') ||
        params.containsKey('access_token') ||
        params.containsKey('error') ||
        params.containsKey('error_description');
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

  static bool _isFlowExpiredError(AuthException error) {
    final message = error.message.toLowerCase();
    return message.contains('flow state has expired') ||
        message.contains('invalid flow state') ||
        message.contains('code has expired') ||
        message.contains('code verifier');
  }

  static Future<void> _verifyTokenHash(
    GoTrueClient auth,
    Map<String, String> params,
  ) async {
    final tokenHash = params['token_hash']?.trim();
    final typeRaw = params['type']?.trim();
    if (tokenHash == null || tokenHash.isEmpty || typeRaw == null) {
      throw const AuthException('Missing token_hash or type');
    }
    final email = params['email']?.trim();
    await auth.verifyOTP(
      type: otpTypeFromQuery(typeRaw),
      tokenHash: tokenHash,
      email: email?.isNotEmpty == true ? email : null,
    );
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

    var linkExpired = false;

    try {
      final tokenHash = params['token_hash']?.trim();
      final hasTokenHash = tokenHash != null && tokenHash.isNotEmpty;
      final hasPkceParams = params.containsKey('code') ||
          params.containsKey('access_token') ||
          params.containsKey('error') ||
          params.containsKey('error_description');

      // token_hash : pas de PKCE local requis (lien e-mail classique).
      if (hasTokenHash) {
        try {
          await _verifyTokenHash(auth, params);
        } on AuthException catch (e) {
          if (_isFlowExpiredError(e) && auth.currentSession != null) {
            // Lien déjà consommé mais session ouverte.
          } else {
            rethrow;
          }
          linkExpired = _isFlowExpiredError(e);
        }
      } else if (hasPkceParams) {
        try {
          await auth.getSessionFromUrl(normalized);
        } on AuthException catch (e) {
          linkExpired = _isFlowExpiredError(e);
          if (auth.currentSession != null) {
            // Double ouverture du lien : la 1re a réussi.
          } else if (linkExpired) {
            if (kDebugMode) {
              debugPrint('AuthDeepLinkHandler: ${e.message}');
            }
          } else {
            rethrow;
          }
        }
      } else {
        return const AuthDeepLinkResult(handled: false);
      }

      final sessionOpened = auth.currentSession != null;
      if (!sessionOpened) {
        return AuthDeepLinkResult(handled: false, linkExpired: linkExpired);
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
        linkExpired: linkExpired,
      );
    } on AuthException catch (e, st) {
      if (auth.currentSession != null) {
        return AuthDeepLinkResult(
          handled: true,
          passwordRecovery: recoveryFromUri,
          linkExpired: _isFlowExpiredError(e),
        );
      }
      if (kDebugMode) {
        debugPrint('AuthDeepLinkHandler: ${e.message}\n$st');
      }
      return AuthDeepLinkResult(
        handled: false,
        linkExpired: _isFlowExpiredError(e),
      );
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
