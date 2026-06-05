import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/user/user_profile.dart';
import '../../../core/models/user_role.dart';

/// Nom affiché (prénom + nom, ou e-mail en secours).
String profileDisplayName({
  required UserProfile? profile,
  required String? email,
}) {
  final parts = [
    profile?.prenom?.trim(),
    profile?.nom?.trim(),
  ].where((p) => p != null && p.isNotEmpty).cast<String>().toList();
  if (parts.isNotEmpty) return parts.join(' ');
  final mail = email?.trim();
  if (mail != null && mail.isNotEmpty) return mail;
  return ShellStrings.profileNameFallback;
}

/// Libellé lisible des rôles serveur.
String profileRolesLabel(List<UserRole> roles) {
  final hasClient = roles.contains(UserRole.client);
  final hasPresta = roles.contains(UserRole.prestataire);
  if (hasClient && hasPresta) return ShellStrings.profileRoleDual;
  if (hasPresta) return ShellStrings.profileRolePresta;
  if (hasClient) return ShellStrings.profileRoleClient;
  return ShellStrings.profileRoleUnknown;
}

