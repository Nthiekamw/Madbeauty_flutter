/// Réglages du splash (natif + Flutter).
abstract final class SplashConfig {
  SplashConfig._();

  /// Durée minimale à l’écran avant navigation.
  static const Duration minDisplayDuration = Duration(seconds: 4);

  static const Duration introAnimationDuration = Duration(milliseconds: 900);

  /// Largeur du logo : fraction de l’écran (min / max en dp).
  static const double logoWidthFraction = 0.88;
  static const double logoMinWidth = 320;
  static const double logoMaxWidth = 420;

  /// Délai max pour rôles / profil au cold start (puis repli sur le cache).
  static const Duration bootstrapTimeout = Duration(seconds: 12);
}
