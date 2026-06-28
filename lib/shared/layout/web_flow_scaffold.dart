import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'discovery_responsive.dart';
import 'web_flow_page_frame.dart';

/// Scaffold pour parcours client (fiche prestataire, réservation).
class WebFlowScaffold extends StatelessWidget {
  const WebFlowScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.backgroundColor,
    this.bottomNavigationBar,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Color? backgroundColor;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    final layout = DiscoveryResponsive.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mobileBg = backgroundColor ??
        (isDark ? theme.colorScheme.surface : AppColors.lightSurface);

    if (!layout.useWebSiteLayout) {
      return Scaffold(
        appBar: appBar,
        backgroundColor: mobileBg,
        body: body,
        bottomNavigationBar: bottomNavigationBar,
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: appBar,
      body: WebFlowPageFrame(
        applyBackground: false,
        child: body,
      ),
      bottomNavigationBar: bottomNavigationBar == null
          ? null
          : WebFlowPageFrame(
              applyBackground: false,
              child: bottomNavigationBar!,
            ),
    );
  }
}
