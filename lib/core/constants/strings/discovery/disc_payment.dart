/// Chaînes récap réservation (paiement sur place uniquement).
abstract final class DiscPay {
  DiscPay._();

  static const recapTitle = 'Réservation';
  static const recapCta = 'Confirmer la réservation';
  static const recapTrust =
      'Tu règleras la prestation chez le prestataire le jour J. '
      'Aucun paiement dans l’app.';
  static const preparing = 'Préparation de la réservation…';
  static const confirming = 'Confirmation de la réservation…';
  static const successPaid = 'Ta réservation est enregistrée.';
  static const receiptLabel = 'Récapitulatif';
  static const receiptPaidOn = 'Réservé le';
  static const receiptAmount = 'Montant sur place';
  static const retry = 'Réessayer';

  static const recapCtaOnSite = 'Confirmer la réservation';
  static const recapTrustOnSite =
      'Tu règleras la prestation chez le prestataire le jour J. '
      'Aucun paiement dans l’app pour cette réservation.';
  static const doneBodyOnSite =
      'Ta réservation est enregistrée. Le solde de la prestation se règle sur place le jour J.';

  static const recapAmountTitle = 'Montant';
  static const checkoutServiceAfterDiscount = 'Prestation (après remise)';
  static const checkoutPlatformFee = 'Frais MadBeauty';
  static const checkoutOnSiteLater = 'À régler sur place';
  static const checkoutDueOnSite = 'Total sur place';
  static const checkoutDeposit = 'Acompte prestation (20 %)';
  static const checkoutReferralDiscount = 'Remise parrainage';
  static const recapReferralDiscountBanner =
      'Ta remise parrainage −10 % est appliquée sur cette réservation.';
  static const checkoutFreePlatformCount1 =
      'Pas de frais MadBeauty (1ʳᵉ réservation)';
  static String checkoutFreePlatform(int freeBookingCount) {
    if (freeBookingCount <= 1) return checkoutFreePlatformCount1;
    return 'Pas de frais MadBeauty ($freeBookingCount premières réservations)';
  }
}
