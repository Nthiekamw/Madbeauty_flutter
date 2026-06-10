import 'package:flutter/material.dart';

import '../../../../../../shared/layout/discovery_responsive.dart';
import '../../../../../../shared/theme/app_colors.dart';

/// Niveau d'obligation affiché sur une étape du hub profil.
enum HubStepRequirement { required, recommended, optional }

/// Marges et composants visuels partagés par le hub profil (7 étapes).
abstract final class PrestataireHubLayout {
  PrestataireHubLayout._();

  static const sectionGap = 12.0;
  static const blockGap = 16.0;
  static const actionGap = 10.0;
  static BorderRadius cardRadius = BorderRadius.circular(16);

  /// Padding unique de tout l'écran hub (scroll + rail latéral).
  static EdgeInsets pagePadding(BuildContext context) {
    final h = DiscoveryResponsive.of(context).horizontalPadding;
    return EdgeInsets.fromLTRB(h, 12, h, 28);
  }
}

/// Carte pleine largeur sans marge horizontale supplémentaire.
class PrestataireHubSurfaceCard extends StatelessWidget {
  const PrestataireHubSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = theme.colorScheme.surface.withValues(
      alpha: isDark ? 0.92 : 0.98,
    );

    return Material(
      color: surface,
      elevation: 0,
      surfaceTintColor: AppColors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: PrestataireHubLayout.cardRadius,
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
