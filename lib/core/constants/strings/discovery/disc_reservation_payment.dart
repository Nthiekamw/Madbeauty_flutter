/// Paiement réservation (client + prestataire).
abstract final class DiscResPay {
  DiscResPay._();

  static const sectionTitle = 'Paiement';
  static const modeDeposit20 = 'Acompte 20 % dans l’app';
  static const modeOnSite = 'Prestation sur place';
  static const modeUnknown = 'Paiement non précisé';

  static const paidInApp = 'Payé dans l’app';
  static const platformFee = 'Frais MadBeauty';
  static const depositReceived = 'Acompte reçu dans l’app';
  static const collectOnSite = 'À encaisser sur place';
  static const serviceTotal = 'Prix de la prestation';
  static const legacyPaid = 'Montant enregistré dans l’app';
}
