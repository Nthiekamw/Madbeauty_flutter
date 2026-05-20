import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/providers/offline_providers.dart';
import '../../core/providers/offline_queue_providers.dart';
import '../../services/offline/offline_sync_service.dart';

/// Enveloppe les shells connectés : bannières hors ligne / file d’attente + contenu.
class OfflineShell extends ConsumerWidget {
  const OfflineShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<OfflineSyncResult?>(lastOfflineSyncResultProvider, (
      _,
      next,
    ) {
      if (next == null) return;
      final messenger = ScaffoldMessenger.of(context);
      if (next.syncedCount > 0) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(ShellStrings.offlineSyncDone(next.syncedCount)),
          ),
        );
      }
      if (next.failedCount > 0) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(ShellStrings.offlineSyncPartialFail),
          ),
        );
      }
      ref.read(lastOfflineSyncResultProvider.notifier).value = null;
    });

    ref.watch(offlineActionQueueProvider);

    final offline = ref.watch(offlineModeProvider);
    final pendingCount = ref.watch(offlineQueuePendingCountProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (offline) const _OfflineBanner(),
        if (pendingCount > 0)
          _PendingSyncBanner(count: pendingCount, offline: offline),
        Expanded(child: child),
      ],
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.errorContainer.withValues(alpha: 0.92),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(
                Icons.cloud_off_outlined,
                color: theme.colorScheme.onErrorContainer,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  ShellStrings.offlineModeBanner,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingSyncBanner extends StatelessWidget {
  const _PendingSyncBanner({required this.count, required this.offline});

  final int count;
  final bool offline;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Material(
      color: offline
          ? cs.secondaryContainer.withValues(alpha: 0.95)
          : cs.primaryContainer.withValues(alpha: 0.95),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(
                offline ? Icons.schedule_send_outlined : Icons.sync,
                size: 20,
                color: offline
                    ? cs.onSecondaryContainer
                    : cs.onPrimaryContainer,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  ShellStrings.offlinePendingBanner(count),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: offline
                        ? cs.onSecondaryContainer
                        : cs.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
