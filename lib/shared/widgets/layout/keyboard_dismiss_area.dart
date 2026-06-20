import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Ferme le clavier au tap en dehors d'un champ (sans bloquer les enfants interactifs).
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

  static bool _hitTargetAcceptsTextInput(Offset globalPosition, BuildContext context) {
    final box = context.findRenderObject();
    if (box is! RenderBox) return false;

    final result = BoxHitTestResult();
    final local = box.globalToLocal(globalPosition);
    if (!box.hitTest(result, position: local)) return false;

    for (final entry in result.path) {
      if (entry.target is RenderEditable) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) {
        if (_hitTargetAcceptsTextInput(details.globalPosition, context)) return;
        unfocus();
      },
      behavior: behavior,
      child: child,
    );
  }
}

