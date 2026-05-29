/// Chaînes paiement Stripe (réservation).
abstract final class DiscPay {
  DiscPay._();

  static const recapTitle = 'Paiement';
  static const recapCta = 'Payer et confirmer';
  static const recapTrust =
      'Le paiement est sécurisé par Stripe. Les fonds sont versés au prestataire après la prestation.';
  static const preparing = 'Préparation du paiement…';
  static const confirming = 'Confirmation de la réservation…';
  static const successPaid = 'Paiement accepté. Ta réservation est enregistrée.';
  static const receiptLabel = 'Reçu';
  static const receiptPaidOn = 'Payé le';
  static const receiptAmount = 'Montant payé';
  static const retry = 'Réessayer le paiement';

  static const errNotConfigured =
      'Paiement indisponible : clé Stripe manquante dans la configuration.';
  static const errWebUnsupported =
      'Le paiement en ligne est disponible sur l’application mobile (Android / iOS).';
  static const errPrestaNotPayable =
      'Ce prestataire n’accepte pas encore les paiements en ligne.';
  static const errCanceled =
      'Paiement annulé. Tu peux réessayer quand tu veux.';
  static const errGeneric =
      'Le paiement a échoué. Vérifie ta carte ou réessaie dans un instant.';
  static const errSlotTaken =
      'Ce créneau n’est plus disponible. Choisis un autre horaire.';
  static const errPaymentPending =
      'Paiement reçu, confirmation en cours… Réessaie dans quelques secondes.';

  static const recapCtaOnSite = 'Confirmer — paiement sur place';
  static const recapTrustOnSite =
      'Ce prestataire n’accepte pas encore le paiement en ligne. '
      'Tu règleras sur place le jour de la prestation.';
  static const doneBodyOnSite =
      'Ta réservation est enregistrée. Le paiement se fera sur place le jour J.';
}
