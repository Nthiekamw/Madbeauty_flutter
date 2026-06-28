import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/discovery/discovery_brand_scaffold.dart';
import '../widgets/discovery/discovery_feature_header.dart';
import 'discovery_responsive.dart';
import 'web_flow_panel.dart';
import 'web_flow_scaffold.dart';

/// Scaffold sous-page profil / aide : flow centré sur web, brand sur mobile.
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
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget body;
  final bool wrapPanel;
  final VoidCallback? onBack;
  final bool backEnabled;

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

    return DiscoveryBrandScaffold(
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
