import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_service.dart';

/// Indices sur les champs d'identité fournis par un fournisseur OAuth.
class OAuthIdentityHints {
  const OAuthIdentityHints({
    required this.providedPrenom,
    required this.providedNom,
    required this.providedEmail,
  });

  final bool providedPrenom;
  final bool providedNom;
  final bool providedEmail;

  static OAuthIdentityHints fromAppleCredential(
    AuthorizationCredentialAppleID credential,
    User user,
  ) {
    final given = credential.givenName?.trim();
    final family = credential.familyName?.trim();
    final sessionEmail = user.email?.trim();
    final metaHints = fromMetadata(user.userMetadata, email: sessionEmail);

    // Apple fournit toujours un e-mail de session (réel ou private relay).
    // Les noms ne sont renvoyés qu'à la 1ʳᵉ autorisation : on accepte aussi
    // les métadonnées déjà synchronisées.
    return OAuthIdentityHints(
      providedPrenom: (given != null && given.isNotEmpty) ||
          metaHints.providedPrenom,
      providedNom: (family != null && family.isNotEmpty) ||
          metaHints.providedNom,
      providedEmail: true,
    );
  }

  static OAuthIdentityHints fromGoogleAccount(
    GoogleSignInAccount account,
    User user,
  ) {
    final parts = OAuthNameParts.fromDisplayName(account.displayName);
    final accountEmail = account.email.trim();
    final sessionEmail = user.email?.trim();

    return OAuthIdentityHints(
      providedPrenom: parts.prenom != null,
      providedNom: parts.nom != null,
      providedEmail: accountEmail.isNotEmpty ||
          (sessionEmail != null && sessionEmail.isNotEmpty),
    );
  }

  static OAuthIdentityHints fromUserMetadata(User user) {
    return fromMetadata(user.userMetadata, email: user.email);
  }

  static OAuthIdentityHints fromMetadata(
    Map<String, dynamic>? meta, {
    String? email,
  }) {
    final parts = OAuthNameParts.fromMetadata(meta);
    final sessionEmail = email?.trim();

    return OAuthIdentityHints(
      providedPrenom: parts.prenom != null ||
          OAuthNameParts.hasKey(meta, 'given_name') ||
          OAuthNameParts.hasKey(meta, 'prenom'),
      providedNom: parts.nom != null ||
          OAuthNameParts.hasKey(meta, 'family_name') ||
          OAuthNameParts.hasKey(meta, 'nom'),
      providedEmail: (sessionEmail != null && sessionEmail.isNotEmpty) ||
          OAuthNameParts.hasKey(meta, 'email'),
    );
  }
}

/// Découpage prénom / nom à partir d'un nom complet OAuth.
class OAuthNameParts {
  const OAuthNameParts({this.prenom, this.nom});

  final String? prenom;
  final String? nom;

  static OAuthNameParts fromDisplayName(String? displayName) {
    final trimmed = displayName?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return const OAuthNameParts();
    }
    return fromFullName(trimmed);
  }

  static OAuthNameParts fromMetadata(Map<String, dynamic>? meta) {
    if (meta == null) return const OAuthNameParts();

    final given = _read(meta, 'given_name') ?? _read(meta, 'prenom');
    final family = _read(meta, 'family_name') ?? _read(meta, 'nom');
    if (given != null || family != null) {
      return OAuthNameParts(prenom: given, nom: family);
    }

    final full = _read(meta, 'full_name') ?? _read(meta, 'name');
    if (full == null) return const OAuthNameParts();
    return fromFullName(full);
  }

  static OAuthNameParts fromFullName(String fullName) {
    final parts = fullName.split(RegExp(r'\s+'));
    if (parts.isEmpty) return const OAuthNameParts();
    if (parts.length == 1) {
      return OAuthNameParts(prenom: parts.first);
    }
    return OAuthNameParts(
      prenom: parts.first,
      nom: parts.sublist(1).join(' '),
    );
  }

  static bool hasKey(Map<String, dynamic>? meta, String key) {
    if (meta == null) return false;
    final value = meta[key];
    return value is String && value.trim().isNotEmpty;
  }

  Map<String, dynamic> toMetadata() {
    final data = <String, dynamic>{};
    final given = prenom?.trim();
    final family = nom?.trim();
    if (given != null && given.isNotEmpty) {
      data['given_name'] = given;
      data['prenom'] = given;
    }
    if (family != null && family.isNotEmpty) {
      data['family_name'] = family;
      data['nom'] = family;
    }
    if (given != null &&
        given.isNotEmpty &&
        family != null &&
        family.isNotEmpty) {
      data['full_name'] = '$given $family';
      data['name'] = '$given $family';
    } else if (given != null && given.isNotEmpty) {
      data['full_name'] = given;
      data['name'] = given;
    }
    return data;
  }

  static String? _read(Map<String, dynamic> meta, String key) {
    final value = meta[key];
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

/// Persiste le nom fourni par Apple (disponible une seule fois à la 1ʳᵉ autorisation).
class AppleIdentitySync {
  AppleIdentitySync(this._auth);

  final AuthService _auth;

  Future<User?> applyCredentialIfNeeded(
    AuthorizationCredentialAppleID credential,
  ) async {
    final given = credential.givenName?.trim();
    final family = credential.familyName?.trim();
    final data = OAuthNameParts(prenom: given, nom: family).toMetadata();
    return _upsertMissingIdentity(data);
  }

  Future<User?> _upsertMissingIdentity(Map<String, dynamic> incoming) async {
    if (incoming.isEmpty) return null;

    final existing = _auth.currentUser?.userMetadata ?? {};
    final patch = <String, dynamic>{};
    for (final entry in incoming.entries) {
      final current = existing[entry.key];
      if (current is! String || current.trim().isEmpty) {
        patch[entry.key] = entry.value;
      }
    }
    if (patch.isEmpty) return null;

    final response = await _auth.updateUser(UserAttributes(data: patch));
    return response.user ?? _auth.currentUser;
  }
}

/// Enrichit les métadonnées Supabase avec le nom Google natif si besoin.
class GoogleIdentitySync {
  GoogleIdentitySync(this._auth);

  final AuthService _auth;

  Future<User?> applyAccountIfNeeded(
    GoogleSignInAccount account,
    User user,
  ) async {
    final fromAccount =
        OAuthNameParts.fromDisplayName(account.displayName).toMetadata();
    final fromUser = OAuthNameParts.fromMetadata(user.userMetadata).toMetadata();

    final incoming = <String, dynamic>{...fromUser, ...fromAccount};
    return _upsertMissingIdentity(incoming, user.userMetadata);
  }

  Future<User?> _upsertMissingIdentity(
    Map<String, dynamic> incoming,
    Map<String, dynamic>? existingMeta,
  ) async {
    if (incoming.isEmpty) return null;

    final existing = existingMeta ?? _auth.currentUser?.userMetadata ?? {};
    final patch = <String, dynamic>{};
    for (final entry in incoming.entries) {
      final current = existing[entry.key];
      if (current is! String || current.trim().isEmpty) {
        patch[entry.key] = entry.value;
      }
    }
    if (patch.isEmpty) return null;

    final response = await _auth.updateUser(UserAttributes(data: patch));
    return response.user ?? _auth.currentUser;
  }
}
