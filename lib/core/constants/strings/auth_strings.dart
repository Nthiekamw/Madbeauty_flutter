/// Connexion, inscription, mot de passe, rôle.
abstract final class AuthStrings {
  AuthStrings._();

  static const String loginTitle = 'Connexion';
  static const String loginActionOpenRegister = 'Créer un compte';

  static const String loginActionGoogle = 'Continuer avec Google';
  static const String loginActionForgotPassword = 'Mot de passe oublié ?';
  static const String loginGoogleStarted =
      'Complète la connexion dans la fenêtre qui s’ouvre, puis reviens dans l’app.';
  static const String authGoogleSignInCanceled =
      'Connexion Google annulée.';
  static const String authGoogleSignInTimeout =
      'La connexion Google a pris trop de temps. Réessaie ou utilise le navigateur.';
  static const String authGoogleFirebaseNotConfigured =
      'Google natif indisponible sur cet appareil. Ouverture via le navigateur…';
  static const String authGoogleSupabaseLinkFailed =
      'Compte Google reconnu mais la session n’a pas pu s’ouvrir. '
      'Vérifie que le fournisseur Google est activé dans Supabase (Auth → Providers).';
  static const String loginActionApple = 'Continuer avec Apple';
  static const String registerActionApple = 'Continuer avec Apple';
  static const String authAppleSignInCanceled = 'Connexion Apple annulée.';
  static const String authAppleUnavailable =
      'Connexion Apple disponible uniquement sur iPhone et iPad.';
  static const String authAppleSupabaseLinkFailed =
      'Compte Apple reconnu mais la session n’a pas pu s’ouvrir. '
      'Vérifie que le fournisseur Apple est activé dans Supabase (Auth → Providers).';
  static const String authGoogleWebRedirectMissing =
      'Connexion Google web : configure SUPABASE_WEB_REDIRECT_URL dans .env '
      '(ex. http://localhost:7357) et ajoute cette URL dans Supabase → Auth → Redirect URLs.';

  static const String loginFieldEmail = 'E-mail';
  static const String loginFieldPassword = 'Mot de passe';
  static const String loginShowPassword = 'Afficher le mot de passe';
  static const String loginHidePassword = 'Masquer le mot de passe';
  static const String loginActionSubmit = 'Se connecter';
  static const String loginSectionQuick = 'Connexion rapide';
  static const String loginSectionQuickHint =
      'Utilise ton compte Google pour te connecter en un clic.';
  static const String loginSectionCredentials = 'Identifiants';
  static const String loginNoAccountPrompt = 'Pas encore de compte ? ';
  static const String loginValidationEmailEmpty = 'Saisis ton adresse e-mail.';
  static const String loginValidationEmailInvalid = 'Adresse e-mail invalide.';
  static const String loginValidationPasswordEmpty =
      'Saisis ton mot de passe.';
  static const String loginInvalidCredentials =
      'E-mail ou mot de passe incorrect.';
  static const String loginRetryCooldown =
      'Nouvelle tentative dans quelques secondes.';
  static const String loginValidationPhoneEmpty =
      'Saisis ton numéro avec l’indicatif (+…).';
  static const String loginValidationPhoneInvalid =
      'Numéro invalide. Utilise le format international (ex. +33612345678).';
  static const String loginValidationOtpEmpty = 'Saisis le code reçu.';
  static const String loginValidationOtpTooShort =
      'Le code doit contenir au moins 6 caractères.';

  static const String forgotPasswordTitle = 'Mot de passe oublié';
  static const String forgotPasswordDescription =
      'Saisis ton e-mail : nous t’enverrons un lien pour choisir un nouveau mot de passe.';
  static const String forgotPasswordSubmit = 'Envoyer le lien';
  static const String forgotPasswordSuccess =
      'Si un compte existe pour cet e-mail, un lien de réinitialisation a été envoyé.';
  static const String forgotPasswordSuccessHint =
      'Ouvre le lien sur le même téléphone où MadBeauty est installée. '
      'L’app s’ouvrira sur l’écran « Nouveau mot de passe ».';

  static const String resetPasswordRecoveryHeadline = 'Choisis un nouveau mot de passe';
  static const String resetPasswordRecoveryHint =
      'Tu viens du lien reçu par e-mail. Une fois enregistré, tu pourras te connecter normalement.';
  static const String resetPasswordLinkInvalidTitle = 'Lien invalide ou expiré';
  static const String resetPasswordLinkInvalidBody =
      'Ce lien ne fonctionne plus. Demande un nouveau lien depuis la connexion.';
  static const String resetPasswordRequestNewLink = 'Demander un nouveau lien';
  static const String resetPasswordSuccess =
      'Mot de passe mis à jour. Tu peux continuer.';

