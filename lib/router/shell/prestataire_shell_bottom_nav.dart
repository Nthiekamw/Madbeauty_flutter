import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../shared/widgets/prototype/prototype_bottom_nav.dart';

class PrestataireShellBottomNav extends StatelessWidget {
  const PrestataireShellBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return PrototypeDarkBottomNav(
      selectedIndex: selectedIndex,
      onTap: onTap,
      destinations: const [
        PrototypeNavDestination(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home_rounded,
          label: ShellStrings.navPrestataireDashboard,
        ),
        PrototypeNavDestination(
          icon: Icons.calendar_today_outlined,
          selectedIcon: Icons.calendar_today_rounded,
          label: ShellStrings.navPrestataireAgenda,
        ),
        PrototypeNavDestination(
          icon: Icons.groups_outlined,
          selectedIcon: Icons.groups_rounded,
          label: ShellStrings.navPrestataireClients,
        ),
        PrototypeNavDestination(
          icon: Icons.person_outline,
          selectedIcon: Icons.person_rounded,
          label: ShellStrings.navPrestataireProfile,
        ),
      ],
    );
  }
}
