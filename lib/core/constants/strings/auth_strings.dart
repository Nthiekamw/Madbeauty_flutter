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
  static const String roleChoiceDescription =
      'Sélectionne le rôle avec lequel tu veux continuer.';
  static const String roleChoiceClient = 'Je suis client';
  static const String roleChoicePrestataire = 'Je suis prestataire';
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
      'Connecte-toi ou crée un compte pour continuer.';
  static const String welcomeRegister = 'Inscription';
  static const String welcomeLogin = 'Connexion';

  static const String registerStepIdentityTitle = 'Tes informations';
  static const String registerStepRoleTitle = 'Ton profil';
  static const String registerStepExtrasTitle = 'Détails';
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
  static const String registerChoosePresta = 'Je suis prestataire';
  static const String registerFieldAdresse = 'Adresse (optionnel)';
  static const String registerFieldSalon = 'Nom du salon / activité';
  static const String registerFieldVille = 'Ville';
  static const String registerFieldBioPresta = 'Bio (optionnel)';
  static const String registerWizardSubmit = 'Créer mon compte';
  static const String registerWizardNext = 'Continuer';
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
