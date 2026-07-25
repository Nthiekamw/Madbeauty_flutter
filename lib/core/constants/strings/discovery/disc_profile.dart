/// Profil client.
abstract final class DiscProfile {
  DiscProfile._();

  static const sectionMyInfo = 'Mes informations';
  static const sectionPreferences = 'Mes préférences';
  static const sectionAccount = 'Mon compte';
  static const webPageSubtitle =
      'Paramètres, préférences et espace client ou prestataire';

  static const labelEmail = 'E-mail';
  static const labelPhone = 'Téléphone';
  static const labelCity = 'Ville';

  static const statAppointments = 'Rendez-vous';
  static const statFavorites = 'Favoris';
  static const statRating = 'Note moyenne';

  static const prefPush = 'Notifications push';
  static const prefPushHint = 'Alertes réservations et rappels';
  static const prefPushInactiveHint =
      'Non activées — autorise-les pour ne rien manquer';
  static const prefPushWebHint =
      'Alertes réservations et messages sur le navigateur';
  static const prefPushWebInactiveHint =
      'Active les notifications pour ne rien manquer';
  static const prefPushWebFootnote =
      'Ajoute FIREBASE_WEB_VAPID_KEY pour les alertes hors session navigateur.';
  static const prefPushPromptTitle = 'Active les notifications';
  static const prefPushPromptBody =
      'Reçois les confirmations de réservation, les messages et les rappels '
      'même quand l’app est fermée.';
  static const prefPushPromptEnable = 'Activer';
  static const prefPushPromptLater = 'Plus tard';
  static const prefOpenSettings = 'Ouvrir les réglages';
  static const prefLocation = 'Géolocalisation';
  static const prefLocationHint = 'Pros près de toi et tri par distance';

  static const prefBiometric = 'Déverrouiller avec Face ID';
  static const prefBiometricTouchId = 'Déverrouiller avec Touch ID';
  static const prefBiometricFingerprint = 'Déverrouiller avec empreinte';
  static const prefBiometricGeneric = 'Déverrouillage biométrique';
  static const prefBiometricHint =
      'Protège l’accès à ton compte à l’ouverture de l’app';
  static const prefBiometricInactiveHint =
      'Désactivé — connexion classique à chaque ouverture';
  static const prefBiometricFaceIdLabel = 'Face ID';
  static const prefBiometricFingerprintLabel = 'empreinte digitale';
  static const prefBiometricGenericLabel = 'biométrie';
  static const prefBiometricAuthReason =
      'Déverrouille MadBeauty pour accéder à ton compte.';
  static const prefBiometricEnabled = 'Déverrouillage biométrique activé.';
  static const prefBiometricDisabled = 'Déverrouillage biométrique désactivé.';
  static const prefBiometricUnavailable =
      'Biométrie indisponible sur cet appareil.';
  static const prefBiometricSetupFailed =
      'Impossible d’activer la biométrie. Vérifie les réglages de ton téléphone.';

  static const actionEditAccount = 'Modifier mon compte';

