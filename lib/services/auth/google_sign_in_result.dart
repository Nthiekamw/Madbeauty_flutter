import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Résultat d'une connexion Google native : session Supabase + compte Google.
class GoogleSignInResult {
  const GoogleSignInResult({
    required this.response,
    required this.account,
  });

  final AuthResponse response;
  final GoogleSignInAccount account;
}
