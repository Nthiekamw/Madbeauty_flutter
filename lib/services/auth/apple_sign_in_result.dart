import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Résultat d'une connexion Apple native : session Supabase + credential brut.
class AppleSignInResult {
  const AppleSignInResult({
    required this.response,
    required this.credential,
  });

  final AuthResponse response;
  final AuthorizationCredentialAppleID credential;
}