  static const editAccountTitle = 'Modifier mon compte';
  static const editAccountSubtitle =
      'Mets à jour tes informations personnelles.';
  static const editAccountSectionIdentity = 'Identité';
  static const editAccountSectionContact = 'Contact';
  static const editAccountSectionLocation = 'Localisation';
  static const editAccountEmailHint =
      'L’e-mail sert à la connexion. Pour le changer, contacte le support.';
  static const editAccountSave = 'Enregistrer les modifications';
  static const editAccountSaved = 'Compte mis à jour.';
  static const editAccountError =
      'Impossible d’enregistrer. Réessaie dans un instant.';
  static const editAccountNameRequired =
      'Indique au moins un prénom ou un nom.';
  static const actionFavorites = 'Mes favoris';
  static const actionReviews = 'Mes avis';
  static const actionHistory = 'Historique';
  static const actionHelp = 'Aide & informations';
  static const actionReferral = 'Parrainage';
  static const actionReferralHint = 'Invite tes amies avec ton code';
  static const ambassadorBadgeLabel = 'Ambassadrice';
  static const historyTitle = 'Historique';
  static const historySubtitle =
      'Tes prestations passées et annulées.';
  static const sectionAdmin = 'Administration';
  static const adminBadgeLabel = 'Administrateur';
  static const adminSectionSubtitle =
      'Outils de modération et de gestion de la plateforme';
  static const adminBackofficeLabel = 'Back-office';
  static const adminModerationHubTitle = 'Modération & contenus';
  static const adminModerationHubBody =
      'Vérifications prestataires, signalements et galerie des réalisations.';
  static const adminSupportHubTitle = 'Support & signalements';
  static const adminSupportHubBody =
      'Bugs remontés par les utilisateurs et fils de support.';
  static const adminManagementHubTitle = 'Gestion de la plateforme';
  static const adminManagementHubBody =
      'Utilisateurs, réservations, tarifs, notifications et journal d’audit.';
  static const adminHomeQuickAccessTitle = 'Accès rapide';

  static const adminHomeWelcomeTitle = 'Espace administrateur';
  static const adminHomeWelcomeBody =
      'Gère la modération, les vérifications et les signalements de la plateforme.';
  static const adminHomeActionsTitle = 'Actions rapides';
  static const adminHomeStatVerifications = 'Vérif. en attente';
  static const adminHomeStatReports = 'Signalements à traiter';
  static const adminHomeIsolationHint =
      'Tu es connecté en mode admin : les espaces client et prestataire ne sont pas accessibles avec ce compte.';
  static const adminProfileRoleHint =
      'Compte équipe MadBeauty — accès réservé à la modération.';
  static const adminSignOutErr =
      'Impossible de te déconnecter pour le moment. Réessaie.';
  static const actionAdminVerifications = 'Demandes de vérification';
  static const actionAdminVerificationsHint =
      'Valider ou retirer la vérification des prestataires';
  static const adminVerificationsIntroTitle = 'Vérification des prestataires';
  static const adminVerificationsIntroBody =
      'Examine les demandes et valide les profils professionnels fiables.';
  static const adminReportsIntroTitle = 'Modération des signalements';
  static const adminReportsIntroBody =
      'Consulte les rapports utilisateurs et marque-les comme traités.';
  static const actionAdminBugReports = 'Bugs signalés';
  static const actionAdminBugReportsHint =
      'Dysfonctionnements techniques remontés par les utilisateurs.';
  static const actionAdminUserSupport = 'Support utilisateurs';
  static const actionAdminUserSupportHint =
      'Conversations avec les clientes et prestataires.';
  static const actionAdminReports = 'Signalements';
  static const actionAdminReportsHint =
      'Consulter et traiter les signalements utilisateurs';
  static const adminReportsFilterPending = 'À traiter';
  static const adminReportsFilterAll = 'Tous';
  static const adminReportsEmpty = 'Aucun signalement pour le moment.';
  static const adminReportsStatusPending = 'À traiter';
  static const adminReportsStatusReviewed = 'Traité';
  static const adminReportsMarkReviewed = 'Marquer comme traité';
  static const adminReportsMarkedReviewed = 'Signalement marqué comme traité.';
  static const adminReportsMarkReviewedErr =
      'Impossible de mettre à jour ce signalement.';
  static const adminReportsModerateHide = 'Masquer le profil';
  static const adminReportsModerateSuspend = 'Suspendre la conversation';
  static const adminReportsModerateDelete = 'Supprimer le message';
  static const adminReportsModerateDismiss = 'Classer sans action';
  static const adminReportsModerated = 'Action de modération appliquée.';
  static const adminReportsModerateErr =
      'Impossible d’appliquer cette action pour le moment.';

