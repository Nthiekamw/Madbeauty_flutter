import 'package:flutter/material.dart';

/// Palette marron (chocolat / café) + fonds crème chauds — identité unifiée.
class AppColors {
  AppColors._();

  /// Fond principal (crème très clair, légèrement chaud).
  static const Color lightSurface = Color(0xFFF8F4F0);

  /// Cartes / conteneurs un peu plus marqués.
  static const Color lightSurfaceContainer = Color(0xFFFAF7F3);

  /// Texte et icônes principales (marron très foncé).
  static const Color lightOnSurface = Color(0xFF2D211C);

  /// Sous-texte, légendes.
  static const Color lightOnSurfaceVariant = Color(0xFF5D4E47);

  /// Bordures / séparateurs discrets.
  static const Color lightOutline = Color(0xFF8B7355);

  /// Marron principal (barres d’app, boutons pleins, nav active).
  static const Color brandBrown = Color(0xFF4A3328);

  /// Accent secondaire doux (badges, puces).
  static const Color brownSecondaryLight = Color(0xFF8D6E63);

  /// Fond sombre « espresso » (noir chaud, pas gris bleuté).
  static const Color darkSurface = Color(0xFF141210);

  /// Cartes / zones surélevées (marron profond).
  static const Color darkSurfaceContainer = Color(0xFF2A221C);

  /// Texte principal (crème, même famille que le fond clair inversé).
  static const Color darkOnSurface = Color(0xFFEDE6DF);

  /// Sous-textes / icônes atténuées.
  static const Color darkOnSurfaceVariant = Color(0xFFADA39C);

  /// Séparateurs ; reste dans les tons terre.
  static const Color darkOutline = Color(0xFF5E534C);

  /// Primaire dark : **sable / latte** — équivalent lumineux du marron clair,
  /// lisible sur fond foncé (évite le gris-mauve type `BCAAA4`).
  static const Color brandBrownDark = Color(0xFFD4C4B8);

  /// Secondaire : taupe chaud pour puces, liens, éléments moins importants.
  static const Color brownSecondaryDark = Color(0xFF9A8B82);

  // --- Alias thème : client & prestataire partagent la même identité marron ---

  static const Color clientPrimaryLight = brandBrown;
  static const Color clientOnPrimaryLight = Color(0xFFFFFFFF);
  static const Color clientPrimaryDark = brandBrownDark;
  /// Texte / icônes sur boutons clairs en dark (noir café).
  static const Color clientOnPrimaryDark = Color(0xFF1A1410);

  static const Color prestatairePrimaryLight = brandBrown;
  static const Color prestataireOnPrimaryLight = Color(0xFFFFFFFF);
  static const Color prestatairePrimaryDark = brandBrownDark;
  static const Color prestataireOnPrimaryDark = Color(0xFF1A1410);
}
