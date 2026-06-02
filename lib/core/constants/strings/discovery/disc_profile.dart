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
  static const actionAdminVerifications = 'Demandes de vérification';
  static const actionAdminVerificationsHint =
      'Valider ou retirer la vérification des prestataires';

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