  static const actionAdminRealisationPhotos = 'Photos de réalisations';
  static const actionAdminRealisationPhotosHint =
      'Consulter, télécharger et modérer la galerie des prestataires.';
  static const adminRealisationPhotosIntroTitle = 'Modération galerie';
  static const adminRealisationPhotosIntroBody =
      'Parcours les photos et vidéos publiées. Supprime le contenu inadapté '
      'ou applique un signalement, un avertissement ou un bannissement.';
  static const adminRealisationPhotosSearchHint = 'Salon, nom ou e-mail…';
  static const adminRealisationPhotosEmpty = 'Aucune photo de réalisation.';
  static String adminRealisationPhotosUserMediaCount(int count) =>
      '$count média${count > 1 ? 's' : ''}';
  static const adminRealisationPhotosDownload = 'Ouvrir / télécharger';
  static const adminRealisationPhotosDelete = 'Supprimer';
  static const adminRealisationPhotosFlagObscene = 'Signaler (obscène)';
  static const adminRealisationPhotosWarn = 'Avertir le compte';
  static const adminRealisationPhotosBan = 'Bannir le compte';
  static const adminRealisationPhotosDeleteConfirmTitle = 'Supprimer cette photo ?';
  static const adminRealisationPhotosDeleteConfirmBody =
      'Elle sera retirée de la galerie publique et du stockage.';
  static const adminRealisationPhotosFlagConfirmTitle = 'Signaler comme obscène ?';
  static const adminRealisationPhotosFlagConfirmBody =
      'La photo sera supprimée et un signalement interne sera enregistré.';
  static const adminRealisationPhotosWarnDialogTitle = 'Avertir le prestataire';
  static const adminRealisationPhotosWarnHint =
      'Message visible dans ses notifications.';
  static const adminRealisationPhotosWarnDefault =
      'Une photo de votre galerie ne respecte pas nos règles. '
      'Merci de publier uniquement du contenu professionnel.';
  static const adminRealisationPhotosModerated = 'Action de modération appliquée.';
  static const adminRealisationPhotosModerateErr =
      'Impossible d’appliquer cette action.';
  static const adminRealisationPhotosOpenErr =
      'Impossible d’ouvrir cette image.';
  static const adminRealisationPhotosTargetType = 'Photo de réalisation';

  static const actionAdminUsers = 'Utilisateurs';
  static const actionAdminUsersHint =
      'Rechercher, bannir et gérer les rôles';
  static const adminUsersIntroTitle = 'Gestion des utilisateurs';
  static const adminUsersIntroBody =
      'Recherche par e-mail, nom ou identifiant. Bannissement et attribution des rôles.';
  static const adminUsersSearchHint = 'E-mail, nom ou ID…';
  static const adminUsersSearchAction = 'Chercher';
  static const adminUsersEmpty = 'Aucun utilisateur trouvé.';
  static const adminUsersSearchErr =
      'Impossible de charger les utilisateurs. Vérifie ta connexion ou réessaie.';
  static const adminUsersBan = 'Bannir';
  static const adminUsersUnban = 'Débannir';
  static const adminUsersBannedBadge = 'Banni';
  static const adminActionOk = 'Action enregistrée.';
  static const adminActionErr = 'Action impossible pour le moment.';

  static const actionAdminAccountDeletions = 'Suppressions de compte';
  static const actionAdminAccountDeletionsHint =
      'Valider les demandes de suppression définitive';
  static const adminAccountDeletionsIntroTitle = 'Demandes de suppression';
  static const adminAccountDeletionsIntroBody =
      'Les utilisateurs demandent la suppression depuis leur profil. '
      'Tu confirmes ici la suppression définitive de leur compte uniquement.';
  static const adminAccountDeletionsEmpty = 'Aucune demande en attente.';
  static const adminAccountDeletionsLoadErr =
      'Impossible de charger les demandes. Réessaie.';
  static const adminAccountDeletionExecute = 'Supprimer définitivement';
  static const adminAccountDeletionConfirm = 'Supprimer le compte';
  static const adminAccountDeletionDialogBody =
      'Cette action est irréversible : le compte et les données associées seront effacés.';
  static String adminAccountDeletionDialogTitle(String name) =>
      'Supprimer le compte de $name ?';
  static String adminAccountDeletionRequestedAt(DateTime at) =>
      'Demandé le ${at.day.toString().padLeft(2, '0')}/'
      '${at.month.toString().padLeft(2, '0')}/${at.year} '
      'à ${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}';
  static const adminAccountDeletionDone = 'Compte supprimé définitivement.';
  static const adminAccountDeletionErr =
      'Impossible de supprimer ce compte pour le moment.';

