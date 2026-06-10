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
      'Tu bénéficies de 5 jours d’essai gratuit pour apparaître dans le catalogue. '
      'Ensuite, active ton abonnement pour rester visible et gérer tes réservations.';
  static const trialBannerTitle = 'Essai gratuit en cours';
  static String trialBannerBody(int days) =>
      'Il te reste $days jour${days > 1 ? 's' : ''} pour tester le catalogue gratuitement. '
      'Pense à t’abonner avant la fin pour rester visible.';
  static const trialBannerCta = 'Voir les offres';
  static const trialBadge = 'Essai 5 jours';
  static const checkoutTrialHint =
      '5 jours d’essai offerts à l’abonnement — aucun prélèvement avant la fin de l’essai.';
  static const statusTrialing = 'Période d’essai Stripe en cours';
  static const statusCatalogTrial = 'Essai catalogue actif';
  static const skipForNow = 'Passer pour l’instant';
  static const onboardingCompactHint =
      'Abonnement obligatoire pour être visible dans le catalogue et gérer tes réservations.';
  static const subscriptionRequiredForCatalog =
      'Active ton abonnement pour terminer et être visible dans le catalogue.';
  static const notVisibleBannerTitle = 'Les clientes ne te voient pas';
  static const notVisibleBannerBody =
      'Ton profil est prêt, mais il est masqué du catalogue. Active ton abonnement maintenant pour recevoir des réservations.';
  static const notVisibleBannerCta = 'Activer maintenant';
  static const notVisibleBannerBadge = 'Action requise';
  static const notVisibleGateHint =
      'Active ton abonnement pour apparaître dans le catalogue et débloquer toutes les actions pro.';
  static const notVisibleReminderTitle = 'MadBeauty Pro';
  static const notVisibleReminderBody =
      'Urgent : ton profil est masqué du catalogue. Active ton abonnement pour être visible des clientes.';
  static const featureLockedTitle = 'Abonnement requis pour agir';
  static const featureLockedBody =
      'Sans abonnement actif, tu n’es pas visible et tu ne peux pas gérer tes réservations.';
  static const bookingActionLocked =
      'Abonne-toi pour confirmer ou refuser des réservations.';
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
  static const activeHeroBadge = 'Actif';
  static const activeHeroTitle = 'Ton abonnement est actif';
  static const activeHeroBody =
      'Ton profil et tes services peuvent être visibles sur le catalogue MadBeauty.';
  static String activeTierLabel(String tierLabel) =>
      'Palier : $tierLabel';
  static const activeIntervalMonthly = 'Facturation mensuelle';
  static const activeIntervalYearly = 'Facturation annuelle';
  static const activeSyncing = 'Mise à jour de ton abonnement…';
  static const plansSectionTitle = 'Comparer les offres';
  static const plansSectionSubtitle =
      'Le palier dépend du nombre de services que tu publies.';
}
