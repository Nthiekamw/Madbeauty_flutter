import 'package:flutter/material.dart';

/// Ferme le clavier au tap en dehors d’un champ (sans bloquer les enfants interactifs).
class KeyboardDismissArea extends StatelessWidget {
  const KeyboardDismissArea({
    super.key,
    required this.child,
    this.behavior = HitTestBehavior.deferToChild,
  });

  final Widget child;
  final HitTestBehavior behavior;

  static void unfocus() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: unfocus,
      behavior: behavior,
      child: child,
    );
  }
}
