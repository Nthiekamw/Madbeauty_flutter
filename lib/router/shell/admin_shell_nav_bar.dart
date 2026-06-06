import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../shared/theme/app_colors.dart';
import '../../shared/theme/app_fonts.dart';
import 'shell_nav_badge_icon.dart';

const _kNavLabels = [
  ShellStrings.navAdminHome,
  ShellStrings.navAdminVerifications,
  ShellStrings.navAdminReports,
  ShellStrings.navAdminProfile,
];
const _kNavOutlined = [
  Icons.dashboard_outlined,
  Icons.verified_user_outlined,
  Icons.flag_outlined,
  Icons.shield_outlined,
];
const _kNavFilled = [
  Icons.dashboard_rounded,
  Icons.verified_user_rounded,
  Icons.flag_rounded,
  Icons.shield_rounded,
];

/// Barre d'onglets back-office admin (accent or / bronze).
class AdminShellNavBar extends StatelessWidget {
  const AdminShellNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    this.verificationsBadgeCount = 0,
    this.reportsBadgeCount = 0,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;
  final int verificationsBadgeCount;
  final int reportsBadgeCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = AppColors.adminAccentMid;
    final onAccent = isDark ? AppColors.onPrimaryDarkText : AppColors.brandBrown;

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
          padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
          child: Row(
            children: List.generate(_kNavLabels.length, (index) {
              final selected = selectedIndex == index;
              final badgeCount = switch (index) {
                1 => verificationsBadgeCount,
                2 => reportsBadgeCount,
                _ => 0,
              };

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Material(
                    color: selected
                        ? AppColors.adminBg12
                        : AppColors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: selected
                          ? BorderSide(color: AppColors.adminBorder30)
                          : BorderSide.none,
                    ),
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
                                    ? accent
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
                            const SizedBox(height: 2),
                            Text(
                              _kNavLabels[index],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontFamily: AppFonts.body,
                                fontWeight:
                                    selected ? FontWeight.w700 : FontWeight.w500,
                                fontSize: 10,
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
