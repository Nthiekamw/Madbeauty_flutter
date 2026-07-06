import '../../../utils/trial_duration_format.dart';

/// Accès catalogue prestataire (essai / visibilité — sans paiement in-app).
abstract final class DiscPrestaSub {
  DiscPrestaSub._();

  static const screenTitle = 'Accès catalogue';
  static const heroTitle = 'Visibilité sur MadBeauty';
  static const heroBody =
      'Publie ton profil et tes services sur le catalogue MadBeauty. '
      'Le règlement des prestations se fait sur place chez toi, le jour J.';
  static const heroBodyShort =
      'Profil et services visibles sur le catalogue MadBeauty.';
  static const tierSolo = '1 service publié';
  static const tierMulti = '2 services ou plus';
  static const currentTier = 'Ton profil';
  static const serviceCount = '%s service(s) publié(s)';
  static const profileTileTitle = 'Accès catalogue';
  static const profileTileSubtitle =
      'Visibilité de ton salon dans le catalogue client';
  static const accountPlansTitle = 'Accès catalogue';
  static const accountPlansHint =
      'Vérifie si les clientes peuvent te trouver et réserver';
  static const accountPlansRecommended = 'Adapté à ton profil';
  static const profileTileSubtitleActive =
      'Visible sur le catalogue MadBeauty';
  static const dashboardBannerTitle = 'Accès catalogue';
  static const dashboardBannerBody =
      'Consulte ton essai et ta visibilité sur le catalogue.';
  static const onboardingTitle = 'Visibilité catalogue';
  static String onboardingBody(int days) => TrialDurationFormat.onboardingBody(days);
  static const trialBannerTitle = 'Essai catalogue en cours';
  static String trialBannerBody(int days) =>
      'Il te reste $days jour${days > 1 ? 's' : ''} pour tester la visibilité sur le catalogue. '
      'Complète ton profil pour inspirer confiance.';
  static const trialBannerCta = 'Voir mon statut';
  static String trialBadge(int days) => TrialDurationFormat.trialBadge(days);
  static String checkoutTrialHint(int days) =>
      TrialDurationFormat.checkoutTrialHint(days);
  static const statusTrialing = 'Essai catalogue actif';
  static const statusCatalogTrial = 'Essai catalogue actif';
  static const skipForNow = 'Passer pour l’instant';
  static String onboardingCompactHint(int days) =>
      '${TrialDurationFormat.labelShort(days)} d’essai catalogue pour apparaître dans le catalogue. '
      'Tu peux enregistrer ton profil maintenant et compléter les détails plus tard.';
  static const subscriptionRequiredForCatalog =
      'Complète ton profil pour être visible dans le catalogue.';
  static const notVisibleBannerTitle = 'Les clientes ne te voient pas';
  static const notVisibleBannerBody =
      'Ton profil est prêt, mais il est masqué du catalogue. Consulte ton statut ou complète les informations manquantes.';
  static const notVisibleBannerCta = 'Voir mon statut';
  static const notVisibleBannerBadge = 'Action requise';
  static const notVisibleGateHint =
      'Ton essai catalogue est terminé ou ton profil est incomplet. '
      'Complète ta fiche pour retrouver ta visibilité.';
  static const notVisibleReminderTitle = 'Visibilité catalogue';
  static const notVisibleReminderBody =
      'Ton profil n’est plus visible des clientes. Consulte ton accès catalogue depuis ton profil.';
  static const featureLockedTitle = 'Accès catalogue requis';
  static const featureLockedBody =
      'Sans visibilité catalogue, tu ne peux pas gérer tes réservations depuis l’app.';
  static const bookingActionLocked =
      'Active ta visibilité catalogue pour confirmer ou refuser des réservations.';
  static const viewFullDetails = 'Voir mon statut';
  static const registerHint =
      'Après la création du compte, tu pourras compléter ton profil prestataire '
      'et bénéficier d’un essai catalogue gratuit.';

  static const refreshStatus = 'Actualiser le statut';
  static const statusActive = 'Visible sur le catalogue';
  static const statusNone = 'Non visible sur le catalogue';
  static const statusPastDue = 'Visibilité suspendue';
  static const statusCanceled = 'Accès catalogue terminé';
  static const statusIncomplete = 'Profil à finaliser';
  static const activeHeroBadge = 'Actif';
  static const activeHeroTitle = 'Tu es visible sur le catalogue';
  static const activeHeroBody =
      'Ton profil et tes services peuvent être consultés par les clientes sur MadBeauty.';
  static String activeTierLabel(String tierLabel) => 'Profil : $tierLabel';
  static const activeSyncing = 'Mise à jour de ton statut…';
  static const plansSectionTitle = 'Ton profil';
  static const plansSectionSubtitle =
      'Le nombre de services publiés détermine l’affichage de ta fiche.';

  static const returnSuccess = 'Statut catalogue mis à jour.';
  static const returnCancel = 'Retour sans modification.';

  static const catalogHelpTitle = 'À quoi sert l’accès catalogue ?';
  static const catalogHelpVisibilityTitle = 'Être visible des clientes';
  static const catalogHelpVisibilityBody =
      'Ton profil, tes services et tes photos apparaissent dans le catalogue, '
      'la recherche et les suggestions MadBeauty.';
  static const catalogHelpBookingTitle = 'Recevoir des réservations';
  static const catalogHelpBookingBody =
      'Les clientes consultent tes créneaux et t’envoient une demande depuis l’app. '
      'Tu confirmes ou refuses depuis ton espace pro.';
  static const catalogHelpTrialTitle = 'Essai gratuit à l’inscription';
  static const catalogHelpTrialBody =
      'Tu testes la visibilité pendant l’essai catalogue. '
      'Le règlement des prestations se fait chez toi, le jour du rendez-vous.';
}
