import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'discovery_responsive.dart';
import 'web_flow_panel.dart';
import 'web_flow_scaffold.dart';

/// Scaffold sous-page profil / aide : AppBar simple (comme Mon panier) + flow web.
class ProfileFlowScaffold extends StatelessWidget {
  const ProfileFlowScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.body,
    this.wrapPanel = true,
    this.onBack,
    this.backEnabled = true,
    this.actions,
  });

  final String title;
  /// Conservé pour compatibilité API (titre AppBar uniquement).
  final String? subtitle;
  /// Conservé pour compatibilité API (titre AppBar uniquement).
  final IconData? icon;
  final Widget body;
  final bool wrapPanel;
  final VoidCallback? onBack;
  final bool backEnabled;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final useWeb = DiscoveryResponsive.of(context).useWebSiteLayout;
    final content =
        wrapPanel && useWeb ? WebFlowPanel(child: body) : body;

    final appBar = AppBar(
      title: Text(title),
      automaticallyImplyLeading: backEnabled,
      leading: backEnabled
          ? IconButton(
              onPressed: onBack ?? () => context.pop(),
              icon: const Icon(Icons.arrow_back_rounded),
            )
          : null,
      actions: actions,
    );

    if (useWeb) {
      return WebFlowScaffold(appBar: appBar, body: content);
    }

    return Scaffold(appBar: appBar, body: content);
  }
}
