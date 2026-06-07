import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/auth_form_styles.dart';
import '../../../shared/widgets/brand/brand_logo.dart';

class OnboardingSlide {
  const OnboardingSlide({
    required this.body,
    this.icon,
    this.title,
    this.showLogo = false,
  });

  final IconData? icon;
  final String? title;
  final String body;
  final bool showLogo;
}

class OnboardingPageContent extends StatelessWidget {
  const OnboardingPageContent({super.key, required this.slide});

  final OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;

    return LayoutBuilder(
      builder: (context, constraints) {
        final logoWidth = (constraints.maxWidth * 0.72).clamp(220.0, 300.0);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (slide.showLogo) ...[
                  BrandLogo(
                    width: logoWidth,
                    showGlow: true,
                    glowColor: isDark
                        ? AppColors.brandGoldGlow20
                        : AppColors.brandGold.withValues(alpha: 0.3),
                    glowBlurRadius: isDark ? 48 : 36,
                    glowSpreadRadius: isDark ? 10 : 8,
                  ),
                  const SizedBox(height: 28),
                  Text(
                    slide.title ?? CoreStrings.appName,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                      height: 1.1,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    slide.body,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontFamily: AppFonts.body,
                      color: onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ] else
                  _OnboardingFeatureCard(
                    slide: slide,
                    theme: theme,
                    isDark: isDark,
                    primary: primary,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OnboardingFeatureCard extends StatelessWidget {
  const _OnboardingFeatureCard({
    required this.slide,
    required this.theme,
    required this.isDark,
    required this.primary,
  });

  final OnboardingSlide slide;
  final ThemeData theme;
  final bool isDark;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;
    final surface = theme.colorScheme.surfaceContainerHighest;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
      decoration: BoxDecoration(
        color: surface.withValues(alpha: isDark ? 0.55 : 0.92),
        borderRadius: AuthFormStyles.cardBorderRadius,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.22 : 0.18),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: AppColors.scrimLight08,
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primary.withValues(alpha: isDark ? 0.35 : 0.18),
                  AppColors.brandGold.withValues(alpha: isDark ? 0.2 : 0.12),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: AppColors.brandGold.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: Icon(
              slide.icon,
              size: 44,
              color: isDark ? AppColors.brandGoldLight : primary,
            ),
          ),
          const SizedBox(height: 28),
          Text(
            slide.title ?? '',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              height: 1.15,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            slide.body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontFamily: AppFonts.body,
              color: onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
