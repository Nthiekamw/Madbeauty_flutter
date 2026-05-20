import 'package:flutter/material.dart';

import '../../core/constants/app_area.dart';
import 'app_colors.dart';
import 'app_fonts.dart';

class AppTheme {
  AppTheme._();

  static ThemeData _withTypography(ThemeData base) {
    final text = base.textTheme.apply(fontFamily: AppFonts.body);
    TextStyle? exo(TextStyle? s) =>
        s?.copyWith(fontFamily: AppFonts.display);

    return base.copyWith(
      textTheme: text.copyWith(
        displayLarge: exo(text.displayLarge),
        displayMedium: exo(text.displayMedium),
        displaySmall: exo(text.displaySmall),
        headlineLarge: exo(text.headlineLarge),
        headlineMedium: exo(text.headlineMedium),
        headlineSmall: exo(text.headlineSmall),
        titleLarge: exo(text.titleLarge),
      ),
      primaryTextTheme: base.primaryTextTheme.apply(fontFamily: AppFonts.body),
      appBarTheme: base.appBarTheme.copyWith(
        titleTextStyle: exo(
          base.appBarTheme.titleTextStyle ??
              text.titleLarge?.copyWith(
                color: base.appBarTheme.foregroundColor,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }

  static ThemeData light(AppArea area) {
    final primary = area == AppArea.client
        ? AppColors.clientPrimaryLight
        : AppColors.prestatairePrimaryLight;
    final onPrimary = area == AppArea.client
        ? AppColors.clientOnPrimaryLight
        : AppColors.prestataireOnPrimaryLight;

    final scheme = ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: primary,
      primary: primary,
      onPrimary: onPrimary,
      secondary: AppColors.brownSecondaryLight,
      onSecondary: Colors.white,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightOnSurface,
      onSurfaceVariant: AppColors.lightOnSurfaceVariant,
      error: const Color(0xFFC62828),
      onError: Colors.white,
      outline: AppColors.lightOutline,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme.copyWith(
        surfaceContainerLowest: AppColors.lightSurfaceContainer,
        surfaceContainerLow: AppColors.lightSurfaceContainer,
        surfaceContainer: AppColors.lightSurfaceContainer,
        surfaceContainerHigh: const Color(0xFFF0E8E2),
        surfaceContainerHighest: const Color(0xFFE8DDD4),
      ),
    );

    return _withTypography(
      base.copyWith(
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

    final scheme = ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: primary,
      primary: primary,
      onPrimary: onPrimary,
      secondary: AppColors.brownSecondaryDark,
      onSecondary: AppColors.darkSurface,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkOnSurface,
      onSurfaceVariant: AppColors.darkOnSurfaceVariant,
      error: const Color(0xFFCF6679),
      onError: Colors.black,
      outline: AppColors.darkOutline,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme.copyWith(
        surfaceContainerLowest: AppColors.darkSurface,
        surfaceContainerLow: AppColors.darkSurfaceContainer,
        surfaceContainer: AppColors.darkSurfaceContainer,
        surfaceContainerHigh: const Color(0xFF352B24),
        surfaceContainerHighest: const Color(0xFF40352E),
      ),
    );

    return _withTypography(
      base.copyWith(
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
      ),
    );
  }
}
