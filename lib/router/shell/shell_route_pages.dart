import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'shell_tab_keep_alive.dart';

/// Page sans transition pour les onglets du shell (évite le flash au changement).
Page<void> shellTabPage({required Widget child, LocalKey? key}) {
  return NoTransitionPage<void>(
    key: key,
    child: ShellTabKeepAlive(child: child),
  );
}
