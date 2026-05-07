import 'package:flutter/material.dart';

import '../../core/constants/app_area.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light(AppArea area) {
    final primary = area == AppArea.client
        ? AppColors.clientPrimaryLight
        : AppColors.prestatairePrimaryLight;
    final onPrimary = area == AppArea.client
        ? AppColors.clientOnPrimaryLight
        : AppColors.prestataireOnPrimaryLight;

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.light,
        seedColor: primary,
        primary: primary,
        onPrimary: onPrimary,
        secondary: AppColors.lightOnSurface,
        onSecondary: AppColors.lightSurface,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightOnSurface,
        error: const Color(0xFFB00020),
        onError: Colors.white,
        outline: AppColors.lightOutline,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.lightSurface,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
    );
  }

  static ThemeData dark(AppArea area) {
    final primary = area == AppArea.client
        ? AppColors.clientPrimaryDark
        : AppColors.prestatairePrimaryDark;
    final onPrimary = area == AppArea.client
        ? AppColors.clientOnPrimaryDark
        : AppColors.prestataireOnPrimaryDark;

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: primary,
        primary: primary,
        onPrimary: onPrimary,
        secondary: AppColors.darkOnSurface,
        onSecondary: AppColors.darkSurface,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkOnSurface,
        error: const Color(0xFFCF6679),
        onError: Colors.black,
        outline: AppColors.darkOutline,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.darkSurface,
      cardColor: AppColors.darkSurfaceContainer,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: primary,
        foregroundColor: onPrimary,
        elevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
    );
  }
}
