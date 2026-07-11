import 'package:flutter/material.dart';

/// Apparence : thème et langue (libellés bilingues pour ce panneau).
abstract final class DiscAppearance {
  DiscAppearance._();

  static bool isEnglish(Locale locale) => locale.languageCode == 'en';

  static String sectionTitle(Locale locale) =>
      isEnglish(locale) ? 'Appearance' : 'Apparence';

  static String tileTitle(Locale locale) =>
      isEnglish(locale) ? 'Theme, language & country' : 'Thème, langue et pays';

  static String tileSubtitle(
    Locale locale, {
    required String themeLabel,
    required String languageLabel,
    required String marketLabel,
  }) =>
      isEnglish(locale)
          ? '$themeLabel · $languageLabel · $marketLabel'
          : '$themeLabel · $languageLabel · $marketLabel';

  static String sheetTitle(Locale locale) =>
      isEnglish(locale) ? 'Customize the app' : 'Personnaliser l’app';

  static String themeSection(Locale locale) =>
      isEnglish(locale) ? 'Theme' : 'Thème';

  static String themeSystem(Locale locale) =>
      isEnglish(locale) ? 'Automatic' : 'Automatique';

  static String themeLight(Locale locale) =>
      isEnglish(locale) ? 'Light' : 'Clair';

  static String themeDark(Locale locale) =>
      isEnglish(locale) ? 'Dark' : 'Sombre';

  static String languageSection(Locale locale) =>
      isEnglish(locale) ? 'Language' : 'Langue';

  static String languageFrench(Locale locale) => 'Français';

  static String languageEnglish(Locale locale) => 'English';

  static String languageNote(Locale locale) => isEnglish(locale)
      ? 'Most of the app is still in French. Dates and system labels follow your choice.'
      : 'La majeure partie de l’app reste en français. Les dates et libellés système suivent ton choix.';

  static String themeSaved(Locale locale) =>
      isEnglish(locale) ? 'Theme updated.' : 'Thème mis à jour.';

  static String languageSaved(Locale locale) =>
      isEnglish(locale) ? 'Language updated.' : 'Langue mise à jour.';

  static String marketSection(Locale locale) =>
      isEnglish(locale) ? 'Country / region' : 'Pays / région';

  static String marketNote(Locale locale) => isEnglish(locale)
      ? 'Market order: auto-detect (device language or location), then your choice here, then your profile country.'
      : 'Ordre du marché : détection auto (langue de l’appareil ou position), puis ton choix ici, puis le pays de ton profil client.';

  static String marketSaved(Locale locale) =>
      isEnglish(locale) ? 'Country updated.' : 'Pays mis à jour.';
}
