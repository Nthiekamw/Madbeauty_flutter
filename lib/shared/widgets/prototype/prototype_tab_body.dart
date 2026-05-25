import 'package:flutter/material.dart';

import '../../theme/prototype_palette.dart';

/// Corps d’onglet prestataire : arrondi crème en haut (style hub flutter).
class PrototypeTabBody extends StatelessWidget {
  const PrototypeTabBody({
    super.key,
    required this.child,
    this.backgroundColor = PrototypePalette.creamPrestataire,
  });

  final Widget child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: PrototypePalette.navDark,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: child,
      ),
    );
  }
}
