class AppStrings {
  AppStrings._();

  static const String appName = 'MadBeauty';
  static const String tagline =
      'Coiffure afro — tresses, locks, cheveux crépus & bouclés';

  static const String loginTitle = 'Connexion';
  static String get loginDescription =>
      'Connecte-toi avec ton e-mail et ton mot de passe.';
  static const String loginActionOpenRegister = 'Créer un compte';

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
