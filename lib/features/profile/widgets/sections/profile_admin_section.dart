import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/user_role.dart';
import '../../../auth/providers/my_roles_provider.dart';
import '../../../../router/navigation_extensions.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/theme/discovery_styles.dart';
import '../../../../shared/widgets/discovery/discovery_menu_tile.dart';

class ProfileAdminSection extends ConsumerWidget {
  const ProfileAdminSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roles = ref.watch(myRolesProvider).value ?? const <UserRole>[];
    final isAdmin = roles.contains(UserRole.admin);
    if (!isAdmin) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.adminBg12,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.adminBorder30),
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  size: 16,
                  color: AppColors.adminAccentMid,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                DiscProfile.sectionAdmin,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: DiscoveryStyles.cardBorderRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.adminAccent.withValues(alpha: isDark ? 0.18 : 0.14),
                theme.colorScheme.surface.withValues(alpha: isDark ? 0.95 : 0.98),
              ],
            ),
            border: Border.all(
              color: AppColors.adminBorder30,
              width: 1.2,
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: AppColors.adminAccent.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          child: Material(
            color: AppColors.transparent,
            borderRadius: DiscoveryStyles.cardBorderRadius,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                  child: Text(
                    DiscProfile.adminSectionSubtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ),
                DiscoveryMenuTile(
                  icon: Icons.verified_user_outlined,
                  title: DiscProfile.actionAdminVerifications,
                  subtitle: DiscProfile.actionAdminVerificationsHint,
                  iconColor: AppColors.adminAccentMid,
                  onTap: () => context.pushAdminVerifications(),
                ),
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: AppColors.adminBorder30.withValues(alpha: 0.5),
                ),
                DiscoveryMenuTile(
                  icon: Icons.flag_outlined,
                  title: DiscProfile.actionAdminReports,
                  subtitle: DiscProfile.actionAdminReportsHint,
                  iconColor: AppColors.adminAccentMid,
                  onTap: () => context.pushAdminReports(),
                ),
                Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: AppColors.adminBorder30.withValues(alpha: 0.5),
                ),
                DiscoveryMenuTile(
                  icon: Icons.bug_report_outlined,
                  title: DiscProfile.actionAdminBugReports,
                  subtitle: DiscProfile.actionAdminBugReportsHint,
                  iconColor: AppColors.adminAccentMid,
                  onTap: () => context.pushAdminBugReports(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
