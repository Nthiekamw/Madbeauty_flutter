class AdminCatalogTrialSettings {
  const AdminCatalogTrialSettings({
    required this.catalogTrialDays,
    required this.prestatairesInTrial,
    required this.prestatairesExpiredWithoutSub,
  });

  final int catalogTrialDays;
  final int prestatairesInTrial;
  final int prestatairesExpiredWithoutSub;

  factory AdminCatalogTrialSettings.fromJson(Map<String, dynamic> json) {
    return AdminCatalogTrialSettings(
      catalogTrialDays: (json['catalog_trial_days'] as num?)?.toInt() ?? 90,
      prestatairesInTrial:
          (json['prestataires_in_trial'] as num?)?.toInt() ?? 0,
      prestatairesExpiredWithoutSub:
          (json['prestataires_expired_without_sub'] as num?)?.toInt() ?? 0,
    );
  }
}

class AdminPrestataireTrialSummary {
  const AdminPrestataireTrialSummary({
    required this.prestataireId,
    required this.userId,
    required this.email,
    this.displayName,
    this.catalogTrialEndsAt,
    required this.subscriptionStatus,
    required this.isInTrial,
  });

  final String prestataireId;
  final String userId;
  final String email;
  final String? displayName;
  final DateTime? catalogTrialEndsAt;
  final String subscriptionStatus;
  final bool isInTrial;

  String get label {
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return email;
  }

  factory AdminPrestataireTrialSummary.fromJson(Map<String, dynamic> json) {
    final endsRaw = json['catalog_trial_ends_at'];
    DateTime? endsAt;
    if (endsRaw is String && endsRaw.isNotEmpty) {
      endsAt = DateTime.tryParse(endsRaw);
    }
    return AdminPrestataireTrialSummary(
      prestataireId: json['prestataire_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['display_name'] as String?,
      catalogTrialEndsAt: endsAt,
      subscriptionStatus: json['subscription_status'] as String? ?? 'none',
      isInTrial: json['is_in_trial'] as bool? ?? false,
    );
  }
}
