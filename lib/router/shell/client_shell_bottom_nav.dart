import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../shared/theme/app_fonts.dart';
import 'shell_nav_badge_icon.dart';
import '../../shared/theme/app_colors.dart';

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

class ClientShellBottomNav extends StatelessWidget {
  const ClientShellBottomNav({
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
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    final screenW = MediaQuery.sizeOf(context).width;
    final isCompact = screenW < 360;
    final hPad = isCompact ? 2.0 : 6.0;
    final vPad = isCompact ? 6.0 : 8.0;

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
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        child: Row(
          children: List.generate(_kNavLabels.length, (index) {
            final selected = selectedIndex == index;
            final badgeCount = switch (index) {
              2 => reservationsBadgeCount,
              3 => messagesBadgeCount,
              _ => 0,
            };

            return Expanded(
              child: _NavItem(
                label: _kNavLabels[index],
                icon: shellNavBadgeIcon(
                  outlined: _kNavOutlined[index],
                  filled: _kNavFilled[index],
                  selected: selected,
                  badgeCount: badgeCount,
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
    final screenW = MediaQuery.sizeOf(context).width;
    final isCompact = screenW < 360;
    final iconSz = isCompact ? 20.0 : 22.0;
    final labelSzSelected = isCompact ? 8.5 : 10.0;
    final labelSzUnselected = isCompact ? 8.0 : 9.5;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: EdgeInsets.symmetric(horizontal: isCompact ? 1 : 2),
        padding: EdgeInsets.symmetric(vertical: isCompact ? 6 : 8),
        decoration: BoxDecoration(
          color: selected ? primary.withValues(alpha: 0.1) : AppColors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconTheme(
              data: IconThemeData(
                color: selected
                    ? primary
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                size: iconSz,
              ),
              child: icon,
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontSize: selected ? labelSzSelected : labelSzUnselected,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? primary
                      : theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.6,
                        ),
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

