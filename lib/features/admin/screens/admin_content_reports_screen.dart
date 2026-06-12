import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../models/admin_content_report.dart';
import '../providers/admin_pending_counts_provider.dart';
import '../providers/admin_content_reports_provider.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../widgets/admin_discovery_widgets.dart';
import '../widgets/admin_screen_scaffold.dart';

class AdminContentReportsScreen extends ConsumerStatefulWidget {
  const AdminContentReportsScreen({super.key});

  @override
  ConsumerState<AdminContentReportsScreen> createState() =>
      _AdminContentReportsScreenState();
}

class _AdminContentReportsScreenState
    extends ConsumerState<AdminContentReportsScreen> {
  AdminContentReportFilter _filter = AdminContentReportFilter.pending;
  final Set<String> _busyIds = <String>{};
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'fr_FR');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reportsAsync = ref.watch(adminContentReportsProvider(_filter));

    return AdminScreenScaffold(
      title: DiscProfile.actionAdminReports,
      body: Column(
        children: [
          const AdminScreenIntroBanner(
            icon: Icons.flag_outlined,
            title: DiscProfile.adminReportsIntroTitle,
            body: DiscProfile.adminReportsIntroBody,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: AdminFilterSegment<AdminContentReportFilter>(
              segments: const [
                ButtonSegment(
                  value: AdminContentReportFilter.pending,
                  label: Text(DiscProfile.adminReportsFilterPending),
                ),
                ButtonSegment(
                  value: AdminContentReportFilter.all,
                  label: Text(DiscProfile.adminReportsFilterAll),
                ),
              ],
              selected: {_filter},
              onSelectionChanged: (selected) {
                final next = selected.first;
                if (next == _filter) return;
                setState(() => _filter = next);
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: reportsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return const AdminListEmptyState(
                    icon: Icons.flag_outlined,
                    title: DiscProfile.adminReportsEmpty,
                    body: DiscProfile.adminReportsIntroBody,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(adminContentReportsProvider(_filter));
                    await ref.read(
                      adminContentReportsProvider(_filter).future,
                    );
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _ReportCard(
                        item: item,
                        dateFormat: _dateFormat,
                        busy: _busyIds.contains(item.id),
                        onModerate: (action) => _moderate(item, action),
                      );
                    },
                  ),
                );
              },
              loading: () => const DiscoveryListSkeleton(rowCount: 5),
              error: (_, __) => DiscoveryEmptyState(
                icon: Icons.cloud_off_outlined,
                title: CoreStrings.networkErrorTitle,
                body: CoreStrings.networkErrorBody,
                iconColor: theme.colorScheme.error,
                actionLabel: DiscList.retry,
                onAction: () =>
                    ref.invalidate(adminContentReportsProvider(_filter)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _moderate(AdminContentReport item, String action) async {
    final service = ref.read(adminContentReportsServiceProvider);
    if (service == null) return;
    setState(() => _busyIds.add(item.id));
    try {
      await service.moderateReport(reportId: item.id, action: action);
      ref.invalidate(adminContentReportsProvider(_filter));
      ref.invalidate(adminPendingReportsCountProvider);
      if (mounted) {
        AppSnackBar.show(
          context,
          message: DiscProfile.adminReportsModerated,
          kind: AppSnackKind.success,
        );
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: DiscProfile.adminReportsModerateErr,
          kind: AppSnackKind.error,
        );
      }
    } finally {
      if (mounted) setState(() => _busyIds.remove(item.id));
    }
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.item,
    required this.dateFormat,
    required this.busy,
    required this.onModerate,
  });

  final AdminContentReport item;
  final DateFormat dateFormat;
  final bool busy;
  final ValueChanged<String> onModerate;

  IconData _iconForType(String type) => switch (type) {
        'prestataire_profile' => Icons.storefront_outlined,
        'conversation' => Icons.forum_outlined,
        'message' => Icons.chat_outlined,
        _ => Icons.flag_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final details = item.details?.trim();
    final reviewed = item.isReviewed;

    return AdminDiscoveryCard(
      accentColor: reviewed
          ? theme.colorScheme.outline
          : AppColors.errorLight.withValues(alpha: 0.85),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.adminBg12,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.adminBorder30),
                ),
                child: Icon(
                  _iconForType(item.targetType),
                  color: AppColors.adminAccentMid,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.displayTarget,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontFamily: AppFonts.display,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        AdminMetaChip(
                          icon: Icons.label_outline_rounded,
                          label: item.targetTypeLabel,
                        ),
                        AdminMetaChip(
                          icon: Icons.schedule_rounded,
                          label: dateFormat.format(item.createdAt.toLocal()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AdminStatusChip(
                label: reviewed
                    ? DiscProfile.adminReportsStatusReviewed
                    : DiscProfile.adminReportsStatusPending,
                tone: reviewed
                    ? AdminStatusTone.neutral
                    : AdminStatusTone.warning,
              ),
            ],
          ),
          const SizedBox(height: 12),
          AdminNotePanel(
            title: 'Motif',
            body: item.reason,
          ),
          if (details != null && details.isNotEmpty)
            AdminNotePanel(
              title: 'Détails',
              body: details,
            ),
          AdminInfoRow(
            icon: Icons.person_outline_rounded,
            label: 'Signaleur',
            value: item.reporterLabel,
            dense: true,
          ),
          if (item.reporterEmail != null &&
              item.reporterEmail!.trim().isNotEmpty)
            AdminInfoRow(
              icon: Icons.mail_outline_rounded,
              label: 'E-mail',
              value: item.reporterEmail!,
              dense: true,
            ),
          AdminInfoRow(
            icon: Icons.tag_outlined,
            label: 'ID cible',
            value: item.targetId,
            dense: true,
          ),
          if (item.actionTaken != null)
            AdminNotePanel(
              title: 'Action appliquée',
              body: item.actionTaken!,
              highlighted: true,
            ),
          if (!reviewed)
            AdminActionRow(
              children: [
                if (item.targetType == 'prestataire_profile')
                  FilledButton.icon(
                    onPressed: busy ? null : () => onModerate('hide_prestataire'),
                    icon: const Icon(Icons.visibility_off_outlined, size: 18),
                    label: const Text(DiscProfile.adminReportsModerateHide),
                  ),
                if (item.targetType == 'conversation')
                  FilledButton.icon(
                    onPressed: busy
                        ? null
                        : () => onModerate('suspend_conversation'),
                    icon: const Icon(Icons.pause_circle_outline, size: 18),
                    label: const Text(DiscProfile.adminReportsModerateSuspend),
                  ),
                if (item.targetType == 'message')
                  FilledButton.icon(
                    onPressed: busy ? null : () => onModerate('delete_message'),
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text(DiscProfile.adminReportsModerateDelete),
                  ),
                OutlinedButton.icon(
                  onPressed: busy ? null : () => onModerate('dismiss'),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text(DiscProfile.adminReportsModerateDismiss),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
