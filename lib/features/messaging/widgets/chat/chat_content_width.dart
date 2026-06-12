import 'package:flutter/material.dart';

import '../../../../shared/layout/discovery_responsive.dart';

/// Centre le fil de discussion sur grands écrans.
class ChatContentWidth extends StatelessWidget {
  const ChatContentWidth({super.key, required this.child});

  final Widget child;

  static const double _chatMaxWidth = 640;

  @override
  Widget build(BuildContext context) {
    final layout = DiscoveryResponsive.of(context);
    if (!layout.isTablet) return child;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _chatMaxWidth),
        child: child,
      ),
    );
  }
}
