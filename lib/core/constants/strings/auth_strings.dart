/// Connexion, inscription, mot de passe, rôle.
abstract final class AuthStrings {
  AuthStrings._();

  static const String loginTitle = 'Connexion';
  static String get loginDescription =>
      'Connecte-toi avec ton e-mail et ton mot de passe, ou avec Google.';
  static const String loginActionOpenRegister = 'Créer un compte';

  static const String loginMethodPassword = 'Mot de passe';
  static const String loginMethodEmailOtp = 'Code e-mail';
  static const String loginMethodPhoneOtp = 'Code SMS';
  static const String loginFieldPhone = 'Téléphone (E.164, ex. +33612345678)';
  static const String loginFieldOtp = 'Code à 6 chiffres';
  static const String loginActionSendOtp = 'Envoyer le code';
  static const String loginActionVerifyOtp = 'Vérifier le code';
  static const String loginActionGoogle = 'Continuer avec Google';
  static const String loginActionForgotPassword = 'Mot de passe oublié ?';
  static const String loginOtpSentEmail =
      'Si cette adresse est valide, un code vient de t’être envoyé par e-mail.';
  static const String loginOtpSentSms =
      'Si ce numéro est valide, un SMS vient de t’être envoyé.';
  static const String loginGoogleStarted =
      'Complète la connexion dans la fenêtre qui s’ouvre, puis reviens dans l’app.';

  static const String loginFieldEmail = 'E-mail';
  static const String loginFieldPassword = 'Mot de passe';
  static const String loginActionSubmit = 'Se connecter';
  static const String loginValidationEmailEmpty = 'Saisis ton adresse e-mail.';
  static const String loginValidationEmailInvalid = 'Adresse e-mail invalide.';
  static const String loginValidationPasswordEmpty =
      'Saisis ton mot de passe.';
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

  static const String registerTitle = 'Inscription';
  static const String registerDescription =
      'Crée ton compte avec ton nom, ton e-mail et ton mot de passe.';
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

  static const String onboardingSkip = 'Passer';
  static const String onboardingCtaNext = 'Suivant';
  static const String onboardingCtaEnd = 'C’est parti';
  static const String onboardingPage1Title = 'MadBeauty près de toi';
  static const String onboardingPage1Body =
      'Découvre des professionnels de la beauté autour de toi et réserve en quelques gestes.';
  static const String onboardingPage2Title = 'Réservation simple';
  static const String onboardingPage2Body =
      'Choisis ton service, une date et un créneau : ta demande part directement au prestataire.';
  static const String onboardingPage3Title = 'Un compte, deux espaces';
  static const String onboardingPage3Body =
      'Passe du mode client au mode pro quand tu veux — tout reste dans la même app.';

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
      'Optionnel : aide les prestataires à mieux te localiser.';
  static const String registerStepExtrasPrestaSubtitle =
      'Présente ton activité aux futures clientes.';
  static const String registerStepLabelIdentity = 'Compte';
  static const String registerStepLabelRole = 'Profil';
  static const String registerStepLabelExtras = 'Détails';
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
  static const String registerFieldSalon = 'Nom du salon / activité';
  static const String registerFieldSalonAdresse = 'Adresse du salon';
  static const String registerFieldPostalCode = 'Code postal';
  static const String registerFieldDisplayName = 'Nom affiché';
  static const String registerFieldDescriptionPresta = 'Description courte';
  static const String registerFieldVille = 'Ville';
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

  static const String loginPasswordTabEmail = 'E-mail';
  static const String loginPasswordTabPhone = 'Téléphone';
  static const String loginPasswordPhoneSoon =
      'La connexion avec le téléphone et le mot de passe arrive bientôt. Utilise pour l’instant l’e-mail de ton compte.';
  static const String loginMethodOtpLater =
      'Connexion par code (e-mail / SMS) — à venir';

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
