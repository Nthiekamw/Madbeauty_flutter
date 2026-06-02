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

  static const recapCtaOnSite = 'Confirmer la réservation';
  static const recapCtaPayAmount = 'Payer %s et confirmer';
  static const recapTrustOnSite =
      'Tu règleras la prestation chez le prestataire le jour J. '
      'Les frais MadBeauty éventuels sont réglés dans l’app à la confirmation.';
  static const doneBodyOnSite =
      'Ta réservation est enregistrée. Le solde de la prestation se règle sur place le jour J.';

  static const paymentModeTitle = 'Comment payer ?';
  static const paymentModeDeposit20 = 'Acompte 20 % dans l’app';
  static const paymentModeDeposit20Hint =
      'Le reste (%s) se paie sur place chez le prestataire.';
  static const paymentModeOnSite = 'Tout payer sur place';
  static const paymentModeOnSiteHint =
      'Prestation intégrale chez le prestataire. Frais MadBeauty éventuels dans l’app.';
  static const checkoutDueNow = 'À payer maintenant';
  static const checkoutOnSiteLater = 'À régler sur place';
  static const checkoutPlatformFee = 'Frais MadBeauty';
  static const checkoutDeposit = 'Acompte prestation (20 %)';
  static const checkoutReferralDiscount = 'Remise parrainage';
  static const checkoutServiceAfterDiscount = 'Prestation (après remise)';
  static const checkoutFreePlatform = 'Pas de frais MadBeauty (1ʳᵉ ou 2ᵉ réservation)';
  static const recapReferralDiscountBanner =
      'Ta remise parrainage −10 % est appliquée sur cette réservation.';
  static const errNoPaymentRequired =
      'Aucun paiement en ligne requis : confirme sans passer par la carte.';
  static const errDepositRequiresConnect =
      'Ce prestataire n’accepte pas encore l’acompte en ligne.';
}
