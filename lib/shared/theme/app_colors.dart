import 'package:flutter/material.dart';

/// Palette marron (chocolat / café) + fonds crème chauds – identité unifiée.
class AppColors {
  AppColors._();

  // --- Neutres ---

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  // --- Fonds clairs (blanc cassé chaud) ---

  /// Fond principal écrans client / prestataire.
  static const Color lightSurface = Color(0xFFF4E9DC);
  static const Color lightSurfaceContainer = Color(0xFFEDE0CE);
  static const Color lightSurfaceContainerHigh = Color(0xFFE5D6C4);
  static const Color lightSurfaceContainerHighest = Color(0xFFDAC9B4);
  static const Color lightOnSurface = Color(0xFF6B4E31);
  static const Color lightOnSurfaceVariant = Color(0xFF9A7B62);
  static const Color lightOutline = Color(0xFFC4A882);

  /// Puces de filtre inactives (accueil, listing).
  static const Color filterChipInactive = Color(0xFFEDE0CE);
  static const Color filterChipInactiveText = Color(0xFF6B4E31);

  // --- Fonds sombres ---

  static const Color darkSurface = Color(0xFF141210);
  static const Color darkSurfaceContainer = Color(0xFF2A221C);
  static const Color darkSurfaceContainerHigh = Color(0xFF352B24);
  static const Color darkSurfaceContainerHighest = Color(0xFF40352E);
  static const Color darkOnSurface = Color(0xFFEDE6DF);
  static const Color darkOnSurfaceVariant = Color(0xFFC4B8AE);
  static const Color darkOutline = Color(0xFF6E6258);
  static const Color darkPrimaryContainer = Color(0xFF4A382E);
  static const Color darkOnPrimaryContainer = Color(0xFFE8D4C8);

  // --- Marque ---

  /// Marron principal (tan chaud — identité visuelle).
  static const Color brandBrown = Color(0xFFC09267);
  /// Ton intermédiaire pour dégradés d’en-tête.
  static const Color brandBrownMid = Color(0xFFB08258);
  static const Color brownSecondaryLight = Color(0xFFD4B896);
  static const Color brandBrownDark = Color(0xFFC9A882);
  static const Color brownSecondaryDark = Color(0xFFB8A092);
  static const Color onPrimaryDarkText = Color(0xFF1A1410);

  /// Or / bronze du logo (silhouettes premium).
  static const Color brandGold = Color(0xFFC9A962);
  static const Color brandGoldLight = Color(0xFFE8D4A8);
  static const Color brandGoldDark = Color(0xFF8B7340);
  static const Color brandGoldGlow20 = Color(0x33C9A962);
  static const Color brandGoldGlow12 = Color(0x1FC9A962);

  /// Fond du pictogramme logo (noir profond).
  static const Color brandLogoBackground = Color(0xFF0D0D0D);
  static const Color brandSplashBackground = Color(0xFF0A0A0A);

  // --- Erreur (ThemeData) ---

  static const Color errorLight = Color(0xFFC62828);
  static const Color errorDark = Color(0xFFCF6679);

  // --- Workspace ---

  /// Panneau sous l'en-tête marron (catalogue, réservations…) — crème, pas blanc pur.
  static const Color workspacePanelLight = lightSurface;
  static const Color workspacePanelDark = darkSurfaceContainer;

  /// Cartes et champs sur fond crème (léger contraste chaud, pas blanc pur).
  static const Color cardSurfaceLight = Color(0xFFF7EFE4);
  static const Color clientAppointmentIconBg = Color(0xFFF2E3D5);
  static const Color clientAppointmentIconBgDark = Color(0xFF3D322A);

  /// Panneau principal sous l’en-tête (client / prestataire).
  static Color workspacePanelFor(Brightness brightness) =>
      brightness == Brightness.dark ? workspacePanelDark : workspacePanelLight;

  /// Fond de carte (listes, tuiles).
  static Color cardSurfaceFor(Brightness brightness) =>
      brightness == Brightness.dark
          ? darkSurfaceContainerHigh
          : cardSurfaceLight;

  static const Color notificationDot = Color(0xFFFF6B35);

  /// Accusé de lecture (double check bleu) dans les chats.
  static const Color chatReadReceipt = Color(0xFF53B3F6);

  static const List<Color> categoryPastels = [
    Color(0xFFFFE8DC),
    Color(0xFFFFE4EC),
    Color(0xFFEDE4FF),
    Color(0xFFE0F5EE),
    Color(0xFFFFF0D6),
    Color(0xFFE8F0FF),
  ];

  // --- Sémantiques ---

  static const Color success = Color(0xFF10B981);
  static const Color successBg08 = Color(0x1410B981);
  static const Color successBg12 = Color(0x1F10B981);
  static const Color successBorder20 = Color(0x3310B981);
  static const Color successBorder22 = Color(0x3810B981);
  static const Color successBorder35 = Color(0x5910B981);

