import 'package:flutter/material.dart';

import '../../core/constants/app_area.dart';
import 'app_colors.dart';
import 'app_fonts.dart';
import 'auth_form_styles.dart';

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
      onSecondary: AppColors.white,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightOnSurface,
      onSurfaceVariant: AppColors.lightOnSurfaceVariant,
      error: AppColors.errorLight,
      onError: AppColors.white,
      outline: AppColors.lightOutline,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme.copyWith(
        surfaceContainerLowest: AppColors.lightSurfaceContainer,
        surfaceContainerLow: AppColors.lightSurfaceContainer,
        surfaceContainer: AppColors.lightSurfaceContainer,
        surfaceContainerHigh: AppColors.lightSurfaceContainerHigh,
        surfaceContainerHighest: AppColors.lightSurfaceContainerHighest,
      ),
    );

    return _withFormChrome(
      _withTypography(
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
              minimumSize: const Size.fromHeight(52),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: AuthFormStyles.buttonBorderRadius,
              ),
              textStyle: const TextStyle(
                fontFamily: AppFonts.body,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
      brightness: Brightness.light,
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
      error: AppColors.errorDark,
      onError: AppColors.black,
      outline: AppColors.darkOutline,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme.copyWith(
        surfaceContainerLowest: AppColors.darkSurface,
        surfaceContainerLow: AppColors.darkSurfaceContainer,
        surfaceContainer: AppColors.darkSurfaceContainer,
        surfaceContainerHigh: AppColors.darkSurfaceContainerHigh,
        surfaceContainerHighest: AppColors.darkSurfaceContainerHighest,
      ),
    );

    return _withFormChrome(
      _withTypography(
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
              minimumSize: const Size.fromHeight(52),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: AuthFormStyles.buttonBorderRadius,
              ),
              textStyle: const TextStyle(
                fontFamily: AppFonts.body,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
      brightness: Brightness.dark,
    );
  }

  static ThemeData _withFormChrome(ThemeData theme, {required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;
    final scheme = theme.colorScheme;
    final fieldFill = isDark
        ? AppColors.darkSurfaceContainerHigh
        : AppColors.lightSurfaceContainerHigh;
    final onField = scheme.onSurfaceVariant;
    final border = scheme.outline;
    final focus = scheme.primary;

    return theme.copyWith(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldFill,
        labelStyle: TextStyle(color: onField),
        hintStyle: TextStyle(color: onField.withValues(alpha: 0.85)),
        prefixIconColor: focus,
        suffixIconColor: onField,
        border: AuthFormStyles.outlineBorder(
          border.withValues(alpha: isDark ? 0.45 : 0.5),
        ),
        enabledBorder: AuthFormStyles.outlineBorder(
          border.withValues(alpha: isDark ? 0.4 : 0.45),
        ),
        focusedBorder: AuthFormStyles.outlineBorder(focus, width: 1.5),
        errorBorder: AuthFormStyles.outlineBorder(
          isDark ? AppColors.errorDark : AppColors.errorLight,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: focus, width: 1.4),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: AuthFormStyles.buttonBorderRadius,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: focus),
      ),
      dividerTheme: DividerThemeData(
        color: border.withValues(alpha: 0.35),
      ),
      cardTheme: CardThemeData(
        color: isDark
            ? AppColors.darkSurfaceContainer
            : AppColors.lightSurfaceContainer,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AuthFormStyles.cardBorderRadius,
          side: BorderSide(color: border.withValues(alpha: 0.25)),
        ),
      ),
    );
  }
}