  static const String resetPasswordTitle = 'Nouveau mot de passe';
  static const String resetPasswordDescription =
      'Choisis un nouveau mot de passe pour ton compte.';
  static const String resetPasswordFieldConfirm = 'Confirmer le mot de passe';
  static const String resetPasswordActionSubmit = 'Enregistrer';
  static const String resetPasswordValidationMismatch =
      'Les deux mots de passe ne correspondent pas.';
  static const String resetPasswordValidationTooShort =
      'Le mot de passe doit contenir au moins 8 caractères.';
  static const String passwordValidationTooShort =
      'Le mot de passe doit contenir au moins 8 caractères.';
  static const String passwordValidationRequiresLetterAndDigit =
      'Le mot de passe doit contenir au moins une lettre et un chiffre.';

  static const String registerTitle = 'Inscription';
  static const String registerDescription =
      'Crée ton compte avec ton nom et ton e-mail.';
  static const String registerFieldName = 'Nom';
  static const String registerActionSubmit = 'Créer mon compte';
  static const String registerActionBackToLogin = 'J’ai déjà un compte';
  static const String registerValidationNameEmpty = 'Saisis ton nom.';
  static const String registerValidationEmailEmpty =
      'Saisis ton adresse e-mail.';
  static const String registerValidationEmailInvalid = 'Adresse e-mail invalide.';
  static const String registerValidationPasswordEmpty =
      'Saisis ton mot de passe.';

  static const String roleChoiceTitle = 'Choisis ton espace';
  static const String roleChoiceSubtitle =
      'Comment veux-tu utiliser MadBeauty aujourd’hui ?';
  static const String roleChoiceDescription =
      'Tu pourras ajouter l’autre espace plus tard depuis ton profil.';
  static const String roleChoiceClient = 'Je suis client';
  static const String roleChoiceClientHint =
      'Réserver des prestations beauté près de chez moi.';
  static const String roleChoicePrestataire = 'Je suis prestataire';
  static const String roleChoicePrestataireHint =
      'Gérer mon salon, mes services et mes réservations.';
  static const String roleChoiceSyncForbidden =
      'Synchronisation du rôle refusée par le serveur. Mets à jour l’app ou réessaie dans un instant.';

  static const String authEmailNotConfirmed =
      'Ton e-mail n’est pas encore confirmé. Vérifie ta boîte mail et clique sur le lien de confirmation.';
  static const String authEmailAddressInvalid =
      'Cette adresse e-mail n’est pas acceptée. Utilise une adresse réelle '
      '(Gmail, Outlook, etc.) — certains domaines de test sont refusés par Supabase.';
  static const String authEmailAddressNotAuthorized =
      'Impossible d’envoyer l’e-mail de confirmation à cette adresse avec la '
      'configuration actuelle. Utilise une autre adresse ou configure un SMTP '
      'personnalisé dans Supabase.';
  static const String authEmailRateLimitExceeded =
      'Trop de tentatives d’inscription ou d’e-mails envoyés. Attends quelques '
      'minutes avant de réessayer, ou consulte ta boîte mail si tu as déjà reçu '
      'le lien de confirmation.';

  static const String onboardingSkip = 'Passer';
  static const String onboardingBack = 'Retour';
  static const String onboardingCtaNext = 'Suivant';
  static const String onboardingCtaEnd = 'C’est parti';
  static String onboardingStep(int current, int total) =>
      'Étape $current sur $total';
  static const String onboardingPage1Title = 'Bienvenue sur MadBeauty';
  static const String onboardingPage1Body =
      'En quelques étapes, découvre comment réserver tes soins ou gérer ton activité, en client comme en professionnel.';
  static const String onboardingPage2Title = 'Côté client';
  static const String onboardingPage2Body =
      'Trouve un pro près de toi, choisis ton service et réserve un créneau en quelques gestes.';
  static const String onboardingPage3Title = 'Côté prestataire';
  static const String onboardingPage3Body =
      'Agenda, demandes et profil : pilote ton activité beauté depuis le même compte.';
  static const String onboardingPage4Title = 'MadBeauty en chiffres';
  static const String onboardingPage4Body =
      'Une communauté beauté qui grandit chaque jour.';
  static const String onboardingStatClientsValue = '10K+';
  static const String onboardingStatClientsLabel = 'Clientes';
  static const String onboardingStatPrestatairesValue = '500+';
  static const String onboardingStatPrestatairesLabel = 'Prestataires';
  static const String onboardingStatReservationsValue = '50K+';
  static const String onboardingStatReservationsLabel = 'Réservations';
  static const String onboardingStatRatingValue = '4.8★';
  static const String onboardingStatRatingLabel = 'Note moyenne';
  static const String onboardingStatsDisclaimer =
      'Chiffres indicatifs de la plateforme.';

