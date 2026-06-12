import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_failure.dart';
import '../../core/errors/failure_mapper.dart';
import 'auth_session_sanitizer.dart';
import '../supabase/supabase_service.dart';

/// Accès à [GoTrueClient] (`supabase.auth`) : email/mot de passe, OAuth, session.
///
/// Nécessite [SupabaseService.initialize] après configuration (`SUPABASE_URL`, etc.).
///
/// Les appels qui peuvent échouer côté Supabase lèvent [AppFailure] (jamais
/// [AuthException] directement) pour que l'UI reste sur un seul type d'erreur.
class AuthService {
  AuthService(this._client);

  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  factory AuthService.fromEnv() => AuthService(SupabaseService.client);

  User? get currentUser => _auth.currentUser;

  Session? get currentSession => _auth.currentSession;

  Stream<AuthState> get onAuthStateChange =>
      AuthSessionSanitizer.streamWithRecovery(_auth);

  Future<T> _runAuth<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AuthException catch (e) {
      throw FailureMapper.fromAuthException(e);
    } on AppFailure {
      rethrow;
    } catch (e) {
      throw FailureMapper.fromUnknown(e);
    }
  }

  static String normalizeEmail(String email) => email.trim().toLowerCase();

  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) =>
      _runAuth(
        () => _auth.signInWithPassword(
          email: normalizeEmail(email),
          password: password,
        ),
      );

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
    String? emailRedirectTo,
  }) =>
      _runAuth(
        () => _auth.signUp(
          email: normalizeEmail(email),
          password: password,
          data: data,
          emailRedirectTo: emailRedirectTo,
        ),
      );

  Future<void> resendSignupConfirmationEmail({
    required String email,
    String? emailRedirectTo,
  }) =>
      _runAuth(
        () => _auth.resend(
          type: OtpType.signup,
          email: email,
          emailRedirectTo: emailRedirectTo,
        ),
      );

  Future<void> signOut({SignOutScope scope = SignOutScope.global}) =>
      _runAuth(() => _auth.signOut(scope: scope));

  Future<void> resetPasswordForEmail(
    String email, {
    String? redirectTo,
  }) =>
      _runAuth(() => _auth.resetPasswordForEmail(email, redirectTo: redirectTo));

  Future<UserResponse> updateUser(UserAttributes attributes) =>
      _runAuth(() => _auth.updateUser(attributes));

  Future<AuthResponse> refreshSession() => _runAuth(_auth.refreshSession);

  Future<UserResponse> getUser() => _runAuth(_auth.getUser);

  /// OAuth (ex. Google). Le résultat se lit via [onAuthStateChange].
  Future<bool> signInWithOAuth(
    OAuthProvider provider, {
    String? redirectTo,
    String? scopes,
    LaunchMode authScreenLaunchMode = LaunchMode.platformDefault,
    Map<String, String>? queryParams,
  }) =>
      _runAuth(
        () => _auth.signInWithOAuth(
          provider,
          redirectTo: redirectTo,
          scopes: scopes,
          authScreenLaunchMode: authScreenLaunchMode,
          queryParams: queryParams,
        ),
      );

  /// Google natif : échange l’id_token Google contre une session Supabase.
  Future<AuthResponse> signInWithGoogleIdToken({
    required String idToken,
    String? accessToken,
    String? nonce,
  }) =>
      _runAuth(
        () => _auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
          nonce: nonce,
        ),
      );

}

