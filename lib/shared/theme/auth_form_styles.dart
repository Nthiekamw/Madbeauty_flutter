import 'package:flutter/material.dart';

/// Rayons et formes communs aux formulaires auth.
abstract final class AuthFormStyles {
  AuthFormStyles._();

  static const double cardRadius = 24;
  static const double fieldRadius = 16;
  static const double buttonRadius = 16;
  static const double bannerRadius = 16;
  static const double chipRadius = 18;

  static BorderRadius get cardBorderRadius =>
      BorderRadius.circular(cardRadius);

  static BorderRadius get fieldBorderRadius =>
      BorderRadius.circular(fieldRadius);

  static BorderRadius get buttonBorderRadius =>
      BorderRadius.circular(buttonRadius);

  static OutlineInputBorder outlineBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: fieldBorderRadius,
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static ButtonStyle primaryButtonStyle(ThemeData theme) {
    return FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(52),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: buttonBorderRadius),
      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
    );
  }

  static ButtonStyle secondaryButtonStyle(ThemeData theme) {
    return OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(52),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: buttonBorderRadius),
      side: BorderSide(
        color: theme.colorScheme.primary,
        width: 1.4,
      ),
      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
    );
  }
}
