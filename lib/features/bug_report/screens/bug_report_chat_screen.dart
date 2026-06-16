import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../../../features/admin/providers/admin_bug_reports_provider.dart';
import '../../../features/admin/providers/admin_pending_counts_provider.dart';
import '../../../features/admin/widgets/admin_discovery_widgets.dart';
import '../../../features/auth/providers/auth_notifier.dart';
import '../../../features/auth/providers/my_roles_provider.dart';
import '../../../core/models/user_role.dart';
import '../../../services/supabase/bug_report/bug_report_providers.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../messaging/logic/chat_message_receipt.dart';
import '../../messaging/widgets/chat/chat_bubble.dart';
import '../../messaging/widgets/chat/chat_composer.dart';

class BugReportChatScreen extends ConsumerStatefulWidget {
  const BugReportChatScreen({super.key, required this.bugReportId});

  final String bugReportId;

  @override
  ConsumerState<BugReportChatScreen> createState() =>
      _BugReportChatScreenState();
}

class _BugReportChatScreenState extends ConsumerState<BugReportChatScreen> {
  final _composer = TextEditingController();
  bool _sending = false;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_syncReceipts());
    });
  }

  Future<void> _syncReceipts() async {
    final service = ref.read(bugReportMessageServiceProvider);
    final userId = ref.read(authNotifierProvider).maybeWhen(
          data: (u) => u?.id,
          orElse: () => null,
        );
    if (service == null || userId == null) return;
    await service.markAsRead(
      bugReportId: widget.bugReportId,
      userId: userId,
    );
  }

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final service = ref.read(bugReportMessageServiceProvider);
    if (service == null) return;
    final text = _composer.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    try {
      await service.send(bugReportId: widget.bugReportId, content: text);
      _composer.clear();
      ref.invalidate(bugReportMessagesProvider(widget.bugReportId));
    } catch (_) {
      if (mounted) AppSnackBar.error(context, DiscBug.chatSendErr);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _closeDiscussion() async {
    final result = await showDialog<_CloseDiscussionChoice>(
      context: context,
      builder: (context) => const _CloseBugDiscussionDialog(),
    );
    if (result == null || !mounted) return;

    final service = ref.read(adminBugReportsServiceProvider);
    if (service == null) return;

    setState(() => _closing = true);
    try {
      await service.updateReport(
        reportId: widget.bugReportId,
        status: result.status,
        reporterMessage: result.reporterMessage,
      );
      ref.invalidate(bugReportChatSummaryProvider(widget.bugReportId));
      ref.invalidate(adminBugReportsProvider(AdminBugReportFilter.pending));
      ref.invalidate(adminBugReportsProvider(AdminBugReportFilter.all));
      ref.invalidate(adminPendingBugReportsCountProvider);
      if (mounted) {
        AppSnackBar.show(
          context,
          message: DiscBug.chatCloseSuccess,
          kind: AppSnackKind.success,
        );
      }
    } catch (_) {
      if (mounted) AppSnackBar.error(context, DiscBug.chatCloseErr);
    } finally {
      if (mounted) setState(() => _closing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final messagesAsync =
        ref.watch(bugReportMessagesProvider(widget.bugReportId));
    final summaryAsync =
        ref.watch(bugReportChatSummaryProvider(widget.bugReportId));
    final currentUserId = ref.watch(authNotifierProvider).maybeWhen(
          data: (u) => u?.id,
          orElse: () => null,
        );
    final isAdmin =
        ref.watch(myRolesProvider).value?.contains(UserRole.admin) ?? false;
    final timeFormat = DateFormat('HH:mm', 'fr_FR');
    final title =
        isAdmin ? DiscBug.chatTitleAdmin : DiscBug.chatTitleReporter;
    final summary = summaryAsync.asData?.value;
    final isClosed = summary?.isTerminal ?? false;

    ref.listen(bugReportMessagesProvider(widget.bugReportId), (_, __) {
      unawaited(_syncReceipts());
    });

    return Scaffold(
      backgroundColor: isDark
          ? theme.colorScheme.surface
          : AppColors.lightSurfaceContainer,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              summary?.title ?? title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (summary != null)
              Text(
                DiscBug.statusLabel(summary.status),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.adminAccentMid,
                  fontWeight: FontWeight.w700,
                ),
              )
            else
              Text(
                DiscBug.openChat,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.adminAccentMid,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
        actions: [
          if (isAdmin && summary != null && !summary.isTerminal)
            TextButton.icon(
              onPressed: _closing ? null : _closeDiscussion,
              icon: _closing
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.error,
                      ),
                    )
                  : Icon(
                      Icons.lock_outline_rounded,
                      size: 18,
                      color: theme.colorScheme.error,
                    ),
              label: Text(
                DiscBug.chatCloseAction,
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
        flexibleSpace: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.adminAccent.withValues(alpha: isDark ? 0.14 : 0.1),
                theme.colorScheme.surface.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (isAdmin && !isClosed)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: DiscoverySurfaceCard(
                includeHorizontalMargin: false,
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.support_agent_rounded,
                      color: AppColors.adminAccentMid,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        DiscBug.chatAdminHint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (isClosed)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: DiscoverySurfaceCard(
                includeHorizontalMargin: false,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      Icons.lock_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        DiscBug.chatClosedBanner,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                    if (summary != null)
                      AdminStatusChip(
                        label: DiscBug.statusLabel(summary.status),
                        tone: adminBugStatusTone(summary.status),
                      ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return DiscoveryEmptyState(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: DiscBug.chatEmpty,
                    body: isClosed
                        ? DiscBug.chatClosedBanner
                        : (isAdmin
                            ? DiscBug.chatAdminHint
                            : DiscBug.chatEmptyReporterHint),
                    iconColor: AppColors.adminAccentMid,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 4,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMine = message.senderId == currentUserId;
                    return ChatBubble(
                      text: message.content,
                      isMine: isMine,
                      receiptStatus: isMine
                          ? chatOutgoingReceiptStatus(
                              isRead: message.isRead,
                              deliveredAt: message.deliveredAt,
                            )
                          : null,
                      timeLabel: timeFormat.format(message.createdAt.toLocal()),
                    );
                  },
                );
              },
              loading: () => const DiscoveryListSkeleton(
                rowCount: 4,
                rowHeight: 56,
                padding: EdgeInsets.all(16),
              ),
              error: (_, __) => Center(
                child: Text(
                  DiscBug.chatLoadErr,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            ),
          ),
          if (!isClosed)
            DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.12),
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: ChatComposer(
                  controller: _composer,
                  sending: _sending,
                  onSend: _send,
                ),
              ),
            )
          else
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Text(
                  DiscBug.chatClosedInputHint,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CloseDiscussionChoice {
  const _CloseDiscussionChoice({
    required this.status,
    this.reporterMessage,
  });

  final String status;
  final String? reporterMessage;
}

class _CloseBugDiscussionDialog extends StatefulWidget {
  const _CloseBugDiscussionDialog();

  @override
  State<_CloseBugDiscussionDialog> createState() =>
      _CloseBugDiscussionDialogState();
}

class _CloseBugDiscussionDialogState extends State<_CloseBugDiscussionDialog> {
  final _messageController = TextEditingController();
  String _status = 'resolved';

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text(DiscBug.chatCloseDialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              DiscBug.chatCloseDialogBody,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
            const SizedBox(height: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'resolved',
                  label: Text(DiscBug.chatCloseAsResolved),
                  icon: Icon(Icons.check_rounded, size: 18),
                ),
                ButtonSegment(
                  value: 'closed',
                  label: Text(DiscBug.chatCloseAsClosed),
                  icon: Icon(Icons.archive_outlined, size: 18),
                ),
              ],
              selected: {_status},
              onSelectionChanged: (selected) {
                setState(() => _status = selected.first);
              },
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: DiscBug.chatCloseFinalMessageLabel,
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(CoreStrings.actionCancel),
        ),
        FilledButton(
          onPressed: () {
            final message = _messageController.text.trim();
            Navigator.of(context).pop(
              _CloseDiscussionChoice(
                status: _status,
                reporterMessage: message.isEmpty ? null : message,
              ),
            );
          },
          child: const Text(DiscBug.chatCloseConfirm),
        ),
      ],
    );
  }
}