  static const actionAdminReservations = 'Réservations & paiements';
  static const actionAdminReservationsHint =
      'Suivi des réservations et paiements Stripe';
  static const adminReservationsIntroTitle = 'Réservations et paiements';
  static const adminReservationsIntroBody =
      'Vue globale des rendez-vous, statuts et montants capturés.';
  static const adminReservationsEmpty = 'Aucune réservation pour le moment.';
  static const adminReservationsFilterStatut = 'Statut réservation';
  static const adminReservationsFilterPayment = 'Statut paiement';
  static const adminReservationsFilterAll = 'Tous';
  static const adminReservationsFilterFrom = 'Du';
  static const adminReservationsFilterTo = 'Au';
  static const adminReservationsClearDates = 'Effacer les dates';

  static const adminUsersBanReasonLabel = 'Motif du bannissement';
  static const adminUsersBanReasonHint = 'Ex. signalements répétés, fraude…';
  static const adminUsersBanReasonRequired = 'Le motif est obligatoire.';
  static const adminUsersBanCancel = 'Annuler';
  static const adminUsersBanConfirm = 'Bannir';
  static String adminUsersBanDialogTitle(String name) =>
      'Bannir $name ?';

  static const actionAdminPush = 'Notifications push';
  static const actionAdminPushHint =
      'Envoyer une annonce ou un message aux utilisateurs';

  static const actionAdminSubscriptionTrial = 'Essai abonnement prestataire';
  static const actionAdminSubscriptionTrialHint =
      'Durée d’essai gratuit catalogue (3 mois par défaut) et prolongations';
  static const actionAdminBookingPlatformFee = 'Frais réservation client';
  static const actionAdminBookingPlatformFeeHint =
      'Montant prélevé dans l’app et nombre de réservations gratuites.';
  static const adminBookingFeeIntroTitle = 'Frais MadBeauty (réservations)';
  static const adminBookingFeeIntroBody =
      'Par défaut aucun frais n’est prélevé au client. Tu peux définir un montant '
      'fixe (ex. 1 €) prélevé uniquement lorsque le client paie un acompte en ligne '
      '(prestataire ayant activé l’option), à partir d’un certain nombre de réservations.';
  static const adminBookingFeeAmountLabel = 'Montant par réservation';
  static const adminBookingFeeAmountHint = 'Montant en euros';
  static const adminBookingFeeAmountHelper =
      '0 € = aucun paiement dans l’app pour les frais plateforme.';
  static const adminBookingFeeFreeCountLabel = 'Réservations sans frais';
  static const adminBookingFeeFreeCountHint = 'Nombre de réservations gratuites';
  static const adminBookingFeeFreeCountHelper =
      'Ex. 2 = pas de frais sur les 2 premières réservations du client.';
  static const adminBookingFeeSaveAction = 'Enregistrer';
  static const adminBookingFeeSaved = 'Frais réservation mis à jour.';
  static const adminBookingFeeInvalid =
      'Montant (0–1000 €) ou nombre de réservations gratuites (0–100) invalide.';
  static const adminTrialIntroTitle = 'Essai catalogue prestataire';
  static const adminTrialIntroBody =
      'Les nouveaux prestataires bénéficient d’un essai gratuit pour apparaître dans le catalogue. '
      'Tu peux modifier la durée par défaut et prolonger l’essai d’un prestataire.';
  static const adminTrialDefaultLabel = 'Durée par défaut (jours)';
  static const adminTrialDefaultHint =
      'Appliquée aux nouveaux profils prestataires (90 jours = 3 mois).';
  static const adminTrialPreset3Months = '3 mois (90 j)';
  static const adminTrialPreset1Month = '1 mois (30 j)';
  static const adminTrialPreset6Months = '6 mois (180 j)';
  static const adminTrialSaveAction = 'Enregistrer la durée';
  static const adminTrialSaved = 'Durée d’essai mise à jour.';
  static const adminTrialApplyAllTitle = 'Prolonger tous les non abonnés';
  static const adminTrialApplyAllBody =
      'Réinitialise l’essai catalogue à la durée par défaut pour tous les prestataires sans abonnement actif.';
  static const adminTrialApplyAllAction = 'Appliquer à tous';
  static String adminTrialApplyAllDone(int count) =>
      'Essai prolongé pour $count prestataire${count > 1 ? 's' : ''}.';
  static const adminTrialStatsInTrial = 'En essai actif';
  static const adminTrialStatsExpired = 'Essai expiré (sans abo.)';
  static const adminTrialSearchHint = 'Email, nom ou ID prestataire…';
  static const adminTrialSearchEmpty = 'Aucun prestataire trouvé.';
  static const adminTrialSearchEmptyBody =
      'Recherche par email, nom ou identifiant prestataire.';
  static const adminTrialExtendAction = 'Prolonger';
  static const adminTrialExtendDaysLabel = 'Jours à ajouter';
  static const adminTrialExtendDaysHint = 'Ex. 30';
  static String adminTrialExtendDialogTitle(String name) =>
      'Prolonger l’essai — $name';
  static const adminTrialExtendConfirm = 'Prolonger';
  static const adminTrialExtendDone = 'Essai prolongé.';
  static const adminTrialEndsAt = 'Fin d’essai';
  static const adminTrialStatusActive = 'Essai actif';
  static const adminTrialStatusExpired = 'Essai expiré';
  static const adminTrialStatusSubscribed = 'Abonné';
  static const adminTrialInvalidDays = 'Indique une durée entre 1 et 730 jours.';

