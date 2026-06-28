import 'package:flutter/material.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../shared/layout/discovery_responsive.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/widgets/layout/web_prestataire_page_header.dart';
import 'prestataire_workspace_header.dart';

/// Corps d'écran prestataire : bandeau marron (mobile) ou layout web épuré.
class PrestataireWorkspaceShell extends StatelessWidget {
  const PrestataireWorkspaceShell({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.onRefresh,
    this.headerSubtitle,
    this.showMessagesAction = true,
    this.top,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final Future<void> Function()? onRefresh;
  final String? headerSubtitle;
  final bool showMessagesAction;
  final Widget? top;

  String _resolveSubtitle() {
    if (subtitle?.trim().isNotEmpty == true) return subtitle!.trim();
    if (headerSubtitle?.trim().isNotEmpty == true) return headerSubtitle!.trim();
    return DiscPrestaWorkspace.spaceLabel;
  }

  @override
  Widget build(BuildContext context) {
    final layout = DiscoveryResponsive.of(context);
    if (layout.useWebSiteLayout) {
      return _WebPrestataireWorkspaceShell(
        title: title ?? ShellStrings.navPrestataireDashboard,
        subtitle: _resolveSubtitle(),
        onRefresh: onRefresh,
        showMessagesAction: showMessagesAction,
        top: top,
        child: child,
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrestataireWorkspaceHeader(
          onRefresh: onRefresh,
          subtitle: headerSubtitle ?? subtitle,
          showMessagesAction: showMessagesAction,
        ),
        Expanded(
          child: Transform.translate(
            offset: const Offset(0, -12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.workspacePanelFor(theme.brightness),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                border: isDark
                    ? Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      )
                    : null,
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: theme.colorScheme.shadow.withValues(
                            alpha: 0.06,
                          ),
                          blurRadius: 12,
                          offset: const Offset(0, -2),
                        ),
                      ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (top != null) top!,
                    Expanded(child: child),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WebPrestataireWorkspaceShell extends StatelessWidget {
  const _WebPrestataireWorkspaceShell({
    required this.title,
    required this.subtitle,
    required this.child,
    this.onRefresh,
    this.showMessagesAction = true,
    this.top,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Future<void> Function()? onRefresh;
  final bool showMessagesAction;
  final Widget? top;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final layout = DiscoveryResponsive.of(context);
    final radius = layout.webShellCardRadius;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WebPrestatairePageHeader(
          title: title,
          subtitle: subtitle,
          compact: true,
          onRefresh: onRefresh,
          showMessagesAction: showMessagesAction,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              layout.webShellHorizontalPadding,
              16,
              layout.webShellHorizontalPadding,
              20,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.workspacePanelFor(theme.brightness),
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(
                    alpha: theme.brightness == Brightness.dark ? 0.2 : 0.1,
                  ),
                ),
                boxShadow: theme.brightness == Brightness.light
                    ? [
                        BoxShadow(
                          color: AppColors.brandBrown.withValues(alpha: 0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (top != null) top!,
                    Expanded(child: child),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
