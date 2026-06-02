import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../shared/theme/app_fonts.dart';
import 'shell_nav_badge_icon.dart';

const _kNavLabels = [
  ShellStrings.navClientHome,
  ShellStrings.navClientSearch,
  ShellStrings.navClientReservations,
  ShellStrings.navClientMessages,
  ShellStrings.navClientProfile,
];
const _kNavOutlined = [
  Icons.home_outlined,
  Icons.search_outlined,
  Icons.event_outlined,
  Icons.chat_bubble_outline_rounded,
  Icons.person_outline_rounded,
];
const _kNavFilled = [
  Icons.home_rounded,
  Icons.search_rounded,
  Icons.event_rounded,
  Icons.chat_bubble_rounded,
  Icons.person_rounded,
];

/// Barre d’onglets client (pilule active, style maquette).
class ClientShellNavBar extends StatelessWidget {
  const ClientShellNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    this.reservationsBadgeCount = 0,
    this.messagesBadgeCount = 0,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;
  final int reservationsBadgeCount;
  final int messagesBadgeCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
          child: Row(
            children: List.generate(_kNavLabels.length, (index) {
              final selected = selectedIndex == index;
              final badgeCount = switch (index) {
                2 => reservationsBadgeCount,
                3 => messagesBadgeCount,
                _ => 0,
              };

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Material(
                    color: selected ? primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: () => onTap(index),
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconTheme(
                              data: IconThemeData(
                                color: selected
                                    ? onPrimary
                                    : theme.colorScheme.onSurfaceVariant,
                                size: 22,
                              ),
                              child: shellNavBadgeIcon(
                                outlined: _kNavOutlined[index],
                                filled: _kNavFilled[index],
                                selected: selected,
                                badgeCount: badgeCount,
                              ),
                            ),
                            if (selected) ...[
                              const SizedBox(height: 2),
                              Text(
                                _kNavLabels[index],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontFamily: AppFonts.body,
                                  fontWeight: FontWeight.w700,
                                  color: onPrimary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
