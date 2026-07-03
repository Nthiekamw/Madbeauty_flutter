/// Splash, session, profil affiché, réseau, configuration locale.
abstract final class ShellStrings {
  ShellStrings._();

  static const String splashInitializing = 'Démarrage de l’application…';
  static const String splashCheckingSession =
      'Vérification de la connexion…';
  static const String splashLoadingRoles = 'Chargement de ton compte…';
  static const String splashLoadingProfile = 'Préparation de ton espace…';
  static const String splashAlmostReady = 'Presque prêt…';
  static const String splashBiometricUnlock =
      'Déverrouille l’app pour continuer…';
  static const String splashBiometricRetry = 'Réessayer';
  static const String splashBiometricUsePassword = 'Se connecter autrement';

  static const String signInOrSignUp = 'Connexion / inscription';
  static const String openPrestataireSpace = 'Espace prestataire';
  static const String accountActionSignOut = 'Se déconnecter';
  static const String accountSignOutConfirmTitle = 'Confirmer la déconnexion';
  static const String accountSignOutConfirmBody =
      'Veux-tu vraiment te déconnecter ?';
  static const String accountConnectedAsPrefix = 'Connecté en tant que :';
  static const String accountCachedEmailPrefix = 'Dernière session locale :';

  static const String profileLabelName = 'Nom :';
  static const String profileLabelEmail = 'Email :';
  static const String profileNameFallback = 'Utilisateur';
  static const String profileRoleClient = 'Client';
  static const String profileRolePresta = 'Prestataire';
  static const String profileRoleDual = 'Client et prestataire';
  static const String profileRoleUnknown = 'Compte';
  static const String profileEditName = 'Modifier le nom';
  static const String profileEditPhoto = 'Modifier la photo';
  static const String profileEditNameTitle = 'Nom affiché';
  static const String profileFieldPrenom = 'Prénom';
  static const String profileFieldNom = 'Nom';
  static const String profileSave = 'Enregistrer';
  static const String profileSaveOk = 'Profil mis à jour.';
  static const String profileSaveErr =
      'Impossible d’enregistrer. Réessaie dans un instant.';
  static const String profileNameRequired =
      'Indique au moins un prénom ou un nom.';
  static const String profileVersionLabel = 'Version';
  static const String profileSourceCache = 'Source profil : cache local';
  static const String profileSourceLive = 'Source profil : Supabase';

  static const String networkStatusOnline = 'Statut réseau : en ligne';
  static const String networkStatusOffline = 'Statut réseau : hors connexion';
  static const String offlineModeBanner =
      'Mode hors ligne — données en cache. Connexion requise pour réserver ou modifier ton profil.';
  static const String offlineActionBlocked =
      'Cette action nécessite une connexion Internet.';
  static const String offlineActionQueued =
      'Action enregistrée. Elle sera envoyée dès que tu seras en ligne.';
  static String offlinePendingBanner(int count) =>
      count == 1
          ? '1 action en attente de synchronisation'
          : '$count actions en attente de synchronisation';
  static String offlineSyncDone(int count) =>
      count == 1
          ? '1 action synchronisée.'
          : '$count actions synchronisées.';
  static const String offlineSyncPartialFail =
      'Certaines actions n’ont pas pu être synchronisées. Réessaie plus tard.';
  static const String offlineDataFromCache = 'Données enregistrées localement';
  static const String offlineCatalogCacheOnly =
      'Catalogue hors ligne (dernière synchro). Reconnecte-toi pour actualiser.';

  static const String supabaseMissingTitle = 'Supabase non configuré';
  static const String supabaseMissingBody =
      'Remplis SUPABASE_URL et SUPABASE_ANON_KEY dans le fichier .env à la '
      'racine, puis lance avec --dart-define-from-file=.env '
      '(ou la configuration « MadBeauty (avec .env) » dans VS Code).';

  static const String navClientHome = 'Accueil';
  static const String navClientSearch = 'Catalogue';
  static const String navClientReservations = 'Réservations';
  static const String navClientMessages = 'Chat';
  static const String navClientProfile = 'Profil';

  static const String navAdminHome = 'Accueil';
  static const String navAdminModeration = 'Modération';
  static const String navAdminSupport = 'Support';
  static const String navAdminManagement = 'Gestion';
  static const String navAdminProfile = 'Compte';
  static const String navAdminVerifications = 'Vérifications';
  static const String navAdminReports = 'Signalements';

  static const String navPrestataireDashboard = 'Dashboard';
  static const String navPrestataireAgenda = 'Agenda';
  static const String navPrestataireProfile = 'Profil';
  static const String navPrestataireClients = 'Clients';
  static const String navPrestataireMessages = 'Chat';
}
