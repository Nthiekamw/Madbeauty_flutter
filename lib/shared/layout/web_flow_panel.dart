import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'discovery_responsive.dart';

/// Panneau carte pour parcours web (réservation, profil, fiche pro).
class WebFlowPanel extends StatelessWidget {
  const WebFlowPanel({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final layout = DiscoveryResponsive.of(context);
    if (!layout.useWebSiteLayout) return child;

    final theme = Theme.of(context);
    final radius = layout.webShellCardRadius;
    final hPad = layout.webFlowHorizontalPadding;

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 20),
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
          child: child,
        ),
      ),
    );
  }
}