  static const String welcomeTitle = 'Bienvenue';
  static const String welcomeSubtitle =
      'Connecte-toi, crée un compte, ou explore sans inscription.';
  static const String welcomeRegister = 'Inscription';
  static const String welcomeLogin = 'Connexion';
  static const String welcomeContinueGuest = 'Continuer sans compte';
  static const String welcomeGuestHint =
      'Parcours les prestataires et les services. La réservation nécessite un compte.';

  static const String guestHomeGreeting = 'Bienvenue sur MadBeauty';
  static const String guestHomeSubtitle =
      'Découvre les prestataires près de chez toi.';
  static const String guestHomeSignIn = 'Se connecter';
  static const String guestProfileTitle = 'Ton espace compte';
  static const String guestProfileBody =
      'Crée un compte ou connecte-toi pour gérer ton profil, tes réservations et devenir prestataire.';
  static const String guestReservationsTitle = 'Tes réservations';
  static const String guestReservationsBody =
      'Connecte-toi pour réserver un créneau et suivre tes rendez-vous.';
  static const String guestBookingTitle = 'Réservation';
  static const String guestBookingBody =
      'Un compte est nécessaire pour confirmer une réservation.';
  static const String registerPendingBookingRoleHint =
      'Profil client présélectionné pour finaliser ta réservation.';
  static const String guestCtaLogin = 'Connexion';
  static const String guestCtaRegister = 'Créer un compte';
  static const String welcomeFeatureDualRole = 'Client ou prestataire';
  static const String welcomeFeatureSecure = 'Compte sécurisé';

  static const String registerStepIdentityTitle = 'Tes informations';
  static const String registerStepIdentitySubtitle =
      'Quelques infos pour créer ton compte MadBeauty.';
  static const String registerStepRoleTitle = 'Ton profil';
  static const String registerStepRoleSubtitle =
      'Comment veux-tu utiliser l’application ?';
  static const String registerStepExtrasTitle = 'Détails';
  static const String registerStepExtrasClientSubtitle =
      'Photo de profil et adresse (optionnel) pour personnaliser ton compte.';
  static const String registerStepExtrasPrestaSubtitle =
      'Présente ton activité aux futures clientes.';
  static const String registerStepLabelIdentity = 'Compte';
  static const String registerStepLabelRole = 'Profil';
  static const String registerStepLabelExtras = 'Détails';

  static String registerStepCounter(int current, int total) =>
      'Étape $current sur $total';

