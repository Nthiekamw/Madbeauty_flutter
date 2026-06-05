/// Abonnement prestataire (Stripe Billing).
abstract final class DiscPrestaSub {
  DiscPrestaSub._();

  static const screenTitle = 'Mon abonnement';
  static const heroTitle = 'Offre professionnelle';
  static const heroBody =
      'Abonnement plateforme MadBeauty : publier ton profil et tes services sur le catalogue. '
      'Ce n’est pas l’encaissement de tes prestations (voir « Recevoir mes paiements » dans le profil).';
  static const heroBodyShort =
      'Publie ton profil sur le catalogue — distinct de l’encaissement des prestations.';
  static const tierSolo = '1 service';
  static const tierMulti = '2 services ou plus';
  static const monthly = 'Mensuel';
  static const yearly = 'Annuel';
  static const perMonth = '/ mois';
  static const perYear = '/ an';
  static const currentTier = 'Ton palier actuel';
  static const serviceCount = '%s service(s) publié(s)';
  static const profileTileTitle = 'Mon abonnement';
  static const profileTileSubtitle =
      'Abonnement catalogue — distinct de « Recevoir mes paiements »';
  static const accountPlansTitle = 'Abonnements professionnels';
  static const accountPlansHint =
      'Publie ton profil et tes services sur le catalogue MadBeauty.';
  static const accountPlansRecommended = 'Recommandé pour toi';
  static const profileTileSubtitleActive =
      'Actif pour le catalogue — configure l’encaissement dans ton profil';
  static const dashboardBannerTitle = 'Abonnement professionnel';
  static const dashboardBannerBody =
      'Gère ton abonnement et consulte ton palier.';
  static const onboardingTitle = 'Ton abonnement MadBeauty';
  static const onboardingBody =
      'Pour publier tes services sur le catalogue, un abonnement professionnel '
      'est requis. Tu peux t’abonner maintenant ou passer cette étape et le faire '
      'plus tard depuis ton profil.';
  static const skipForNow = 'Passer pour l’instant';
  static const onboardingCompactHint =
      'Tu peux t’abonner maintenant ou passer cette étape et le faire plus tard depuis ton profil.';
  static const viewFullDetails = 'Voir le détail des offres';
  static const registerHint =
      'Après la création du compte, tu pourras t’abonner depuis ton profil '
      '(mensuel ou annuel selon tes services). Tu pourras aussi passer cette étape.';

  static const subscribeMonthly = 'S’abonner (mensuel)';
  static const subscribeYearly = 'S’abonner (annuel)';
  static const manageBilling = 'Gérer la facturation';
  static const refreshStatus = 'Actualiser le statut';
  static const statusActive = 'Abonnement actif';
  static const statusNone = 'Aucun abonnement actif';
  static const statusPastDue = 'Paiement en retard — mets à jour ton moyen de paiement';
  static const statusCanceled = 'Abonnement résilié';
  static const statusIncomplete = 'Paiement à finaliser';
  static const renewsOn = 'Renouvellement le %s';
  static const payUnavailable = 'Paiement indisponible (configuration Stripe)';
  static const profileRequired =
      'Impossible de préparer ton profil prestataire. Reconnecte-toi puis réessaie.';
  static const checkoutErr = 'Impossible d’ouvrir le paiement';
  static const portalErr = 'Impossible d’ouvrir le portail de facturation';
  static const browserErr =
      'Impossible d’ouvrir le navigateur. Installe un navigateur puis réessaie.';
  static const returnSuccess =
      'Abonnement OK. Configure « Recevoir mes paiements » dans ton profil pour encaisser tes réservations.';
  static const returnCancel = 'Paiement annulé.';
  static const activeConnectHintTitle = 'Prochaine étape : encaissement';
  static const activeConnectHintBody =
      'Ton abonnement est actif pour le catalogue. Pour être payé après chaque prestation, '
      'configure la section « Recevoir mes paiements » dans ton profil (compte bancaire Stripe Connect).';
  static const activeConnectHintBodyShort =
      'Pour être payé par tes clientes, configure « Recevoir mes paiements » dans ton profil.';
  static const activeConnectHintCta = 'Configurer dans mon profil';
}
