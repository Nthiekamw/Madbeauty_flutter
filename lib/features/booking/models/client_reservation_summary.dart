class ClientReservationSummary {
  const ClientReservationSummary({
    required this.id,
    required this.dateHeure,
    required this.statut,
    this.serviceName,
    this.prestataireName,
    this.prestataireAvatarUrl,
  });

  final String id;
  final DateTime dateHeure;
  final String statut;
  final String? serviceName;
  final String? prestataireName;
  /// Photo affichée dans la liste (profil identité du prestataire).
  final String? prestataireAvatarUrl;
}