  static const String registerSectionQuick = 'Inscription rapide';
  static const String registerSectionQuickHint =
      'Quelques secondes avec ton compte Google.';
  static const String registerSectionIdentity = 'Identité';
  static const String registerSectionContact = 'Contact';
  static const String registerSectionSecurity = 'Sécurité';
  static const String registerSectionAvatar = 'Photo de profil';
  static const String registerSectionAvatarHint =
      'Choisis une photo ou un avatar par défaut.';
  static const String registerAvatarPick = 'Choisir une photo';
  static const String registerDefaultAvatars = 'Avatars par défaut';
  static const String registerSectionActivity = 'Ton activité';
  static const String registerSectionActivityHint =
      'Visible sur ta fiche prestataire.';
  static const String registerSectionLocation = 'Localisation';
  static const String registerSectionPresentation = 'Présentation';
  static const String registerSectionOptional = 'Facultatif';
  static const String registerSectionOptionalExpand =
      'Compléter plus tard (optionnel)';
  static const String registerValidationRoleEmpty =
      'Choisis comment tu veux utiliser MadBeauty.';
  static const String registerValidationPrestaRequired =
      'Indique au minimum le nom de ton salon et ta ville.';
  static const String registerValidationSalonEmpty =
      'Indique le nom de ton salon ou de ton activité.';
  static const String registerValidationVilleEmpty = 'Indique ta ville.';
  static const String registerValidationPhoneInvalid =
      'Numéro de téléphone invalide.';
  static const String registerWizardBack = 'Retour';
  static const String registerFieldPhoneHint = 'Ex. 6 12 34 56 78';
  static const String registerFieldPasswordHint =
      '8 caractères min., une lettre et un chiffre';
  static const String registerFieldPrenom = 'Prénom';
  static const String registerFieldNom = 'Nom';
  static const String registerFieldPhone = 'Téléphone';
  static const String registerFieldConfirmPassword =
      'Confirmer le mot de passe';
  static const String registerValidationPrenomEmpty = 'Saisis ton prénom.';
  static const String registerValidationNomEmpty = 'Saisis ton nom.';
  static const String registerValidationPhoneEmpty = 'Saisis ton téléphone.';
  static const String registerValidationPasswordMismatch =
      'Les mots de passe ne correspondent pas.';
  static const String registerChooseClient = 'Je suis client';
  static const String registerChooseClientHint =
      'Réserver des prestations beauté près de chez moi.';
  static const String registerChoosePresta = 'Je suis prestataire';
  static const String registerChoosePrestaHint =
      'Gérer mon salon, mes services et mes réservations.';
  static const String registerFieldAdresse = 'Adresse (optionnel)';
  static const String registerFieldSalon = 'Nom du salon / activité *';
  static const String registerFieldSalonAdresse = 'Adresse du salon';
  static const String registerFieldPostalCode = 'Code postal';
  static const String registerFieldDisplayName = 'Nom affiché';
  static const String registerFieldDescriptionPresta = 'Description courte';
  static const String registerFieldVille = 'Ville *';
  static const String registerFieldVilleOptional = 'Ville';
  static const String registerFieldVoieType = 'Type de voie';
  static const String registerFieldVoieName = 'Nom de la voie';
  static const String registerFieldStreetNumber = 'N°';
  static const String registerFieldCountry = 'Pays';
  static const String registerAddressSearchLabel = 'Recherche rapide d’adresse';
  static const String registerAddressSearchHint =
      'Ex. 30 rue Descartes, Paris';
  static const String registerAddressSearchHintBe =
      'Ex. 150 rue de Montigny, 6000 Charleroi';
  static const String registerAddressSearchHintCa =
      'Ex. 100 Queen Street West, Toronto';
  static const String registerAddressSearchHelp =
      'Choisis une suggestion officielle pour préremplir une adresse existante.';
  static const String registerAddressSearchHelpFr =
      'Suggestions officielles via la Base Adresse Nationale (France).';
  static const String registerAddressSearchHelpBe =
      'Suggestions officielles via le registre BeSt (Belgique).';
  static const String registerAddressSearchHelpCa =
      'Suggestions via Géolocalisation Canada et OpenStreetMap.';
  static const String registerAddressSearchHelpIntl =
      'Suggestions OpenStreetMap pour compléter l’adresse.';
  static const String registerAddressSearchFranceOnly =
      'Autocomplétion BAN disponible pour les adresses en France.';

  static String registerAddressSearchHintFor(String countryIso) {
    return switch (countryIso.toUpperCase()) {
      'BE' => registerAddressSearchHintBe,
      'CA' => registerAddressSearchHintCa,
      _ => registerAddressSearchHint,
    };
  }

  static String registerAddressSearchHelpFor(String countryIso) {
    return switch (countryIso.toUpperCase()) {
      'FR' => registerAddressSearchHelpFr,
      'BE' => registerAddressSearchHelpBe,
      'CA' => registerAddressSearchHelpCa,
      'CH' || 'DE' || 'GB' => registerAddressSearchHelpIntl,
      _ => registerAddressSearchHelp,
    };
  }