  static const adminPushIntroTitle = 'Envoi de notifications push';
  static const adminPushIntroBody =
      'Diffuse un message sur les appareils des utilisateurs ayant activé les notifications. Les comptes admin sont exclus.';
  static const adminPushAudienceLabel = 'Destinataires';
  static const adminPushAudienceAll = 'Tous';
  static const adminPushAudienceClients = 'Clientes';
  static const adminPushAudiencePrestataires = 'Prestataires';
  static const adminPushAudiencePrestataireIncomplete =
      'Prestas — profil incomplet';
  static const adminPushAudienceUser = 'Un utilisateur';
  static const adminPushTemplatesLabel = 'Modèles prêts à l’emploi';
  static const adminPushTemplatesHint =
      'Un tap préremplit le titre, le message, l’audience et l’écran d’ouverture.';
  static const adminPushTemplateIncompleteProfile = 'Profil presta incomplet';
  static const adminPushTemplateAppUpdate = 'Nouvelle mise à jour';
  static const adminPushTemplateSubscription = 'Abonnement catalogue';
  static const adminPushTemplateCatalogHidden = 'Profil masqué';
  static const adminPushTemplateClientsWelcome = 'Clients — découverte';
  static const adminPushTemplateCustom = 'Message libre';
  static const adminPushTplIncompleteTitle = 'Complète ton profil MadBeauty';
  static const adminPushTplIncompleteBody =
      'Ton profil pro est encore incomplet. Ajoute les infos manquantes pour apparaître dans le catalogue et recevoir des clientes.';
  static const adminPushTplAppUpdateTitle = 'Nouvelle mise à jour MadBeauty';
  static const adminPushTplAppUpdateBody =
      'Une nouvelle version de MadBeauty est disponible. Mets à jour l’app pour profiter des dernières améliorations.';
  static const adminPushTplSubscriptionTitle = 'Active ton abonnement';
  static const adminPushTplSubscriptionBody =
      'Passe en abonnement pour rester visible dans le catalogue et continuer à recevoir des réservations.';
  static const adminPushTplCatalogHiddenTitle =
      'Ton salon est masqué du catalogue';
  static const adminPushTplCatalogHiddenBody =
      'Les clientes ne voient plus ton profil. Vérifie ton abonnement ou ton essai catalogue pour réactiver ta visibilité.';
  static const adminPushTplClientsWelcomeTitle =
      'Trouve ton prochain RDV beauté';
  static const adminPushTplClientsWelcomeBody =
      'Parcours le catalogue MadBeauty et réserve chez un prestataire près de chez toi.';
  static const adminPushTitleLabel = 'Titre';
  static const adminPushTitleHint = 'Ex. Nouveauté MadBeauty';
  static const adminPushBodyLabel = 'Message';
  static const adminPushBodyHint = 'Texte affiché dans la notification…';
  static const adminPushPreviewLoading = 'Calcul des destinataires…';
  static String adminPushPreviewCount(int count) =>
      '$count appareil${count > 1 ? 's' : ''} joignable${count > 1 ? 's' : ''}';
  static const adminPushRefreshPreview = 'Actualiser';
  static const adminPushSendAction = 'Envoyer';
  static const adminPushConfirmTitle = 'Confirmer l’envoi ?';
  static String adminPushConfirmBody(int count) =>
      'Cette notification sera envoyée à $count appareil${count > 1 ? 's' : ''}.';
  static const adminPushConfirmAudience = 'Audience';
  static const adminPushConfirmOpen = 'Ouverture';
  static const adminPushConfirmMessage = 'Message';
  static const adminPushFieldsRequired =
      'Le titre et le message sont obligatoires.';
  static const adminPushUserRequired =
      'Sélectionne un utilisateur destinataire.';
  static String adminPushSentSummary(int sent, int failed, int recipients) {
    if (recipients == 0) {
      return 'Aucun appareil joignable pour cette sélection.';
    }
    if (failed == 0) {
      return 'Notification envoyée à $sent appareil${sent > 1 ? 's' : ''}.';
    }
    return '$sent envoyée${sent > 1 ? 's' : ''}, $failed échec${failed > 1 ? 's' : ''}.';
  }
  static const adminPushExcludeBannedLabel = 'Exclure les utilisateurs bannis';
  static const adminPushExcludeBannedHint =
      'Les comptes bannis ne recevront pas la notification.';
  static const adminPushNavLabel = 'À l’ouverture, ouvrir…';
  static const adminPushNavNone = 'L’application seulement';
  static const adminPushNavClientHome = 'Accueil cliente';
  static const adminPushNavClientReservations = 'Mes réservations (cliente)';
  static const adminPushNavClientSearch = 'Recherche prestataires';
  static const adminPushNavClientMessages = 'Messages (cliente)';
  static const adminPushNavPrestataireDashboard = 'Tableau de bord pro';
  static const adminPushNavPrestataireSubscription = 'Abonnement pro';
  static const adminPushNavPrestataireProfileEdit = 'Profil pro (édition)';
  static const adminPushNavBooking = 'Écran de réservation';
  static const adminPushPrestataireIdLabel = 'ID prestataire (UUID)';
  static const adminPushPrestataireIdHint = 'Obligatoire pour l’écran de réservation';
  static const adminPushServiceIdLabel = 'ID service (optionnel)';
  static const adminPushServiceIdHint = 'Pré-sélectionner un service';
  static const adminPushBookingNavRequired =
      'L’ID prestataire est requis pour ouvrir l’écran de réservation.';

