/// Profil client.
abstract final class DiscProfile {
  DiscProfile._();

  static const sectionMyInfo = 'Mes informations';
  static const sectionPreferences = 'Mes préférences';
  static const sectionAccount = 'Mon compte';

  static const labelEmail = 'E-mail';
  static const labelPhone = 'Téléphone';
  static const labelCity = 'Ville';

  static const statAppointments = 'Rendez-vous';
  static const statFavorites = 'Favoris';
  static const statRating = 'Note moyenne';

  static const prefPush = 'Notifications push';
  static const prefPushHint = 'Alertes réservations et rappels';
  static const prefLocation = 'Géolocalisation';
  static const prefLocationHint = 'Pros près de toi et tri par distance';

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

  static const actionAdminUsers = 'Utilisateurs';
  static const actionAdminUsersHint =
      'Rechercher, bannir et gérer les rôles';
  static const adminUsersIntroTitle = 'Gestion des utilisateurs';
  static const adminUsersIntroBody =
      'Recherche par e-mail, nom ou identifiant. Bannissement et attribution des rôles.';
  static const adminUsersSearchHint = 'E-mail, nom ou ID…';
  static const adminUsersSearchAction = 'Chercher';
  static const adminUsersEmpty = 'Aucun utilisateur trouvé.';
  static const adminUsersBan = 'Bannir';
  static const adminUsersUnban = 'Débannir';
  static const adminUsersBannedBadge = 'Banni';
  static const adminActionOk = 'Action enregistrée.';
  static const adminActionErr = 'Action impossible pour le moment.';

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
  static const adminHomeStatReservations = 'Réservations';
  static const adminHomeStatRevenue = 'Revenus capturés';
  static const adminHomeAnalyticsTitle = 'Vue d’ensemble';

  static const prestataireVerificationRequestTitle = 'Badge vérifié';
  static const prestataireVerificationRequestBody =
      'Demande la vérification de ton profil pour inspirer confiance aux clientes.';
  static const prestataireVerificationRequestCta = 'Demander la vérification';
  static const prestataireVerificationPending =
      'Demande envoyée — l’équipe examine ton profil.';
  static const prestataireVerificationVerified = 'Profil vérifié';
  static const prestataireVerificationRequestOk = 'Demande envoyée.';
  static const prestataireVerificationRequestErr =
      'Impossible d’envoyer la demande pour le moment.';

  static const signOut = 'Se déconnecter';
  static const deleteAccount = 'Supprimer mon compte';

  static const deleteAccountTitle = 'Supprimer le compte ?';
  static const deleteAccountBody =
      'Cette action est définitive. Toutes tes données associées seront effacées.';
  static const deleteAccountConfirm = 'Supprimer';
  static const deleteAccountDone =
      'Demande de suppression enregistrée. Tu es déconnecté.';
  static const deleteAccountErr =
      'Impossible de supprimer le compte pour l’instant. Réessaie plus tard.';

  static const prefPushEnabled = 'Notifications activées.';
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

  static const becomePrestaScreenStep = 'Étape 1 sur 3';
  static const becomePrestaHubStep = 'Étape 2 sur 3';
  static const becomePrestaScreenTitle = 'Lance ton activité';
  static const becomePrestaScreenBody =
      'Ces informations apparaîtront sur ta fiche. Tu pourras compléter photo, spécialités et services juste après.';
  static const becomePrestaScreenSubmit = 'Continuer';
  static const becomePrestaContinueStep2 = 'Continuer vers l’étape 2';
  static const becomePrestaStep1SavedBanner =
      'Étape 1 enregistrée. Tu peux modifier tes infos ou passer à la suite.';
}
