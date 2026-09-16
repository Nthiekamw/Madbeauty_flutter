import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/layout/discovery_responsive.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/layout/web_client_page_header.dart';
import 'client_workspace_header.dart';

/// Coque client : bandeau marron (mobile) ou layout web épuré.
class ClientWorkspaceShell extends StatelessWidget {
  const ClientWorkspaceShell({
    super.key,
    required this.child,
    this.title,
    this.subtitle = DiscClientWorkspace.searchSubtitle,
    this.header,
    this.top,
    this.panelOverlap = -12,
  });

  final Widget child;
  final String? title;
  final String subtitle;
  final Widget? header;
  final Widget? top;
  final double panelOverlap;

  @override
  Widget build(BuildContext context) {
    final layout = DiscoveryResponsive.of(context);
    if (layout.useWebSiteLayout) {
      return _WebClientWorkspaceShell(
        title: title ?? ShellStrings.navClientSearch,
        subtitle: subtitle,
        top: top,
        child: child,
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header ?? ClientWorkspaceHeader(subtitle: subtitle),
        Expanded(
          child: Transform.translate(
            offset: Offset(0, panelOverlap),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.workspacePanelFor(theme.brightness),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(
                    alpha: isDark ? 0.22 : 0.08,
                  ),
                ),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.12,
                          ),
                          blurRadius: 20,
                          offset: const Offset(0, -4),
                        ),
                      ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
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

class _WebClientWorkspaceShell extends StatelessWidget {
  const _WebClientWorkspaceShell({
    required this.title,
    required this.subtitle,
    required this.child,
    this.top,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? top;

  @override
  Widget build(BuildContext context) {
    final layout = DiscoveryResponsive.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WebClientPageHeader(title: title, subtitle: subtitle, compact: true),
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              layout.webShellHorizontalPadding,
              8,
              layout.webShellHorizontalPadding,
              12,
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
      ],
    );
  }
}
