class AppStrings {
  AppStrings._();

  static const String appName = 'MadBeauty';
  static const String tagline =
      'Coiffure afro — tresses, locks, cheveux crépus & bouclés';

  static const String loginTitle = 'Connexion';
  static String get loginDescription =>
      'Écran d’authentification ($appName) — '
      'email, Google OAuth et choix du rôle à brancher sur Supabase.';

  static const String signInOrSignUp = 'Connexion / inscription';
  static const String openPrestataireSpace = 'Espace prestataire';

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

  static const String loginFieldEmail = 'E-mail';
  static const String loginFieldPassword = 'Mot de passe';
  static const String loginActionSubmit = 'Se connecter';
  static const String loginValidationEmailEmpty = 'Saisis ton adresse e-mail.';
  static const String loginValidationEmailInvalid =
      'Adresse e-mail invalide.';
  static const String loginValidationPasswordEmpty =
      'Saisis ton mot de passe.';
}
