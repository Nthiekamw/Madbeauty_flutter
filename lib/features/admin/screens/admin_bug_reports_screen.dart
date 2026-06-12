import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/app/app_network_image.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../models/admin_bug_report.dart';
import '../providers/admin_bug_reports_provider.dart';
import '../providers/admin_pending_counts_provider.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../widgets/admin_discovery_widgets.dart';
import '../widgets/admin_screen_scaffold.dart';

class AdminBugReportsScreen extends ConsumerStatefulWidget {
  const AdminBugReportsScreen({super.key});

  @override
  ConsumerState<AdminBugReportsScreen> createState() =>
      _AdminBugReportsScreenState();
}

class _AdminBugReportsScreenState extends ConsumerState<AdminBugReportsScreen> {
  AdminBugReportFilter _filter = AdminBugReportFilter.pending;
  final Set<String> _busyIds = <String>{};
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'fr_FR');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reportsAsync = ref.watch(adminBugReportsProvider(_filter));

    return AdminScreenScaffold(
      title: DiscBug.adminScreenTitle,
      body: Column(
        children: [
          const AdminScreenIntroBanner(
            icon: Icons.bug_report_outlined,
            title: DiscBug.adminIntroTitle,
            body: DiscBug.adminIntroBody,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: AdminFilterSegment<AdminBugReportFilter>(
              segments: const [
                ButtonSegment(
                  value: AdminBugReportFilter.pending,
                  label: Text(DiscBug.adminFilterPending),
                ),
                ButtonSegment(
                  value: AdminBugReportFilter.all,
                  label: Text(DiscBug.adminFilterAll),
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
                    icon: Icons.bug_report_outlined,
                    title: DiscBug.adminEmpty,
                    body: DiscBug.adminIntroBody,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(adminBugReportsProvider(_filter));
                    await ref.read(adminBugReportsProvider(_filter).future);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _BugReportCard(
                        item: item,
                        dateFormat: _dateFormat,
                        busy: _busyIds.contains(item.id),
                        onUpdate: (status, adminNotes, reporterMessage) =>
                            _update(
                              item,
                              status,
                              adminNotes: adminNotes,
                              reporterMessage: reporterMessage,
                            ),
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
                    ref.invalidate(adminBugReportsProvider(_filter)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _update(
    AdminBugReport item,
    String status, {
    String? adminNotes,
    String? reporterMessage,
  }) async {
    final service = ref.read(adminBugReportsServiceProvider);
    if (service == null) return;
    setState(() => _busyIds.add(item.id));
    try {
      await service.updateReport(
        reportId: item.id,
        status: status,
        adminNotes: adminNotes,
        reporterMessage: reporterMessage,
      );
      ref.invalidate(adminBugReportsProvider(_filter));
      ref.invalidate(adminPendingBugReportsCountProvider);
      if (mounted) {
        AppSnackBar.show(
          context,
          message: DiscBug.adminUpdated,
          kind: AppSnackKind.success,
        );
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: DiscBug.adminUpdateErr,
          kind: AppSnackKind.error,
        );
      }
    } finally {
      if (mounted) setState(() => _busyIds.remove(item.id));
    }
  }
}

class _BugReportCard extends StatefulWidget {
  const _BugReportCard({
    required this.item,
    required this.dateFormat,
    required this.busy,
    required this.onUpdate,
  });

  final AdminBugReport item;
  final DateFormat dateFormat;
  final bool busy;
  final void Function(
    String status,
    String? adminNotes,
    String? reporterMessage,
  ) onUpdate;

  @override
  State<_BugReportCard> createState() => _BugReportCardState();
}

class _BugReportCardState extends State<_BugReportCard> {
  final _notesController = TextEditingController();
  final _reporterMessageController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    _reporterMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = widget.item;
    final steps = item.stepsToReproduce?.trim();
    final tone = adminBugStatusTone(item.status);

    return AdminDiscoveryCard(
      accentColor: switch (tone) {
        AdminStatusTone.success => theme.colorScheme.tertiary,
        AdminStatusTone.progress => AppColors.adminAccentMid,
        AdminStatusTone.pending => AppColors.brandBrown,
        _ => theme.colorScheme.outline,
      },
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
                child: const Icon(
                  Icons.bug_report_outlined,
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
                      item.title,
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
                          icon: Icons.category_outlined,
                          label: DiscBug.categoryLabel(item.category),
                        ),
                        AdminMetaChip(
                          icon: Icons.schedule_rounded,
                          label: widget.dateFormat.format(
                            item.createdAt.toLocal(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AdminStatusChip(
                label: DiscBug.statusLabel(item.status),
                tone: tone,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.description,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
          if (steps != null && steps.isNotEmpty) ...[
            const AdminCardSectionTitle(title: 'Étapes pour reproduire'),
            Text(
              steps,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ],
          AdminInfoRow(
            icon: Icons.person_outline_rounded,
            label: 'Reporter',
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
          if (item.appVersion != null || item.platform != null)
            AdminInfoRow(
              icon: Icons.smartphone_outlined,
              label: 'Appareil',
              value: [
                if (item.appVersion != null) 'v${item.appVersion}',
                if (item.platform != null) item.platform,
                if (item.deviceInfo != null) item.deviceInfo,
              ].join(' · '),
              dense: true,
            ),
          if (item.currentScreen != null &&
              item.currentScreen!.trim().isNotEmpty)
            AdminInfoRow(
              icon: Icons.route_outlined,
              label: 'Écran',
              value: item.currentScreen!,
              dense: true,
            ),
          if (item.screenshotUrl != null &&
              item.screenshotUrl!.trim().isNotEmpty) ...[
            const AdminCardSectionTitle(title: 'Capture d’écran'),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AppNetworkImage(
                url: item.screenshotUrl!,
                height: 200,
                width: double.infinity,
              ),
            ),
          ],
          if (item.adminNotes != null && item.adminNotes!.trim().isNotEmpty)
            AdminNotePanel(
              title: 'Note interne',
              body: item.adminNotes!,
            ),
          if (item.reporterMessage != null &&
              item.reporterMessage!.trim().isNotEmpty)
            AdminNotePanel(
              title: 'Message utilisateur',
              body: item.reporterMessage!,
              highlighted: true,
            ),
          AdminActionRow(
            children: [
              OutlinedButton.icon(
                onPressed: widget.busy
                    ? null
                    : () => context.pushBugReportChat(item.id),
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                label: const Text(DiscBug.adminOpenChat),
              ),
            ],
          ),
          if (item.isPending) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              enabled: !widget.busy,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: DiscBug.adminNotesLabel,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.35),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _reporterMessageController,
              enabled: !widget.busy,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: DiscBug.adminReporterMessageLabel,
                hintText: DiscBug.adminReporterMessageHint,
                alignLabelWithHint: true,
                filled: true,
                fillColor: theme.colorScheme.primaryContainer
                    .withValues(alpha: 0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            AdminActionRow(
              children: [
                if (item.status == 'pending')
                  FilledButton.icon(
                    onPressed: widget.busy
                        ? null
                        : () => widget.onUpdate(
                              'in_progress',
                              _notesController.text,
                              _reporterMessageController.text,
                            ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    label: const Text(DiscBug.adminActionInProgress),
                  ),
                FilledButton.icon(
                  onPressed: widget.busy
                      ? null
                      : () => widget.onUpdate(
                            'resolved',
                            _notesController.text,
                            _reporterMessageController.text,
                          ),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.tertiary,
                    foregroundColor: theme.colorScheme.onTertiary,
                  ),
                  icon: const Icon(Icons.check_rounded, size: 18),
                  label: const Text(DiscBug.adminActionResolved),
                ),
                OutlinedButton.icon(
                  onPressed: widget.busy
                      ? null
                      : () => widget.onUpdate(
                            'closed',
                            _notesController.text,
                            _reporterMessageController.text,
                          ),
                  icon: const Icon(Icons.archive_outlined, size: 18),
                  label: const Text(DiscBug.adminActionClosed),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
