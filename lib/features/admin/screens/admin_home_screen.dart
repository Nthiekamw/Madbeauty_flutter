import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/app_router.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/discovery_styles.dart';
import '../models/admin_analytics_summary.dart';
import '../providers/admin_analytics_provider.dart';
import '../providers/admin_pending_counts_provider.dart';
import '../widgets/admin_screen_scaffold.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/utils/currency_format.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pendingVerifications =
        ref.watch(adminPendingVerificationsCountProvider);
    final pendingReports = ref.watch(adminPendingReportsCountProvider);
    final analyticsAsync = ref.watch(adminAnalyticsProvider);

    return AdminScreenScaffold(
      title: ShellStrings.navAdminHome,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const AdminScreenIntroBanner(
            icon: Icons.shield_rounded,
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
            data: (stats) => _AnalyticsGrid(stats: stats),
            loading: () => const _StatsLoading(),
            error: (_, __) => pendingVerifications.when(
              data: (vCount) => pendingReports.when(
                data: (rCount) => _StatsRow(
                  verificationsCount: vCount,
                  reportsCount: rCount,
                ),
                loading: () => const _StatsLoading(),
                error: (_, __) => const _StatsLoading(),
              ),
              loading: () => const _StatsLoading(),
              error: (_, __) => const _StatsLoading(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            DiscProfile.adminHomeActionsTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          _ActionCard(
            icon: Icons.verified_user_outlined,
            title: DiscProfile.actionAdminVerifications,
            subtitle: DiscProfile.actionAdminVerificationsHint,
            badge: pendingVerifications.maybeWhen(data: (c) => c, orElse: () => 0),
            onTap: () => context.goNamed(AppRouteNames.adminVerifications),
          ),
          const SizedBox(height: 10),
          _ActionCard(
            icon: Icons.flag_outlined,
            title: DiscProfile.actionAdminReports,
            subtitle: DiscProfile.actionAdminReportsHint,
            badge: pendingReports.maybeWhen(data: (c) => c, orElse: () => 0),
            onTap: () => context.goNamed(AppRouteNames.adminReports),
          ),
          const SizedBox(height: 10),
          _ActionCard(
            icon: Icons.people_outline,
            title: DiscProfile.actionAdminUsers,
            subtitle: DiscProfile.actionAdminUsersHint,
            onTap: () => context.pushAdminUsers(),
          ),
          const SizedBox(height: 10),
          _ActionCard(
            icon: Icons.payments_outlined,
            title: DiscProfile.actionAdminReservations,
            subtitle: DiscProfile.actionAdminReservationsHint,
            onTap: () => context.pushAdminReservations(),
          ),
          const SizedBox(height: 10),
          _ActionCard(
            icon: Icons.notifications_active_outlined,
            title: DiscProfile.actionAdminPush,
            subtitle: DiscProfile.actionAdminPushHint,
            onTap: () => context.pushAdminPush(),
          ),
          const SizedBox(height: 10),
          _ActionCard(
            icon: Icons.history,
            title: DiscProfile.actionAdminAudit,
            subtitle: DiscProfile.actionAdminAuditHint,
            onTap: () => context.pushAdminAudit(),
          ),
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
    );
  }
}

class _AnalyticsGrid extends StatelessWidget {
  const _AnalyticsGrid({required this.stats});

  final AdminAnalyticsSummary stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatTile(
                value: '${stats.usersTotal}',
                label: DiscProfile.adminHomeStatUsers,
                icon: Icons.people_outline,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                value: '${stats.verificationPending}',
                label: DiscProfile.adminHomeStatVerifications,
                icon: Icons.verified_user_outlined,
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
  });

  final int verificationsCount;
  final int reportsCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            value: '$verificationsCount',
            label: DiscProfile.adminHomeStatVerifications,
            icon: Icons.verified_user_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatTile(
            value: '$reportsCount',
            label: DiscProfile.adminHomeStatReports,
            icon: Icons.flag_outlined,
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
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: DiscoveryStyles.cardBorderRadius,
        color: theme.colorScheme.surface,
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
    );
  }
}

class _StatsLoading extends StatelessWidget {
  const _StatsLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 96,
      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge = 0,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: DiscoveryStyles.cardBorderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: DiscoveryStyles.cardBorderRadius,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: DiscoveryStyles.cardBorderRadius,
            border: Border.all(
              color: AppColors.adminBorder30.withValues(alpha: 0.7),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.adminBg12,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.adminBorder30),
                  ),
                  child: Icon(icon, color: AppColors.adminAccentMid),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontFamily: AppFonts.display,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                if (badge > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.notificationDot,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$badge',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
