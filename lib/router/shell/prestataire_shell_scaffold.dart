import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/theme/prototype_palette.dart';
import '../../shared/widgets/offline_shell.dart';
import 'prestataire_shell_bottom_nav.dart';
import 'prestataire_shell_header.dart';

class PrestataireShellScaffold extends StatelessWidget {
  const PrestataireShellScaffold({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  static const int clientsTabIndex = 2;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = navigationShell.currentIndex;
    final usePrototypeChrome = selectedIndex != clientsTabIndex;

    return Scaffold(
      backgroundColor: usePrototypeChrome
          ? PrototypePalette.creamPrestataire
          : null,
      body: Column(
        children: [
          if (usePrototypeChrome) const PrestataireShellHeader(),
          Expanded(
            child: OfflineShell(child: navigationShell),
          ),
        ],
      ),
      bottomNavigationBar: PrestataireShellBottomNav(
        selectedIndex: selectedIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == selectedIndex,
          );
        },
      ),
    );
  }
}