  static const actionAdminAudit = 'Journal d’audit';
  static const actionAdminAuditHint =
      'Historique des actions admin et vérifications';
  static const adminAuditIntroTitle = 'Journal d’audit';
  static const adminAuditIntroBody =
      'Trace des actions de modération, bannissements et vérifications.';
  static const adminAuditTabGeneral = 'Actions admin';
  static const adminAuditTabVerifications = 'Vérifications';
  static const adminAuditEmpty = 'Aucune entrée pour le moment.';
  static const adminAuditVerificationsEmpty =
      'Aucun événement de vérification.';

  static const adminHomeStatUsers = 'Utilisateurs';
  static const adminHomeStatClients = 'Clients';
  static const adminHomeStatPrestataires = 'Prestataires';
  static const adminHomeStatReservations = 'Réservations';
  static const adminHomeStatRevenue = 'Revenus capturés';
  static const adminHomeAnalyticsTitle = 'Vue d’ensemble';
  static const adminCountryStatsTitle = 'Réservations par pays';
  static const adminCountryStatsEmpty =
      'Aucune réservation enregistrée pour le moment.';
  static const adminCountryStatsThisMonth = 'Ce mois';
  static const adminCountryStatsSalons = 'Salons';
  static const adminCountryStatsRevenue = 'Revenus';
  static const adminCountryUnknown = 'Non renseigné';

