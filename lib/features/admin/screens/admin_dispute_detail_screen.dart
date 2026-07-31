import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../../../services/supabase/disputes/dispute_providers.dart';
import '../../../services/supabase/disputes/dispute_service.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../widgets/admin_screen_scaffold.dart';

class AdminDisputeDetailScreen extends ConsumerStatefulWidget {
  const AdminDisputeDetailScreen({super.key, required this.disputeId});

  final String disputeId;

  @override
  ConsumerState<AdminDisputeDetailScreen> createState() =>
      _AdminDisputeDetailScreenState();
}

class _AdminDisputeDetailScreenState
    extends ConsumerState<AdminDisputeDetailScreen> {
  final _notes = TextEditingController();
  final _resolution = TextEditingController();
  final _composer = TextEditingController();
  bool _busy = false;
  bool _sending = false;
  final _dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'fr_FR');

  @override
  void dispose() {
    _notes.dispose();
    _resolution.dispose();
    _composer.dispose();
    super.dispose();
  }

  Future<void> _resolve(DisputeStatus status) async {
    final service = ref.read(disputeServiceProvider);
    if (service == null || _busy) return;
    setState(() => _busy = true);
    try {
      await service.adminResolve(
        disputeId: widget.disputeId,
        status: status,
        adminNotes: _notes.text,
        resolution: _resolution.text,
      );
      ref.invalidate(disputeByIdProvider(widget.disputeId));
      ref.invalidate(adminDisputesProvider(AdminDisputeFilter.open));
      ref.invalidate(adminDisputesProvider(AdminDisputeFilter.all));
      if (mounted) {
        AppSnackBar.success(context, DiscDispute.adminUpdated);
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.error(context, DiscDispute.adminUpdateErr);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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
        senderRole: DisputeSenderRole.admin,
      );
      _composer.clear();
      ref.invalidate(disputeMessagesProvider(dispute.id));
    } catch (_) {
      if (mounted) {
        AppSnackBar.error(context, DiscDispute.messageSendErr);
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disputeAsync = ref.watch(disputeByIdProvider(widget.disputeId));
    final messagesAsync =
        ref.watch(disputeMessagesProvider(widget.disputeId));

    return AdminScreenScaffold(
      title: DiscDispute.adminDetailTitle,
      body: disputeAsync.when(
        loading: () =>
            const DiscoveryListSkeleton(rowCount: 5, rowHeight: 80),
        error: (_, __) => DiscoveryEmptyState(
          icon: Icons.cloud_off_outlined,
          title: CoreStrings.networkErrorTitle,
          body: DiscDispute.detailLoadErr,
          iconColor: theme.colorScheme.error,
          actionLabel: DiscList.retry,
          onAction: () =>
              ref.invalidate(disputeByIdProvider(widget.disputeId)),
        ),
        data: (dispute) {
          if (dispute == null) {
            return const DiscoveryEmptyState(
              icon: Icons.gavel_outlined,
              title: DiscDispute.detailNotFoundTitle,
              body: DiscDispute.detailNotFoundBody,
            );
          }

          final terminal = dispute.statusEnum.isTerminal;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              DiscoverySurfaceCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DiscDispute.reasonLabelOf(dispute.reason),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontFamily: AppFonts.display,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      [
                        DiscDispute.statusLabelOf(dispute.status),
                        DiscDispute.openedByLabel(dispute.openedBy),
                        _dateFormat.format(dispute.createdAt.toLocal()),
                      ].join(' · '),
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
                  rowCount: 2,
                  rowHeight: 56,
                ),
                error: (_, __) => Text(
                  DiscDispute.detailLoadErr,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                data: (messages) {
                  if (messages.isEmpty) {
                    return Text(
                      DiscDispute.messagesEmpty,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    );
                  }
                  return Column(
                    children: [
                      for (final m in messages)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: DiscoverySurfaceCard(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${DiscDispute.roleLabelOf(m.senderRole)} · '
                                  '${_dateFormat.format(m.createdAt.toLocal())}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(m.body),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              if (dispute.canMessage) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _composer,
                        enabled: !_sending,
                        minLines: 1,
                        maxLines: 3,
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
                      icon: const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ],
              if (!terminal) ...[
                const SizedBox(height: 20),
                TextField(
                  controller: _notes,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: DiscDispute.adminNotesLabel,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _resolution,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: DiscDispute.adminResolutionLabel,
                    hintText: DiscDispute.adminResolutionHint,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (dispute.status == 'open')
                      OutlinedButton(
                        onPressed: _busy
                            ? null
                            : () => _resolve(DisputeStatus.underReview),
                        child: const Text(DiscDispute.adminActionReview),
                      ),
                    FilledButton.tonal(
                      onPressed: _busy
                          ? null
                          : () =>
                              _resolve(DisputeStatus.resolvedFavorClient),
                      child: const Text(DiscDispute.adminActionFavorClient),
                    ),
                    FilledButton.tonal(
                      onPressed: _busy
                          ? null
                          : () =>
                              _resolve(DisputeStatus.resolvedFavorPresta),
                      child: const Text(DiscDispute.adminActionFavorPresta),
                    ),
                    OutlinedButton(
                      onPressed: _busy
                          ? null
                          : () => _resolve(DisputeStatus.closed),
                      child: const Text(DiscDispute.adminActionClose),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
