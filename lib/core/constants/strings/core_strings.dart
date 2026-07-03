/// Marque, actions transverses, erreurs génériques.
abstract final class CoreStrings {
  CoreStrings._();

  /// Nom sous l’icône (iOS/Android) et marque in-app — court pour éviter la troncature.
  static const String appName = 'MadBeauty';

  /// Nom App Store Connect (unique mondial).
  static const String appStoreListingName = 'MadBeauty';

  static const String tagline =
      'Trouve ton pro, prends rendez-vous ou développe ton activité beauté.';

  static const String actionCancel = 'Annuler';
  static const String actionConfirm = 'Confirmer';

  static const String errorUnexpected =
      'Une erreur inattendue s’est produite. Réessaie dans un instant.';

  static const String networkErrorTitle = 'Connexion indisponible';
  static const String networkErrorBody =
      'Vérifie ta connexion internet et réessaie.';
}