  static const prestataireVerificationRequestTitle = 'Badge vérifié';
  static const prestataireVerificationRequestBody =
      'Demande la vérification de ton profil pour inspirer confiance aux clientes.';
  static const prestataireVerificationRequestCta = 'Demander la vérification';
  static const prestataireVerificationRequestAgainCta =
      'Refaire une demande de vérification';
  static const prestataireVerificationPending =
      'Demande envoyée — l’équipe examine ton profil.';
  static const prestataireVerificationVerified = 'Profil vérifié';
  static const prestataireVerificationVerifiedBody =
      'Ton profil affiche le badge vérifié. Tu n’as plus besoin de faire une demande.';
  static const prestataireVerificationVerifiedSince =
      'Approuvé le %s';
  static const prestataireVerificationRevokedTitle =
      'Corrections demandées par l’équipe';
  static const prestataireVerificationRevokedHint =
      'Une fois les points corrigés sur ton profil, tu peux renvoyer une demande.';
  static const prestataireVerificationRequestOk = 'Demande envoyée.';
  static const prestataireVerificationRequestErr =
      'Impossible d’envoyer la demande pour le moment.';

  static const adminVerificationFilterPending = 'En attente';
  static const adminVerificationFilterAll = 'Tous';
  static const adminVerificationEmpty = 'Aucune demande pour le moment.';
  static const adminVerificationApproveOk = 'Vérification validée.';
  static const adminVerificationApproveErr =
      'Impossible de valider pour le moment.';
  static const adminVerificationRevokeOk = 'Vérification retirée.';
  static const adminVerificationRevokeErr =
      'Impossible de retirer pour le moment. Indique un motif.';
  static const adminVerificationRevokeTitle = 'Retirer la vérification';
  static const adminVerificationRevokeBody =
      'Explique au prestataire ce qu’il doit corriger. Ce message lui sera envoyé.';
  static const adminVerificationRevokeNoteLabel = 'Motif';
  static const adminVerificationRevokeNoteHint =
      'Ex. : photos floues, adresse incomplète…';
  static const adminVerificationRevokeNoteTooShort =
      'Le motif doit contenir au moins 3 caractères.';
  static const adminVerificationRevokeConfirm = 'Retirer et notifier';
  static const adminVerificationChipVerified = 'Vérifié';
  static const adminVerificationChipNotVerified = 'Non vérifié';
  static const adminVerificationApproveCta = 'Valider';
  static const adminVerificationRevokeCta = 'Retirer la vérification';
  static String adminVerificationRequestedAt(DateTime at) =>
      'Demandé le ${at.toLocal()}';
  static String adminVerificationSalon(String salon) => 'Salon : $salon';
  static String adminVerificationVille(String ville) => 'Ville : $ville';

  static const signOut = 'Se déconnecter';
  static const deleteAccount = 'Supprimer mon compte';
  static const supportUser = 'Support utilisateur';
  static const supportUserHint = 'Discuter avec l’admin';
  static String supportUserUnreadHint(int count) =>
      count == 1
          ? '1 message non lu de l’équipe'
          : '$count messages non lus de l’équipe';

