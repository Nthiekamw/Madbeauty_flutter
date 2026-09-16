import 'package:flutter/foundation.dart';

/// Lisibilité web : texte et icônes plus grands qu'en app mobile native.
abstract final class WebReadability {
  WebReadability._();

  /// Facteur global appliqué via [TextScaler] sur Flutter Web.
  static double textScaleFactor(double width) {
    if (!kIsWeb) return 1;
    return switch (width) {
      >= 1200 => 1.04,
      >= 900 => 1.03,
      >= 600 => 1.02,
      _ => 1,
    };
  }

  /// Complément pour les icônes (non affectées par [TextScaler]).
  static double iconScaleFactor(double width) {
    if (!kIsWeb) return 1;
    return switch (width) {
      >= 900 => 1.04,
      >= 600 => 1.02,
      _ => 1,
    };
  }

  /// Taille minimale conseillée pour les micro-labels (badges, chips).
  static double minCaptionSize(double width) {
    if (!kIsWeb) return 9;
    return width >= 600 ? 12 : 11;
  }
}
