import 'package:flutter/material.dart';

import '../../../../shared/layout/discovery_responsive.dart';
import 'profile_page_insets.dart';

/// Profil web : identité à gauche, réglages en grille à droite.
class ProfileContentLayout extends StatelessWidget {
  const ProfileContentLayout({
    super.key,
    required this.identity,
    required this.sidebar,
    required this.main,
  });

  final Widget identity;
  final Widget sidebar;
  final Widget main;

  @override
  Widget build(BuildContext context) {
    final layout = DiscoveryResponsive.of(context);
    if (!layout.useWebTwoPane) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          identity,
          const SizedBox(height: ProfilePageInsets.sectionGap),
          main,
          const SizedBox(height: ProfilePageInsets.sectionGap),
          sidebar,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 360,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              identity,
              const SizedBox(height: ProfilePageInsets.sectionGap),
              sidebar,
            ],
          ),
        ),
        const SizedBox(width: 28),
        Expanded(child: main),
      ],
    );
  }
}

/// Grille 2 colonnes pour cartes profil / cockpit sur web.
class ProfileCardsGrid extends StatelessWidget {
  const ProfileCardsGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final layout = DiscoveryResponsive.of(context);
    if (!layout.useWebTwoPane || children.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: ProfilePageInsets.sectionGap),
            children[i],
          ],
        ],
      );
    }

    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += 2) {
      if (i > 0) {
        rows.add(const SizedBox(height: ProfilePageInsets.sectionGap));
      }
      if (i + 1 < children.length) {
        rows.add(
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: children[i]),
                const SizedBox(width: 16),
                Expanded(child: children[i + 1]),
              ],
            ),
          ),
        );
      } else {
        rows.add(children[i]);
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }
}
