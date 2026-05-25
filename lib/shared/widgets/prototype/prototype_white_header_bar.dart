import 'package:flutter/material.dart';

import '../../theme/prototype_layout.dart';
import '../../theme/prototype_palette.dart';

/// Bandeau blanc en haut d’écran (recherche, profil) — style Madbeauty_flutter.
class PrototypeWhiteHeaderBar extends StatelessWidget {
  const PrototypeWhiteHeaderBar({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final layout = PrototypeLayout(context);

    return Container(
      width: double.infinity,
      color: PrototypePalette.cardWhite,
      padding: padding ??
          EdgeInsets.fromLTRB(
            layout.sp(4),
            layout.sp(4),
            layout.sp(4),
            layout.sp(3.5),
          ),
      child: child,
    );
  }
}
