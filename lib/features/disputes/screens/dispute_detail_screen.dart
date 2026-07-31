import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/user_role.dart';
import '../../../features/auth/providers/auth_notifier.dart';
import '../../../features/auth/providers/my_roles_provider.dart';
import '../../../services/supabase/disputes/dispute_providers.dart';
import '../../../services/supabase/disputes/dispute_service.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/layout/web_flow_panel.dart';
import '../../../shared/layout/web_flow_scaffold.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';

class DisputeDetailScreen extends ConsumerStatefulWidget {
  const DisputeDetailScreen({
    super.key,
    required this.disputeId,
    this.viewerRole = DisputeSenderRole.client,
  });

  final String disputeId;
  final DisputeSenderRole viewerRole;

  @override
  ConsumerState<DisputeDetailScreen> createState() =>
      _DisputeDetailScreenState();
}

class _DisputeDetailScreenState extends ConsumerState<DisputeDetailScreen> {
  final _composer = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  DisputeSenderRole _resolveSenderRole() {
    final isAdmin =
        ref.read(myRolesProvider).value?.contains(UserRole.admin) ?? false;
    if (isAdmin) return DisputeSenderRole.admin;
    return widget.viewerRole;
  }

  Future<void> _send(BookingDispute dispute) async {
    final service = ref.read(disputeServiceProvider);
    if (service == null || !dispute.canMessage) return;
    final text = _composer.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    try {
      await service.sendMessage(
        disputeId: dispute.id,
        body: text,
        senderRole: _resolveSenderRole(),
      );
      _composer.clear();
      ref.invalidate(disputeMessagesProvider(dispute.id));
    } catch (_) {
      if (mounted) AppSnackBar.error(context, DiscDispute.messageSendErr);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final useWeb = DiscoveryResponsive.of(context).useWebSiteLayout;
    final disputeAsync = ref.watch(disputeByIdProvider(widget.disputeId));
    final messagesAsync =
        ref.watch(disputeMessagesProvider(widget.disputeId));
    final currentUserId = ref.watch(authNotifierProvider).maybeWhen(
          data: (u) => u?.id,
          orElse: () => null,
        );
    final timeFormat = DateFormat('dd/MM HH:mm', 'fr_FR');
    final pad = useWeb
        ? const EdgeInsets.fromLTRB(20, 16, 20, 16)
        : const EdgeInsets.fromLTRB(16, 12, 16, 12);

    final body = disputeAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(20),
        child: DiscoveryListSkeleton(rowCount: 4, rowHeight: 72),
      ),
      error: (_, __) => Center(
        child: DiscoveryEmptyState(
          icon: Icons.cloud_off_outlined,
          title: CoreStrings.networkErrorTitle,
          body: DiscDispute.detailLoadErr,
          iconColor: theme.colorScheme.error,
          actionLabel: DiscList.retry,
          onAction: () {
            ref.invalidate(disputeByIdProvider(widget.disputeId));
            ref.invalidate(disputeMessagesProvider(widget.disputeId));
          },
        ),
      ),
      data: (dispute) {
        if (dispute == null) {
          return Center(
            child: DiscoveryEmptyState(
              icon: Icons.gavel_outlined,
              title: DiscDispute.detailNotFoundTitle,
              body: DiscDispute.detailNotFoundBody,
              iconColor: theme.colorScheme.onSurfaceVariant,
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(disputeByIdProvider(widget.disputeId));
                  ref.invalidate(disputeMessagesProvider(widget.disputeId));
                  await ref.read(disputeByIdProvider(widget.disputeId).future);
                  await ref
                      .read(disputeMessagesProvider(widget.disputeId).future);
                },
                child: ListView(
                  padding: pad,
                  children: [
                    DiscoverySurfaceCard(
                      padding: const EdgeInsets.all(16),
                      includeHorizontalMargin: !useWeb,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  DiscDispute.reasonLabelOf(dispute.reason),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontFamily: AppFonts.display,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              _StatusChip(status: dispute.status),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            DiscDispute.openedByLabel(dispute.openedBy),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (dispute.summary?.trim().isNotEmpty == true) ...[
                            const SizedBox(height: 12),
                            Text(
                              DiscDispute.summarySection,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(dispute.summary!.trim()),
                          ],
                          if (dispute.resolution?.trim().isNotEmpty == true) ...[
                            const SizedBox(height: 12),
                            Text(
                              DiscDispute.resolutionSection,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(dispute.resolution!.trim()),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      DiscDispute.messagesTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    messagesAsync.when(
                      loading: () => const DiscoveryListSkeleton(
                        rowCount: 3,
                        rowHeight: 64,
                      ),
                      error: (_, __) => DiscoveryEmptyState(
                        icon: Icons.cloud_off_outlined,
                        title: CoreStrings.networkErrorTitle,
                        body: DiscDispute.detailLoadErr,
                        actionLabel: DiscList.retry,
                        onAction: () => ref.invalidate(
                          disputeMessagesProvider(widget.disputeId),
                        ),
                      ),
                      data: (messages) {
                        if (messages.isEmpty) {
                          return DiscoverySurfaceCard(
                            padding: const EdgeInsets.all(16),
                            includeHorizontalMargin: !useWeb,
                            child: Text(
                              DiscDispute.messagesEmpty,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        }
                        return Column(
                          children: [
                            for (final m in messages) ...[
                              _MessageBubble(
                                message: m,
                                isMine: m.senderUserId == currentUserId,
                                timeLabel:
                                    timeFormat.format(m.createdAt.toLocal()),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: dispute.canMessage
                    ? Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _composer,
                              enabled: !_sending,
                              minLines: 1,
                              maxLines: 4,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _send(dispute),
                              decoration: const InputDecoration(
                                hintText: DiscDispute.messageHint,
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filled(
                            onPressed: _sending ? null : () => _send(dispute),
                            icon: _sending
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.send_rounded),
                          ),
                        ],
                      )
                    : Text(
                        DiscDispute.messagesClosed,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
          ],
        );
      },
    );

    return WebFlowScaffold(
      appBar: AppBar(title: const Text(DiscDispute.detailTitle)),
      body: useWeb ? WebFlowPanel(child: body) : body,
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        DiscDispute.statusLabelOf(status),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.timeLabel,
  });

  final DisputeMessage message;
  final bool isMine;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = isMine
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainerHighest;
    final fg = isMine
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurface;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.82,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DiscDispute.roleLabelOf(message.senderRole),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: fg.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message.body,
                  style: theme.textTheme.bodyMedium?.copyWith(color: fg),
                ),
                const SizedBox(height: 4),
                Text(
                  timeLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: fg.withValues(alpha: 0.65),
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
