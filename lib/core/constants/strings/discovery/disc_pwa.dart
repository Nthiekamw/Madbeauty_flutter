/// PWA — installation sur l’écran d’accueil (Flutter Web).
abstract final class DiscPwa {
  DiscPwa._();

  static const installBannerTitle = 'Installer MadBeauty';
  static const installBannerBody =
      'Accède plus vite à l’app et reçois les alertes même quand le navigateur est fermé.';
  static const installBannerAction = 'Installer';
  static const installBannerIosAction = 'Comment faire';
  static const installBannerDismiss = 'Plus tard';
  static const installIosDialogTitle = 'Ajouter à l’écran d’accueil';
  static const installIosDialogBody =
      'Sur iPhone : touche l’icône Partager en bas de Safari, '
      'puis « Sur l’écran d’accueil ».';
  static const installIosDialogAction = 'Compris';
  static const installSuccess = 'MadBeauty a été ajoutée à ton écran d’accueil.';
  static const profileSectionTitle = 'Application';
  static const profileInstallTitle = 'Installer sur l’écran d’accueil';
  static const profileInstallSubtitle =
      'Accès rapide, plein écran et notifications même navigateur fermé.';
  static const profileInstallAction = 'Installer';
  static const profileInstallIosAction = 'Voir comment faire';
}
