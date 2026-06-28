import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/layout/discovery_responsive.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/theme/auth_form_styles.dart';
import '../../../../shared/widgets/brand/brand_logo.dart';

class OnboardingStatItem {
  const OnboardingStatItem({
    required this.value,
    required this.label,
    this.icon,
  });

  final String value;
  final String label;
  final IconData? icon;
}

class OnboardingSlide {
  const OnboardingSlide({
    required this.body,
    this.icon,
    this.title,
    this.showLogo = false,
    this.stats,
  });

  final IconData? icon;
  final String? title;
  final String body;
  final bool showLogo;

  /// Page « chiffres clés » (grille 2×2 ou 4 colonnes sur tablette).
  final List<OnboardingStatItem>? stats;

  bool get isStatsPage => stats != null && stats!.isNotEmpty;
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
    final layout = DiscoveryResponsive.of(context);
    final maxWidth = layout.useWebAuthFormLayout
        ? layout.authFormMaxWidthFor(layout.width)
        : layout.contentMaxWidth.clamp(280.0, 560.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final logoWidth = (constraints.maxWidth * 0.72).clamp(220.0, 300.0);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
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
                    ] else if (slide.isStatsPage)
                      _OnboardingStatsCard(
                        slide: slide,
                        theme: theme,
                        isDark: isDark,
                        primary: primary,
                      )
                    else
                      _OnboardingFeatureCard(
                        slide: slide,
                        theme: theme,
                        isDark: isDark,
                        primary: primary,
                      ),
                  ],
                ),
              ),
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

class _OnboardingStatsCard extends StatelessWidget {
  const _OnboardingStatsCard({
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
    final stats = slide.stats!;
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 600 ? 4 : 2;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 22),
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
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primary.withValues(alpha: isDark ? 0.35 : 0.18),
                  AppColors.brandGold.withValues(alpha: isDark ? 0.2 : 0.12),
                ],
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: AppColors.brandGold.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: Icon(
              slide.icon ?? Icons.insights_outlined,
              size: 42,
              color: isDark ? AppColors.brandGoldLight : primary,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            slide.title ?? '',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              height: 1.15,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            slide.body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: AppFonts.body,
              color: onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final gap = 10.0;
              final itemWidth =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                alignment: WrapAlignment.center,
                children: [
                  for (final stat in stats)
                    SizedBox(
                      width: itemWidth,
                      child: _StatTile(
                        stat: stat,
                        theme: theme,
                        isDark: isDark,
                        primary: primary,
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            AuthStrings.onboardingStatsDisclaimer,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              fontFamily: AppFonts.body,
              color: onSurfaceVariant.withValues(alpha: 0.85),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.stat,
    required this.theme,
    required this.isDark,
    required this.primary,
  });

  final OnboardingStatItem stat;
  final ThemeData theme;
  final bool isDark;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final accent = isDark ? AppColors.brandGoldLight : AppColors.brandGoldDark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: primary.withValues(alpha: isDark ? 0.12 : 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.brandGold.withValues(alpha: isDark ? 0.28 : 0.22),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (stat.icon != null) ...[
              Icon(stat.icon, size: 18, color: accent),
              const SizedBox(height: 6),
            ],
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                stat.value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: accent,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              stat.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                fontFamily: AppFonts.body,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
