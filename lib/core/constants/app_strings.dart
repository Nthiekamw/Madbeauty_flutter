class AppStrings {
  AppStrings._();

  static const String appName = 'MadBeauty';
  static const String tagline =
      'Coiffure afro — tresses, locks, cheveux crépus & bouclés';

  static const String loginTitle = 'Connexion';
  static String get loginDescription =>
      'Choisis comment te connecter : mot de passe, code e-mail, SMS ou Google.';
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

  static const String loginValidationPhoneEmpty = 'Saisis ton numéro avec l’indicatif (+…).';
  static const String loginValidationPhoneInvalid =
      'Numéro invalide. Utilise le format international (ex. +33612345678).';
  static const String loginValidationOtpEmpty = 'Saisis le code reçu.';
  static const String loginValidationOtpTooShort = 'Le code doit contenir au moins 6 caractères.';

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

  static const String signInOrSignUp = 'Connexion / inscription';
  static const String openPrestataireSpace = 'Espace prestataire';
  static const String accountActionSignOut = 'Se déconnecter';
  static const String accountSignOutConfirmTitle = 'Confirmer la déconnexion';
  static const String accountSignOutConfirmBody =
      'Veux-tu vraiment te déconnecter ?';
  static const String actionCancel = 'Annuler';
  static const String actionConfirm = 'Confirmer';
  static const String accountConnectedAsPrefix = 'Connecté en tant que :';
  static const String accountCachedEmailPrefix = 'Dernière session locale :';
  static const String profileLabelName = 'Nom :';
  static const String profileLabelEmail = 'Email :';
  static const String profileSourceCache = 'Source profil : cache local';
  static const String profileSourceLive = 'Source profil : Supabase';
  static const String networkStatusOnline = 'Statut réseau : en ligne';
  static const String networkStatusOffline = 'Statut réseau : hors connexion';
  static const String splashCheckingSession = 'Vérification de la session...';
  static const String splashWelcomeBack = 'Bienvenue sur MadBeauty';

  static const String supabaseMissingTitle = 'Supabase non configuré';
  static const String supabaseMissingBody =
      'Remplis SUPABASE_URL et SUPABASE_ANON_KEY dans le fichier .env à la '
      'racine, puis lance avec --dart-define-from-file=.env '
      '(ou la configuration « MadBeauty (avec .env) » dans VS Code).';

  static const String screenPrestataireHub = 'Espace prestataire';
  static const String screenSearch = 'Recherche';
  static const String screenBooking = 'Réservations';
  static const String screenMessaging = 'Messages';
  static const String screenStats = 'Statistiques';
  static const String screenProfile = 'Profil';
  static const String screenReviews = 'Avis';

  static const String errorUnexpected =
      'Une erreur inattendue s’est produite. Réessaie dans un instant.';
  static const String authEmailNotConfirmed =
      'Ton e-mail n’est pas encore confirmé. Vérifie ta boîte mail et clique sur le lien de confirmation.';

  static const String loginFieldEmail = 'E-mail';
  static const String loginFieldPassword = 'Mot de passe';
  static const String loginActionSubmit = 'Se connecter';
  static const String loginValidationEmailEmpty = 'Saisis ton adresse e-mail.';
  static const String loginValidationEmailInvalid =
      'Adresse e-mail invalide.';
  static const String loginValidationPasswordEmpty =
      'Saisis ton mot de passe.';
}
