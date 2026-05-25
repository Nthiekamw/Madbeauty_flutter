import 'package:flutter/material.dart';

import '../../shared/theme/app_fonts.dart';
import 'shell_nav_badge_icon.dart';

const _kNavLabels = ['Accueil', 'Recherche', 'Réservations', 'Profil'];
const _kNavOutlined = [
  Icons.home_outlined,
  Icons.search_outlined,
  Icons.event_outlined,
  Icons.person_outline_rounded,
];
const _kNavFilled = [
  Icons.home_rounded,
  Icons.search_rounded,
  Icons.event_rounded,
  Icons.person_rounded,
];

class ClientShellBottomNav extends StatelessWidget {
  const ClientShellBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    this.reservationsBadgeCount = 0,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;
  final int reservationsBadgeCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(
          alpha: isDark ? 0.95 : 0.98,
        ),
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: primary.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: List.generate(_kNavLabels.length, (index) {
            final selected = selectedIndex == index;
            final isReservations = index == 2;

            return Expanded(
              child: _NavItem(
                label: _kNavLabels[index],
                icon: shellNavBadgeIcon(
                  outlined: _kNavOutlined[index],
                  filled: _kNavFilled[index],
                  selected: selected,
                  badgeCount: isReservations ? reservationsBadgeCount : 0,
                ),
                selected: selected,
                onTap: () => onTap(index),
                theme: theme,
                primary: primary,
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.theme,
    required this.primary,
  });

  final String label;
  final Widget icon;
  final bool selected;
  final VoidCallback onTap;
  final ThemeData theme;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconTheme(
              data: IconThemeData(
                color: selected
                    ? primary
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                size: 24,
              ),
              child: icon,
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontFamily: AppFonts.body,
                fontSize: selected ? 11 : 10.5,
                fontWeight:
                    selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? primary
                    : theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.6),
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
