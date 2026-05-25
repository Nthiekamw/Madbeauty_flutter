import 'package:flutter/material.dart';

/// Palette inspirée de Madbeauty_flutter (or / crème / brun).
abstract final class PrototypePalette {
  PrototypePalette._();

  static const Color creamClient = Color(0xFFF2EBE0);
  static const Color creamAlt = Color(0xFFF5EFE6);
  static const Color creamPrestataire = Color(0xFFF5EFE8);

  static const Color gold = Color(0xFFC4956A);
  static const Color goldAlt = Color(0xFFD4A96A);
  static const Color goldLight = Color(0xFFEDE0CC);
  static const Color goldPale = Color(0xFFF0E6D3);
  static const Color goldDark = Color(0xFF8B6340);

  static const Color textDark = Color(0xFF2C1810);
  static const Color textMed = Color(0xFF6B4C35);
  static const Color textGrey = Color(0xFF9E8878);

  static const Color navDark = Color(0xFF1A0800);
  static const Color brownMid = Color(0xFF3D2314);
  static const Color brownDeep = Color(0xFF2C1810);

  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color searchFieldBg = Color(0xFFF8F4EF);
  static const Color dividerCream = Color(0xFFF5EDE0);
  static const Color signOutBg = Color(0xFFFFEEEE);

  static const Color availableGreen = Color(0xFF4CAF50);

  static List<BoxShadow> cardShadow({double opacity = 0.06}) => [
        BoxShadow(
          color: Colors.black.withValues(alpha: opacity),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> navTopShadow = const [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 12,
      offset: Offset(0, -3),
    ),
  ];
}
