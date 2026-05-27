import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_strings.dart';
import '../../shared/theme/app_fonts.dart';
import 'in_app_notifications_provider.dart';

Future<void> showInAppNotificationsSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (ctx) {
      return Consumer(
        builder: (context, ref, _) {
          final items = ref.watch(inAppNotificationsProvider);
          final unreadCount = ref.watch(unreadInAppNotificationsCountProvider);
          final theme = Theme.of(context);
          final maxH = MediaQuery.sizeOf(context).height * 0.68;
          final notifier = ref.read(inAppNotificationsProvider.notifier);

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 8, 0),
                  child: Text(
                    DiscNotif.sheetTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (items.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 4, 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (unreadCount > 0)
                          TextButton(
                            onPressed: notifier.markAllRead,
                            child: const Text(DiscNotif.markAllRead),
                          ),
                        TextButton(
                          onPressed: notifier.clear,
                          child: const Text(DiscNotif.clearAll),
                        ),
                      ],
                    ),
                  ),
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                    child: DiscoveryNotifPlaceholder(theme: theme),
                  )
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: maxH),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: theme.colorScheme.outlineVariant),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Dismissible(
                          key: ValueKey(item.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) {
                            ref
                                .read(inAppNotificationsProvider.notifier)
                                .dismiss(item.id);
                          },
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            color: theme.colorScheme.errorContainer,
                            child: Icon(
                              Icons.delete_outline_rounded,
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            onTap: () => notifier.markRead(item.id),
                            leading: Icon(
                              item.read
                                  ? Icons.notifications_none_rounded
                                  : Icons.notifications_active_rounded,
                              color: item.read
                                  ? theme.colorScheme.onSurfaceVariant
                                  : theme.colorScheme.primary,
                            ),
                            title: Text(
                              item.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight:
                                    item.read ? FontWeight.w600 : FontWeight.w800,
                              ),
                            ),
                            trailing: _NotificationReadBadge(
                              theme: theme,
                              read: item.read,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  item.body,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    height: 1.35,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  DateFormat(
                                    'd MMMM • HH:mm',
                                    'fr_FR',
                                  ).format(item.createdAt.toLocal()),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _NotificationReadBadge extends StatelessWidget {
  const _NotificationReadBadge({
    required this.theme,
    required this.read,
  });

  final ThemeData theme;
  final bool read;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: read
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        read ? DiscNotif.readLabel : DiscNotif.unreadLabel,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: read
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class DiscoveryNotifPlaceholder extends StatelessWidget {
  const DiscoveryNotifPlaceholder({super.key, required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.notifications_off_outlined,
          size: 48,
          color: theme.colorScheme.outline,
        ),
        const SizedBox(height: 16),
        Text(
          DiscNotif.emptyTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontFamily: AppFonts.display,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          DiscNotif.emptyBody,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

/// Cloche avec pastille (accueil, dashboard prestataire).
class NotificationBellButton extends StatelessWidget {
  const NotificationBellButton({
    super.key,
    required this.onPressed,
    this.unreadCount = 0,
    this.tooltip,
    this.compact = false,
  });

  final VoidCallback onPressed;
  final int unreadCount;
  final String? tooltip;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final padding = compact ? 8.0 : 10.0;
    final iconSize = compact ? 20.0 : 22.0;

    return Material(
      color: theme.colorScheme.surface.withValues(
        alpha: isDark ? 0.35 : 0.65,
      ),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Tooltip(
          message: tooltip ?? DiscHome.notificationsTooltip,
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Badge(
              isLabelVisible: unreadCount > 0,
              label: Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
              ),
              child: Icon(
                Icons.notifications_outlined,
                size: iconSize,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
