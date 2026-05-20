import 'package:flutter/material.dart';

import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/auth_form_styles.dart';
import '../../../shared/widgets/brand_background.dart';
import 'auth_marketing_logo.dart';

/// Scaffold auth : fond brand, en-tête, contenu scrollable, barre basse optionnelle.
class AuthFormScaffold extends StatelessWidget {
  const AuthFormScaffold({
    super.key,
    required this.title,
    required this.onBack,
    required this.child,
    this.subtitle,
    this.isBackEnabled = true,
    this.showLogo = true,
    this.scrollable = true,
    this.bottomBar,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onBack;
  final bool isBackEnabled;
  final bool showLogo;
  final bool scrollable;
  final Widget child;
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          BrandBackground(isDark: isDark),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: isBackEnabled ? onBack : null,
                        icon: const Icon(Icons.arrow_back_rounded),
                        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                if (showLogo) ...[
                  const Center(child: AuthMarketingLogo(width: 200)),
                  const SizedBox(height: 8),
                ],
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontFamily: AppFonts.display,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                          height: 1.15,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontFamily: AppFonts.body,
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: scrollable
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          child: child,
                        )
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                          child: child,
                        ),
                ),
                if (bottomBar != null)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(
                        alpha: isDark ? 0.94 : 0.98,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AuthFormStyles.cardRadius),
                      ),
                      border: Border(
                        top: BorderSide(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.15,
                          ),
                        ),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                        child: bottomBar!,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
