import 'package:flutter/material.dart';

import '../../layout/discovery_responsive.dart';
import '../layout/keyboard_dismiss_area.dart';

/// Liste formulaire centrée, largeur max sur tablette, clavier fermable au scroll/tap.
class DiscoveryFormScrollView extends StatelessWidget {
  const DiscoveryFormScrollView({
    super.key,
    required this.children,
    this.padding,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final layout = DiscoveryResponsive.of(context);

    return KeyboardDismissArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: layout.formMaxWidth),
          child: ListView(
            padding: padding ?? layout.formPadding,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: children,
          ),
        ),
      ),
    );
  }
}
