import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../shared/theme/app_fonts.dart';
import '../../shared/theme/app_colors.dart';

/// Barre d'onglets prestataire (pilule active style maquette).
class PrestataireShellNavBar extends StatelessWidget {
  const PrestataireShellNavBar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    this.messagesUnread = 0,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final int messagesUnread;

  static const _labels = [
    ShellStrings.navPrestataireDashboard,
    ShellStrings.navPrestataireAgenda,
    ShellStrings.navPrestataireClients,
    ShellStrings.navPrestataireMessages,
    ShellStrings.navPrestataireProfile,
  ];

  static const _icons = [
    Icons.dashboard_outlined,
    Icons.calendar_month_outlined,
    Icons.groups_outlined,
    Icons.chat_bubble_outline_rounded,
    Icons.person_outline,
  ];

  static const _selectedIcons = [
    Icons.dashboard,
    Icons.calendar_month,
    Icons.groups,
    Icons.chat_bubble_rounded,
    Icons.person,
  ];

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
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
          child: Row(
            children: [
              for (var i = 0; i < _labels.length; i++)
                Expanded(
                  child: _NavItem(
                    selected: i == selectedIndex,
                    icon: i == selectedIndex ? _selectedIcons[i] : _icons[i],
                    label: _labels[i],
                    badge: i == 3 ? messagesUnread : 0,
                    primary: primary,
                    onPrimary: onPrimary,
                    onTap: () => onSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.selected,
    required this.icon,
    required this.label,
    required this.badge,
    required this.primary,
    required this.onPrimary,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final int badge;
  final Color primary;
  final Color onPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: selected ? primary : AppColors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    size: 22,
                    color: selected
                        ? onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  if (badge > 0)
                    Positioned(
                      right: -8,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badge > 9 ? '9+' : '$badge',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (selected) ...[
                const SizedBox(height: 2),
                Text(
                  label,
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
    );
  }
}

