import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/discovery_styles.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../models/admin_analytics_summary.dart';
import '../providers/admin_analytics_provider.dart';
import '../providers/admin_pending_counts_provider.dart';
import '../providers/admin_user_support_provider.dart';
import '../widgets/admin_country_stats_section.dart';
import '../widgets/admin_hub_action_tile.dart';
import '../widgets/admin_screen_scaffold.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final responsive = DiscoveryResponsive.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pendingVerifications =
        ref.watch(adminPendingVerificationsCountProvider);
    final pendingReports = ref.watch(adminPendingReportsCountProvider);
    final pendingBugs = ref.watch(adminPendingBugReportsCountProvider);
    final supportUnread = ref.watch(adminUserSupportUnreadCountProvider);
    final analyticsAsync = ref.watch(adminAnalyticsProvider);

    final moderationPending =
        (pendingVerifications.value ?? 0) + (pendingReports.value ?? 0);
    final supportPending =
        (pendingBugs.value ?? 0) + (supportUnread.value ?? 0);

    return AdminScreenScaffold(
      title: ShellStrings.navAdminHome,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          responsive.horizontalPadding,
          8,
          responsive.horizontalPadding,
          24,
        ),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: responsive.contentMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AdminScreenIntroBanner(
                    icon: Icons.dashboard_rounded,
                    title: DiscProfile.adminHomeWelcomeTitle,
                    body: DiscProfile.adminHomeWelcomeBody,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    DiscProfile.adminHomeAnalyticsTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  analyticsAsync.when(
                    data: (stats) => _AnalyticsGrid(
                      stats: stats,
                      onVerificationsTap: () =>
                          context.pushAdminVerifications(),
                      onReportsTap: () => context.pushAdminReports(),
                    ),
                    loading: () => const _StatsLoading(),
                    error: (_, __) => pendingVerifications.when(
                      data: (vCount) => pendingReports.when(
                        data: (rCount) => _StatsRow(
                          verificationsCount: vCount,
                          reportsCount: rCount,
                          onVerificationsTap: () =>
                              context.pushAdminVerifications(),
                          onReportsTap: () => context.pushAdminReports(),
                        ),
                        loading: () => const _StatsLoading(),
                        error: (_, __) => const _StatsLoading(),
                      ),
                      loading: () => const _StatsLoading(),
                      error: (_, __) => const _StatsLoading(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    DiscProfile.adminHomeQuickAccessTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AdminHubActionGrid(
                    children: [
                      AdminHubActionTile(
                        icon: Icons.gavel_outlined,
                        title: ShellStrings.navAdminModeration,
                        subtitle: DiscProfile.adminModerationHubBody,
                        badge: moderationPending,
                        onTap: () => context.goAdminModeration(),
                      ),
                      AdminHubActionTile(
                        icon: Icons.support_agent_outlined,
                        title: ShellStrings.navAdminSupport,
                        subtitle: DiscProfile.adminSupportHubBody,
                        badge: supportPending,
                        onTap: () => context.goAdminSupport(),
                      ),
                      AdminHubActionTile(
                        icon: Icons.tune_outlined,
                        title: ShellStrings.navAdminManagement,
                        subtitle: DiscProfile.adminManagementHubBody,
                        onTap: () => context.goAdminManagement(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const AdminCountryStatsSection(),
                  const SizedBox(height: 20),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: DiscoveryStyles.cardBorderRadius,
                      color: AppColors.adminBg12,
                      border: Border.all(color: AppColors.adminBorder30),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            color: AppColors.adminAccentMid,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              DiscProfile.adminHomeIsolationHint,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? theme.colorScheme.onSurfaceVariant
                                    : AppColors.adminAccentDark,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsGrid extends StatelessWidget {
  const _AnalyticsGrid({
    required this.stats,
    required this.onVerificationsTap,
    required this.onReportsTap,
  });

  final AdminAnalyticsSummary stats;
  final VoidCallback onVerificationsTap;
  final VoidCallback onReportsTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatTile(
                value: '${stats.clientsTotal}',
                label: DiscProfile.adminHomeStatClients,
                icon: Icons.person_outline_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                value: '${stats.prestatairesTotal}',
                label: DiscProfile.adminHomeStatPrestataires,
                icon: Icons.storefront_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                value: '${stats.verificationPending}',
                label: DiscProfile.adminHomeStatVerifications,
                icon: Icons.verified_user_outlined,
                onTap: onVerificationsTap,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                value: '${stats.usersTotal}',
                label: DiscProfile.adminHomeStatUsers,
                icon: Icons.people_outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                value: '${stats.reportsPending}',
                label: DiscProfile.adminHomeStatReports,
                icon: Icons.flag_outlined,
                onTap: onReportsTap,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                value: '${stats.reservationsTotal}',
                label: DiscProfile.adminHomeStatReservations,
                icon: Icons.event_note_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _StatTile(
          value: CurrencyFormat.eurCents(stats.revenueCapturedCents),
          label: DiscProfile.adminHomeStatRevenue,
          icon: Icons.euro_rounded,
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.verificationsCount,
    required this.reportsCount,
    required this.onVerificationsTap,
    required this.onReportsTap,
  });

  final int verificationsCount;
  final int reportsCount;
  final VoidCallback onVerificationsTap;
  final VoidCallback onReportsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            value: '$verificationsCount',
            label: DiscProfile.adminHomeStatVerifications,
            icon: Icons.verified_user_outlined,
            onTap: onVerificationsTap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            value: '$reportsCount',
            label: DiscProfile.adminHomeStatReports,
            icon: Icons.flag_outlined,
            onTap: onReportsTap,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.value,
    required this.label,
    required this.icon,
    this.onTap,
  });

  final String value;
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: DiscoveryStyles.cardBorderRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: DiscoveryStyles.cardBorderRadius,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: DiscoveryStyles.cardBorderRadius,
            border: Border.all(color: AppColors.adminBorder30),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            child: Column(
              children: [
                Icon(icon, color: AppColors.adminAccentMid, size: 22),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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

class _StatsLoading extends StatelessWidget {
  const _StatsLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 96,
      child: DiscoveryListSkeleton(
        rowCount: 1,
        rowHeight: 80,
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
