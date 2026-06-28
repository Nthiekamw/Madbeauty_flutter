import 'package:flutter/material.dart';

import '../../../layout/discovery_responsive.dart';

/// Centre le contenu et limite la largeur sur grands écrans.
class DiscoveryConstrainedBody extends StatelessWidget {
  const DiscoveryConstrainedBody({
    super.key,
    required this.child,
    this.maxWidth,
  });

  final Widget child;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final layout = DiscoveryResponsive.of(context);
    if (layout.useWebSiteLayout) return child;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? layout.contentMaxWidth,
        ),
        child: child,
      ),
    );
  }
}