  static bool supportsAddressAutocomplete(String countryIso) {
    return switch (countryIso.toUpperCase()) {
      'FR' || 'BE' || 'CA' => true,
      _ => false,
    };
  }
  static const String registerAddressSearchNoResult =
      'Aucune adresse trouvée. Vérifie la saisie ou complète les champs manuellement.';
  static const String registerAddressSearchError =
      'Impossible de rechercher une adresse pour le moment.';
  static const String registerValidationAddressNotFound =
      'Adresse introuvable. Choisis une adresse existante dans la liste ou corrige la saisie.';
  static const String registerFieldBioPresta = 'Présentation (optionnel)';
  static const String registerWizardSubmit = 'Créer mon compte';
  static const String registerWizardNext = 'Continuer';
  static const String registerDraftRestored =
      'Ton inscription a été reprise là où tu l’avais laissée.';
  static const String registerDraftRestart = 'Recommencer';
  static const String registerOrDivider = 'ou';
  static const String registerActionGoogle = 'Continuer avec Google';
  static const String registerGooglePhoneHint =
      'Google ne fournit pas ton numéro : renseigne-le pour finaliser ton compte.';
  static const String registerAppleConnected = 'Connecté avec Apple';
  static const String registerGoogleConnected =
      'Compte Google connecté. Vérifie tes informations puis appuie sur Continuer.';
  static const String registerGoogleConnectedBanner =
      'Connecté avec Google';
  static const String registerAppleConnectedBanner =
      'Connecté avec Apple';
  static const String registerOAuthPhoneHint =
      'Ton fournisseur de connexion ne partage pas ton numéro : renseigne-le pour finaliser ton compte.';
  static const String registerOAuthIdentityPrefilledHint =
      'Ton prénom, ton nom et ton e-mail ont été enregistrés automatiquement via ta connexion.';
  static const String registerAppleIdentitySatisfiedHint =
      'Prénom, nom et e-mail fournis par Apple — tu n’as pas à les ressaisir.';
  static const String registerSuccessTitle = 'Inscription réussie';
  static const String registerSuccessBody =
      'Ton compte MadBeauty est prêt. Tu peux commencer à utiliser l’application.';
  static const String registerSuccessCta = 'C’est parti';
  static const String registerEmailVerifyTitle = 'Vérifie ton e-mail';
  static String registerEmailVerifySubtitle(String email) =>
      email.trim().isEmpty ? 'Confirme ton adresse e-mail' : email.trim();
  static const String registerEmailVerifyBody =
      'On vient de t’envoyer un lien de confirmation. Ouvre-le depuis ta boîte mail '
      '(sur ce téléphone ou un autre), puis appuie sur le bouton ci-dessous pour '
      'entrer dans l’application.';
  static const String registerEmailVerifyConfirmedCta = 'J’ai vérifié mon e-mail';
  static const String registerEmailVerifyChecking = 'Connexion…';
  static const String registerEmailVerifyResendLabel = 'Je ne vois pas le mail';
  static const String registerEmailVerifyResendHint =
      'Vérifie les spams / promotions, puis réessaie dans quelques secondes.';
  static const String registerEmailVerifyResendSuccess =
      'Email de confirmation renvoyé. Vérifie ta boîte mail.';
  static const String registerEmailVerifyResendError =
      'Impossible de renvoyer l’email pour le moment.';
  static const String registerEmailVerifyStillPending =
      'Ton e-mail n’est pas encore confirmé. Clique sur le lien reçu (sur n’importe '
      'quel appareil), attends quelques secondes, puis réessaie.';
  static const String authEmailLinkExpired =
      'Ce lien a expiré ou a déjà été utilisé. Si ton e-mail est confirmé, appuie sur '
      '« J’ai vérifié mon e-mail ». Sinon, demande un nouveau mail.';

  static const String loginSuccessTitle = 'Bon retour !';
  static const String loginSuccessBody =
      'Tu es connecté(e). Retrouve tes prestataires et tes réservations sur MadBeauty.';
  static const String loginSuccessCta = 'Continuer';

  static const String accountBannedTitle = 'Compte suspendu';
  static const String accountBannedBody =
      'Ton accès à MadBeauty a été suspendu par notre équipe. '
      'Tu peux contacter le support depuis l’application si tu penses qu’il s’agit d’une erreur.';
  static String accountBannedReason(String reason) => 'Motif : $reason';
  static const String accountBannedContactSupport = 'Contacter le support';
  static const String accountBannedCta = 'Compris';

  static const String bannedSupportTitle = 'Contacter le support';
  static const String bannedSupportSubtitle =
      'Explique ta situation. Tu pourras échanger avec l’équipe dans une discussion, '
      'comme pour un signalement de bug.';
  static const String bannedSupportDescriptionLabel = 'Ton message';
  static const String bannedSupportDescriptionHint =
      'Pourquoi demandes-tu la réouverture de ton compte ?';
  static const String bannedSupportSubmit = 'Envoyer ma demande';
  static const String bannedSupportDefaultTitle = 'Contestation suspension de compte';
  static const String bannedSupportSuccess =
      'Demande envoyée. Ouvre la discussion pour suivre les échanges.';
  static const String bannedSupportSessionExpired =
      'Ta session a expiré. Reconnecte-toi pour envoyer ta demande au support.';

  static const String profileBecomePresta = 'Devenir prestataire';
  static const String profileSwitchToPresta = 'Espace prestataire';
  static const String profileSwitchToClient = 'Espace client';
  static const String profileDualRoleHint =
      'Tu as un profil client et un profil prestataire : choisis l’espace à afficher.';

  static const String becomePrestaStep1Title =
      'Étape 1 — Ton activité';
  static const String becomePrestaStep1Body =
      'Indique le nom de ton salon ou activité et ta ville. '
      'Tu compléteras ensuite photo, spécialités et services.';
  static const String becomePrestaStep1Submit =
      'Continuer vers le profil complet';
}
