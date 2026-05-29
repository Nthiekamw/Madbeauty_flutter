import 'package:flutter/material.dart';

import '../../theme/app_fonts.dart';

/// Type visuel du message flottant.
enum AppSnackKind {
  success,
  error,
  info,
  warning,
}

/// Snackbars Material 3 flottants, arrondis et alignés sur la charte MadBeauty.
abstract final class AppSnackBar {
  AppSnackBar._();

  static const double _radius = 18;
  static const EdgeInsets _margin = EdgeInsets.fromLTRB(16, 0, 16, 22);
  static const Duration _duration = Duration(seconds: 3);

  /// Affiche un message flottant au-dessus du contenu.
  static void show(
    BuildContext context, {
    required String message,
    AppSnackKind kind = AppSnackKind.info,
    Duration? duration,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.zero,
          margin: _margin,
          behavior: SnackBarBehavior.floating,
          duration: duration ?? _duration,
          content: _SnackContent(message: message, kind: kind),
        ),
      );
  }

  static void success(BuildContext context, String message) =>
      show(context, message: message, kind: AppSnackKind.success);

  static void error(BuildContext context, String message) =>
      show(context, message: message, kind: AppSnackKind.error);

  static void info(BuildContext context, String message) =>
      show(context, message: message, kind: AppSnackKind.info);

  static void warning(BuildContext context, String message) =>
      show(context, message: message, kind: AppSnackKind.warning);
}

extension AppSnackBarContext on BuildContext {
  void showAppSnack(
    String message, {
    AppSnackKind kind = AppSnackKind.info,
  }) =>
      AppSnackBar.show(this, message: message, kind: kind);
}

class _SnackContent extends StatelessWidget {
  const _SnackContent({required this.message, required this.kind});

  final String message;
  final AppSnackKind kind;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final palette = _palette(theme.colorScheme, kind, isDark);

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: palette.background,
          borderRadius: BorderRadius.circular(AppSnackBar._radius),
          border: Border.all(color: palette.border),
          boxShadow: isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: palette.accent.withValues(alpha: 0.14),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: palette.iconBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(palette.icon, size: 22, color: palette.iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: AppFonts.body,
                  color: palette.text,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SnackPalette {
  const _SnackPalette({
    required this.background,
    required this.border,
    required this.text,
    required this.accent,
    required this.iconBackground,
    required this.iconColor,
    required this.icon,
  });

  final Color background;
  final Color border;
  final Color text;
  final Color accent;
  final Color iconBackground;
  final Color iconColor;
  final IconData icon;
}

_SnackPalette _palette(ColorScheme cs, AppSnackKind kind, bool isDark) {
  switch (kind) {
    case AppSnackKind.success:
      return _SnackPalette(
        background: isDark
            ? cs.primary.withValues(alpha: 0.22)
            : cs.primaryContainer.withValues(alpha: 0.98),
        border: cs.primary.withValues(alpha: isDark ? 0.35 : 0.22),
        text: isDark ? cs.onPrimary : cs.onPrimaryContainer,
        accent: cs.primary,
        iconBackground: cs.primary.withValues(alpha: isDark ? 0.28 : 0.14),
        iconColor: cs.primary,
        icon: Icons.check_circle_rounded,
      );
    case AppSnackKind.error:
      return _SnackPalette(
        background: isDark
            ? cs.error.withValues(alpha: 0.2)
            : cs.errorContainer.withValues(alpha: 0.98),
        border: cs.error.withValues(alpha: isDark ? 0.4 : 0.25),
        text: cs.onErrorContainer,
        accent: cs.error,
        iconBackground: cs.error.withValues(alpha: isDark ? 0.25 : 0.12),
        iconColor: cs.error,
        icon: Icons.error_outline_rounded,
      );
    case AppSnackKind.warning:
      return _SnackPalette(
        background: isDark
            ? cs.tertiary.withValues(alpha: 0.18)
            : cs.tertiaryContainer.withValues(alpha: 0.98),
        border: cs.tertiary.withValues(alpha: isDark ? 0.35 : 0.22),
        text: cs.onTertiaryContainer,
        accent: cs.tertiary,
        iconBackground: cs.tertiary.withValues(alpha: isDark ? 0.25 : 0.14),
        iconColor: cs.tertiary,
        icon: Icons.info_outline_rounded,
      );
    case AppSnackKind.info:
      return _SnackPalette(
        background: isDark
            ? cs.surfaceContainerHighest.withValues(alpha: 0.95)
            : cs.surface.withValues(alpha: 0.98),
        border: cs.outline.withValues(alpha: isDark ? 0.28 : 0.18),
        text: cs.onSurface,
        accent: cs.secondary,
        iconBackground: cs.secondary.withValues(alpha: isDark ? 0.2 : 0.1),
        iconColor: cs.secondary,
        icon: Icons.notifications_none_rounded,
      );
  }
}
