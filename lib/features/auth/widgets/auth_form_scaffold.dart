import 'package:flutter/material.dart';

import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/auth_form_styles.dart';
import '../../../shared/widgets/layout/brand_background.dart';
import '../../../shared/widgets/layout/keyboard_dismiss_area.dart';
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
    this.headerAccessory,
    this.compact = false,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onBack;
  final bool isBackEnabled;
  final bool showLogo;
  final bool scrollable;
  final Widget child;
  final Widget? bottomBar;
  /// Contenu sous le sous-titre (ex. barre de progression inscription).
  final Widget? headerAccessory;
  /// En-tête resserré (wizard inscription) pour limiter le défilement.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final headerCompact = compact || keyboardOpen;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          BrandBackground(isDark: isDark),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(8, headerCompact ? 0 : 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: isBackEnabled ? onBack : null,
                        icon: const Icon(Icons.arrow_back_rounded),
                        tooltip:
                            MaterialLocalizations.of(context).backButtonTooltip,
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                if (showLogo && !headerCompact) ...[
                  const Center(child: AuthMarketingLogo(width: 200)),
                  const SizedBox(height: 8),
                ],
                _AuthFormHeader(
                  theme: theme,
                  title: title,
                  subtitle: subtitle,
                  headerAccessory: headerAccessory,
                  headerCompact: headerCompact,
                  hideSubtitle: keyboardOpen,
                ),
                SizedBox(
                  height: headerAccessory != null
                      ? (headerCompact ? 8 : 12)
                      : (headerCompact ? 8 : 16),
                ),
                Expanded(
                  child: KeyboardDismissArea(
                    child: scrollable
                        ? SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(
                              24,
                              0,
                              24,
                              headerCompact ? 12 : 24,
                            ),
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            child: child,
                          )
                        : Padding(
                            padding:
                                const EdgeInsets.fromLTRB(24, 0, 24, 16),
                            child: child,
                          ),
                  ),
                ),
                if (bottomBar != null)
                  _AuthFormBottomBar(
                    theme: theme,
                    isDark: isDark,
                    headerCompact: headerCompact,
                    child: bottomBar!,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthFormHeader extends StatelessWidget {
  const _AuthFormHeader({
    required this.theme,
    required this.title,
    required this.subtitle,
    required this.headerAccessory,
    required this.headerCompact,
    required this.hideSubtitle,
  });

  final ThemeData theme;
  final String title;
  final String? subtitle;
  final Widget? headerAccessory;
  final bool headerCompact;
  final bool hideSubtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, headerCompact ? 0 : 4, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: (headerCompact
                    ? theme.textTheme.titleLarge
                    : theme.textTheme.headlineSmall)
                ?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              height: 1.12,
            ),
          ),
          if (subtitle != null && !hideSubtitle) ...[
            SizedBox(height: headerCompact ? 4 : 8),
            Text(
              subtitle!,
              maxLines: headerCompact ? 2 : null,
              overflow: headerCompact ? TextOverflow.ellipsis : null,
              style: (headerCompact
                      ? theme.textTheme.bodySmall
                      : theme.textTheme.bodyMedium)
                  ?.copyWith(
                fontFamily: AppFonts.body,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
          if (headerAccessory != null) ...[
            SizedBox(height: headerCompact ? 8 : 16),
            headerAccessory!,
          ],
        ],
      ),
    );
  }
}

class _AuthFormBottomBar extends StatelessWidget {
  const _AuthFormBottomBar({
    required this.theme,
    required this.isDark,
    required this.headerCompact,
    required this.child,
  });

  final ThemeData theme;
  final bool isDark;
  final bool headerCompact;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(
          alpha: isDark ? 0.94 : 0.98,
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AuthFormStyles.cardRadius),
        ),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            headerCompact ? 12 : 16,
            24,
            headerCompact ? 12 : 16,
          ),
          child: child,
        ),
      ),
    );
  }
}
