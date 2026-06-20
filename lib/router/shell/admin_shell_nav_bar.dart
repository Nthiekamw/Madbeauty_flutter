import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_fonts.dart';
import 'shell_nav_badge_icon.dart';

const _kNavLabels = [
  ShellStrings.navAdminHome,
  ShellStrings.navAdminModeration,
  ShellStrings.navAdminSupport,
  ShellStrings.navAdminManagement,
  ShellStrings.navAdminProfile,
];
const _kNavOutlined = [
  Icons.home_outlined,
  Icons.gavel_outlined,
  Icons.support_agent_outlined,
  Icons.tune_outlined,
  Icons.shield_outlined,
];
const _kNavFilled = [
  Icons.home_rounded,
  Icons.gavel_rounded,
  Icons.support_agent_rounded,
  Icons.tune_rounded,
  Icons.shield_rounded,
];

/// Barre d'onglets back-office admin (5 onglets, accent or / bronze).
class AdminShellNavBar extends StatelessWidget {
  const AdminShellNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    this.moderationBadgeCount = 0,
    this.supportBadgeCount = 0,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;
  final int moderationBadgeCount;
  final int supportBadgeCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = AppColors.adminAccentMid;
    final onAccent =
        isDark ? AppColors.adminAccent : AppColors.brandBrown;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.adminBorder30.withValues(alpha: 0.45),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.adminAccent.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 6, 4, 4),
          child: Row(
            children: List.generate(_kNavLabels.length, (index) {
              final selected = selectedIndex == index;
              final badgeCount = switch (index) {
                1 => moderationBadgeCount,
                2 => supportBadgeCount,
                _ => 0,
              };

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Material(
                    color: selected
                        ? AppColors.adminBg12
                        : AppColors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: selected
                          ? BorderSide(color: AppColors.adminBorder30)
                          : BorderSide.none,
                    ),
                    child: InkWell(
                      onTap: () => onTap(index),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconTheme(
                              data: IconThemeData(
                                color: selected
                                    ? accent
                                    : theme.colorScheme.onSurfaceVariant,
                                size: 21,
                              ),
                              child: shellNavBadgeIcon(
                                outlined: _kNavOutlined[index],
                                filled: _kNavFilled[index],
                                selected: selected,
                                badgeCount: badgeCount,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _kNavLabels[index],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontFamily: AppFonts.body,
                                fontWeight:
                                    selected ? FontWeight.w700 : FontWeight.w500,
                                fontSize: 9.5,
                                letterSpacing: -0.1,
                                color: selected
                                    ? onAccent
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
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
