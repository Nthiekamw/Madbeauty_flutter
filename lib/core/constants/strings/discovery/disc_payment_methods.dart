/// Chaînes profil prestataire (encaissement sur place — sans paiement in-app).
abstract final class DiscPaymentMethods {
  DiscPaymentMethods._();

  static const sectionTitle = 'Règlement des prestations';
  static const sectionSubtitle =
      'Les clientes règlent sur place le jour de la prestation.';
  static const payoutTitle = 'Recevoir mes paiements';
  static const payoutHint =
      'Les réservations se règlent directement chez toi, le jour J.';
  static const payoutConfigure = 'En savoir plus';
  static const payoutContinue = 'En savoir plus';
  static const payoutRefresh = 'Actualiser';
  static const payoutActive = 'Règlement sur place';
  static const payoutPending = 'Information';
  static const payoutNotStarted = 'Sur place le jour J';
}