  static const Color availableBadge = Color(0xFF22C55E);
  static const Color availableBadgeDark = Color(0xFF1B5E20);
  static const Color availableDot = Color(0xFF69F0AE);
  static const Color unavailableDot = Color(0xFFB0BEC5);

  static const Color starGold = Color(0xFFFBBF24);
  static const Color starAmber = Color(0xFFE6A817);
  static const Color starRating = Color(0xFFF59E0B);
  static const Color starReview = Color(0xFFFFB800);

  static const Color favorite = Color(0xFFE11D48);

  static const Color ambassador = Color(0xFF7C3AED);
  static const Color ambassadorMid = Color(0xFF6D28D9);
  static const Color ambassadorDark = Color(0xFF5B21B6);
  static const Color ambassadorBg10 = Color(0x1A7C3AED);
  static const Color ambassadorBorder25 = Color(0x407C3AED);

  /// Badge et back-office administrateur (or / bronze).
  static const Color adminAccent = brandGold;
  static const Color adminAccentMid = Color(0xFFB8944A);
  static const Color adminAccentDark = brandGoldDark;
  static const Color adminBg12 = brandGoldGlow12;
  static const Color adminBorder30 = Color(0x4DC9A962);
  static const Color purpleAccent = Color(0xFF8B5CF6);
  static const Color purpleAccentBg15 = Color(0x268B5CF6);
  static const Color purpleAccentBorder35 = Color(0x598B5CF6);

  static const Color infoSky = Color(0xFF0EA5E9);

  // --- Overlays / scrims ---

  static const Color scrimDark55 = Color(0x8C000000);
  static const Color scrimDark38 = Color(0x61000000);
  static const Color scrimDark35 = Color(0x59000000);
  static const Color scrimDark25 = Color(0x40000000);
  static const Color scrimDark22 = Color(0x38000000);
  static const Color scrimDark20 = Color(0x33000000);
  static const Color scrimDark18 = Color(0x2E000000);
  static const Color scrimDark54 = Color(0x8A000000);
  static const Color scrimDark26 = Color(0x42000000);
  static const Color scrimDark12 = Color(0x1F000000);
  static const Color scrimLight08 = Color(0x14000000);
  static const Color scrimLight05 = Color(0x0D000000);
  static const Color shadowSelected08 = Color(0x14000000);

  /// Texte et bordures sur bandeaux / cartes à dégradé marron.
  static const Color onPrimaryMuted30 = Color(0x4DFFFFFF);
  static const Color onPrimaryMuted70 = Color(0xB3FFFFFF);
  static const Color onPrimaryMuted75 = Color(0xBFFFFFFF);
  static const Color onPrimaryMuted80 = Color(0xCCFFFFFF);
  static const Color onPrimaryMuted85 = Color(0xD9FFFFFF);
  static const Color onPrimaryMuted88 = Color(0xE0FFFFFF);
  static const Color onPrimaryMuted92 = Color(0xEBFFFFFF);
  static const Color onPrimaryMuted95 = Color(0xF2FFFFFF);
  static const Color onPrimarySurface16 = Color(0x29FFFFFF);
  static const Color onPrimarySurface18 = Color(0x2EFFFFFF);
  static const Color onPrimarySurface20 = Color(0x33FFFFFF);
  static const Color onPrimarySurface22 = Color(0x38FFFFFF);
  static const Color onPrimarySurface28 = Color(0x47FFFFFF);
  static const Color onPrimarySurface30 = Color(0x4DFFFFFF);
  static const Color onPrimarySurface35 = Color(0x59FFFFFF);
  static const Color onPrimarySurface45 = Color(0x73FFFFFF);
  static const Color onPrimarySurface50 = Color(0x80FFFFFF);
  static const Color onPrimarySurface55 = Color(0x8CFFFFFF);
  static const Color onPrimarySurface60 = Color(0x99FFFFFF);

  // --- Alias thème : client & prestataire ---

  static const Color clientPrimaryLight = brandBrown;
  static const Color clientOnPrimaryLight = white;
  static const Color clientPrimaryDark = brandBrownDark;
  static const Color clientOnPrimaryDark = onPrimaryDarkText;

  static const Color prestatairePrimaryLight = brandBrown;
  static const Color prestataireOnPrimaryLight = white;
  static const Color prestatairePrimaryDark = brandBrownDark;
  static const Color prestataireOnPrimaryDark = onPrimaryDarkText;

  /// Assombrit légèrement le marron pour les dégradés d'en-tête workspace.
  static Color headerGradientEnd(Color primary) =>
      Color.lerp(primary, black, 0.12)!;

  /// Texte marque lisible sur fond surface (évite le marron foncé en dark).
  static Color brandTextFor(Brightness brightness) =>
      brightness == Brightness.dark ? brandBrownDark : brandBrown;

  /// Texte sur pastille claire (badge or, notification).
  static Color badgeTextFor(Brightness brightness) =>
      brightness == Brightness.dark ? onPrimaryDarkText : brandBrown;
}

