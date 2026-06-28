import 'package:flutter/material.dart';

import '../../layout/shell_nav_destination.dart';
import '../../theme/app_fonts.dart';

/// Navigation horizontale en haut (web étroit) — style site, pas barre mobile.
class WebShellTopNav extends StatelessWidget {
  const WebShellTopNav({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<ShellNavDestination> destinations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Material(
      color: theme.colorScheme.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.12),
            ),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(destinations.length, (index) {
                        final item = destinations[index];
                        final selected = selectedIndex == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: TextButton.icon(
                            onPressed: () => onDestinationSelected(index),
                            style: TextButton.styleFrom(
                              foregroundColor: selected
                                  ? primary
                                  : theme.colorScheme.onSurfaceVariant,
                              backgroundColor: selected
                                  ? primary.withValues(alpha: 0.1)
                                  : Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: _topNavIcon(
                              item.outlinedIcon,
                              item.filledIcon,
                              selected: selected,
                              badgeCount: item.badgeCount,
                            ),
                            label: Text(
                              item.label,
                              style: TextStyle(
                                fontFamily: AppFonts.body,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _topNavIcon(
  IconData outlined,
  IconData filled, {
  required bool selected,
  int badgeCount = 0,
}) {
  final icon = Icon(selected ? filled : outlined, size: 22);
  if (badgeCount <= 0) return icon;
  final label = badgeCount > 99 ? '99+' : '$badgeCount';
  return Badge(
    label: Text(label, style: const TextStyle(fontSize: 11)),
    child: icon,
  );
}
