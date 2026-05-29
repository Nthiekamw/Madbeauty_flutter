/// Stripe Connect — onboarding prestataire.
abstract final class DiscStripeConnect {
  DiscStripeConnect._();

  static const sectionTitle = 'Recevoir mes paiements';
  static const sectionSubtitle =
      'Connecte ton compte bancaire via Stripe pour être payé après chaque prestation.';
  static const statusNotStarted = 'Non configuré';
  static const statusPending = 'Inscription en cours';
  static const statusComplete = 'Compte actif';
  static const statusRestricted = 'Compte restreint';
  static const ctaStart = 'Configurer Stripe Connect';
  static const ctaContinue = 'Continuer l’inscription';
  static const ctaRefresh = 'Actualiser le statut';
  static const openErr = 'Impossible d’ouvrir la page Stripe.';
  static const syncErr = 'Impossible de récupérer le statut Stripe.';
  static const alreadyActive = 'Ton compte de paiement est déjà actif.';
  static const stripeUnavailable =
      'Stripe n’est pas configuré dans l’application.';
  static const errPlatformConnectDisabled =
      'Stripe Connect n’est pas activé sur le compte MadBeauty. '
      'Un administrateur doit l’activer sur dashboard.stripe.com/connect (mode test).';
  static const errInvalidRedirectUrl =
      'URL de retour Stripe invalide. Redéploie les fonctions Connect '
      '(voir docs/STRIPE_CONNECT_SETUP.md) et supprime les anciens secrets com.madbeauty://.';
}
