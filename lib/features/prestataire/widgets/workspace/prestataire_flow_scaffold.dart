import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/layout/discovery_responsive.dart';
import '../../../../shared/layout/web_flow_panel.dart';
import '../../../../shared/layout/web_flow_scaffold.dart';
import '../../../../shared/widgets/discovery/discovery_feature_header.dart';
import 'layout/prestataire_brand_scaffold.dart';

/// Scaffold flow prestataire (AppBar + panneau centré sur web).
class PrestataireFlowScaffold extends StatelessWidget {
  const PrestataireFlowScaffold({
    super.key,
    required this.appBar,
    required this.body,
    this.wrapPanel = true,
  });

  final PreferredSizeWidget appBar;
  final Widget body;
  final bool wrapPanel;

  @override
  Widget build(BuildContext context) {
    final useWeb = DiscoveryResponsive.of(context).useWebSiteLayout;
    final content =
        wrapPanel && useWeb ? WebFlowPanel(child: body) : body;

    if (useWeb) {
      return WebFlowScaffold(appBar: appBar, body: content);
    }

    return PrestataireBrandScaffold(appBar: appBar, body: body);
  }
}

/// Sous-page prestataire avec en-tête feature (mobile) ou AppBar (web).
class PrestataireSubpageScaffold extends StatelessWidget {
  const PrestataireSubpageScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.body,
    this.wrapPanel = true,
    this.backEnabled = true,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget body;
  final bool wrapPanel;
  final bool backEnabled;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final useWeb = DiscoveryResponsive.of(context).useWebSiteLayout;
    final content =
        wrapPanel && useWeb ? WebFlowPanel(child: body) : body;

    if (useWeb) {
      return WebFlowScaffold(
        appBar: AppBar(
          title: Text(title),
          automaticallyImplyLeading: backEnabled,
          leading: backEnabled
              ? IconButton(
                  onPressed: onBack ?? () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                )
              : null,
        ),
        body: content,
      );
    }

    final headerIcon = icon;

    return PrestataireBrandScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: backEnabled ? (onBack ?? () => context.pop()) : null,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          if (headerIcon != null)
            DiscoveryFeatureHeader(
              title: title,
              subtitle: subtitle,
              icon: headerIcon,
            ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
