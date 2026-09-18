import 'package:flutter/material.dart';

import 'discovery_responsive.dart';

/// Deux colonnes web : occupe la largeur sans laisser de vide à droite.
class WebPageSplit extends StatelessWidget {
  const WebPageSplit({
    super.key,
    required this.leading,
    required this.trailing,
    this.leadingWidth = 360,
    this.gap = 28,
  });

  final Widget leading;
  final Widget trailing;
  final double leadingWidth;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final layout = DiscoveryResponsive.of(context);
    if (!layout.useWebTwoPane) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          leading,
          SizedBox(height: gap),
          trailing,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: leadingWidth,
          child: leading,
        ),
        SizedBox(width: gap),
        Expanded(child: trailing),
      ],
    );
  }
}
