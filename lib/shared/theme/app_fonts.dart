/// Familles déclarées dans [pubspec.yaml] (`fonts/`).
abstract final class AppFonts {
  AppFonts._();

  /// Texte courant, boutons, formulaires.
  static const String body = 'Poppins';

  /// Titres et en-têtes (même famille que le corps — évite le duo Exo/Poppins « template »).
  static const String display = 'Poppins';

  /// Accroches / logo wordmark (usage ponctuel).
  static const String brand = 'Bungee';
}