  static const deleteAccountTitle = 'Supprimer le compte ?';
  static const deleteAccountBody =
      'Ta demande sera transmise à l’équipe MadBeauty. '
      'Un administrateur validera la suppression définitive de ton compte et de tes données. '
      'Tu seras déconnecté immédiatement.';
  static const deleteAccountConfirm = 'Demander la suppression';
  static const deleteAccountDone =
      'Demande envoyée. Tu es déconnecté — l’équipe traitera la suppression sous peu.';
  static const deleteAccountErr =
      'Impossible d’envoyer la demande pour l’instant. Réessaie plus tard.';

  static const prefPushEnabled = 'Notifications activées.';
  static const prefPushWebEnabled = 'Notifications activées.';
  static const prefPushDisabled = 'Notifications désactivées.';
  static const prefPushDenied =
      'Autorise les notifications dans les réglages du téléphone.';
  static const prefLocationEnabled = 'Géolocalisation activée.';
  static const prefLocationDisabled = 'Géolocalisation désactivée.';
  static const prefLocationDenied =
      'Autorise la localisation dans les réglages du téléphone.';

  static const comingSoon = 'Bientôt disponible.';

  static const roleSpaceTitle = 'Mon espace';
  static const roleSpaceDualHint =
      'Bascule entre réservation client et gestion de ton activité.';
  static const roleClientTitle = 'Client';
  static const roleClientSub = 'Découvrir & réserver';
  static const rolePrestaTitle = 'Prestataire';
  static const rolePrestaSub = 'Agenda & services';
  static const roleActiveBadge = 'Actif';
  static const roleSwitchAction = 'Ouvrir';

  static const becomePrestaCardTitle = 'Propose tes services sur MadBeauty';
  static const becomePrestaCardBody =
      'Crée ton espace pro en quelques minutes : profil, spécialités, créneaux.';
  static const becomePrestaBenefit1 = 'Visibilité auprès des clientes';
  static const becomePrestaBenefit2 = 'Agenda et réservations';
  static const becomePrestaBenefit3 = 'Portfolio de réalisations';
  static const becomePrestaCta = 'Commencer';

  static const becomeClientCardTitle = 'Réserver en tant que cliente';
  static const becomeClientCardBody =
      'Active ton espace client pour découvrir des prestataires, réserver et gérer tes rendez-vous.';
  static const becomeClientBenefit1 = 'Recherche et réservation en quelques clics';
  static const becomeClientBenefit2 = 'Historique et favoris';
  static const becomeClientBenefit3 = 'Messages avec les prestataires';
  static const becomeClientCta = 'Activer l’espace client';

  static const becomeClientScreenTitle = 'Espace cliente';
  static const becomeClientScreenBody =
      'Tu restes prestataire : tu pourras basculer entre les deux espaces depuis ton profil.';
  static const becomeClientScreenSubmit = 'Activer l’espace client';
  static const becomeClientSuccess = 'Espace client activé. Tu peux réserver dès maintenant.';

  static const becomePrestaScreenStep = 'Étape 1 sur 3';
  static const becomePrestaHubStep = 'Étape 2 sur 3';
  static const becomePrestaScreenTitle = 'Lance ton activité';
  static const becomePrestaScreenBody =
      'Les mêmes informations que lors d’une inscription prestataire. '
      'Ensuite, un assistant en 7 étapes te guide (photo, spécialités, services, horaires…) '
      'pour apparaître dans le catalogue.';
  static const becomePrestaHubPreviewHint =
      'Étape suivante : profil professionnel guidé (photo, services, horaires, galerie…).';
  static const becomePrestaScreenSubmit = 'Continuer';
  static const becomePrestaContinueStep2 = 'Continuer vers l’étape 2';
  static const becomePrestaStep1SavedBanner =
      'Étape 1 enregistrée. Tu peux modifier tes infos ou passer à la suite.';
}
