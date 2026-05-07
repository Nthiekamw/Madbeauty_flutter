import 'package:flutter/material.dart';

/// Neutre blanc / noir + accents vert (client) et bleu (prestataire).
class AppColors {
  AppColors._();

  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF000000);
  static const Color lightOutline = Color(0xFF6B7280);

  static const Color darkSurface = Color(0xFF000000);
  static const Color darkSurfaceContainer = Color(0xFF121212);
  static const Color darkOnSurface = Color(0xFFFFFFFF);
  static const Color darkOutline = Color(0xFF9CA3AF);

  static const Color clientPrimaryLight = Color(0xFF15803D);
  static const Color clientOnPrimaryLight = Color(0xFFFFFFFF);
  static const Color clientPrimaryDark = Color(0xFF4ADE80);
  static const Color clientOnPrimaryDark = Color(0xFF000000);

  static const Color prestatairePrimaryLight = Color(0xFF1D4ED8);
  static const Color prestataireOnPrimaryLight = Color(0xFFFFFFFF);
  static const Color prestatairePrimaryDark = Color(0xFF60A5FA);
  static const Color prestataireOnPrimaryDark = Color(0xFF000000);
}
