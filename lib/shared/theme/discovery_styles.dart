import 'package:flutter/material.dart';

/// Rayons et espacements des écrans découverte (accueil, recherche, catalogue).
abstract final class DiscoveryStyles {
  DiscoveryStyles._();

  static const double heroRadius = 24;
  static const double cardRadius = 20;
  static const double chipRadius = 14;
  static const double listCardWidth = 176;
  static const double listCardHeight = 232;
  static const double horizontalSectionHeight = 232;
  static const double listCardPhotoHeight = 100;
  static const double catalogCardPhotoHeight = 148;
  static const double catalogListCardRadius = 20;

  static BorderRadius get heroBorderRadius =>
      BorderRadius.circular(heroRadius);

  static BorderRadius get cardBorderRadius =>
      BorderRadius.circular(cardRadius);

  static BorderRadius get chipBorderRadius =>
      BorderRadius.circular(chipRadius);

  static BorderRadius get catalogListCardBorderRadius =>
      BorderRadius.circular(catalogListCardRadius);
}

/// Alias historique (accueil).
typedef HomeStyles = DiscoveryStyles;

