import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../shared/widgets/prototype/prototype_bottom_nav.dart';

class ClientShellBottomNav extends StatelessWidget {
  const ClientShellBottomNav({
    super.key,
    required this.selectedIndex,
    required this.reservationsBadgeCount,
    required this.onTap,
  });

  final int selectedIndex;
  final int reservationsBadgeCount;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return PrototypeLightBottomNav(
      selectedIndex: selectedIndex,
      onTap: onTap,
      destinations: [
        const PrototypeNavDestination(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home_rounded,
          label: ShellStrings.navClientHome,
        ),
        const PrototypeNavDestination(
          icon: Icons.search_outlined,
          selectedIcon: Icons.search,
          label: ShellStrings.navClientSearch,
        ),
        PrototypeNavDestination(
          icon: Icons.calendar_today_outlined,
          selectedIcon: Icons.calendar_today,
          label: ShellStrings.navClientReservations,
          badgeCount: reservationsBadgeCount,
        ),
        const PrototypeNavDestination(
          icon: Icons.person_outline,
          selectedIcon: Icons.person,
          label: ShellStrings.navClientProfile,
        ),
      ],
    );
  }
}
