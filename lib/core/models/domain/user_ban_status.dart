/// Statut de modération d'un compte ([user_profiles.is_banned]).
class UserBanStatus {
  const UserBanStatus({
    required this.isBanned,
    this.reason,
  });

  const UserBanStatus.notBanned() : isBanned = false, reason = null;

  final bool isBanned;
  final String? reason;
}
