import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../providers/admin_user_support_provider.dart';
import '../widgets/admin_discovery_widgets.dart';
import '../widgets/admin_screen_scaffold.dart';

class AdminUserSupportScreen extends ConsumerWidget {
  const AdminUserSupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final threadsAsync = ref.watch(adminUserSupportThreadsProvider);
    final dateFormat = DateFormat('d MMM · HH:mm', 'fr_FR');
    final theme = Theme.of(context);

    return AdminScreenScaffold(
      title: DiscSupport.adminHubTitle,
      body: threadsAsync.when(
        data: (threads) {
          if (threads.isEmpty) {
            return DiscoveryEmptyState(
              icon: Icons.support_agent_rounded,
              title: DiscSupport.adminEmptyTitle,
              body: DiscSupport.adminEmptyBody,
              iconColor: AppColors.adminAccentMid,
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(adminUserSupportThreadsProvider);
              await ref.read(adminUserSupportThreadsProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: threads.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final thread = threads[index];
                final preview = thread.lastMessage?.trim();
                final previewLabel = preview != null && preview.isNotEmpty
                    ? preview
                    : DiscSupport.adminNoPreview;
                final when = thread.lastMessageAt ?? thread.updatedAt;

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => context.pushUserSupportChatThread(
                      thread.threadId,
                    ),
                    child: AdminDiscoveryCard(
                      child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.adminBg12,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.adminBorder30),
                        ),
                        child: const Icon(
                          Icons.support_agent_rounded,
                          color: AppColors.adminAccentMid,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    thread.userLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontFamily: AppFonts.display,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                if (thread.unreadCount > 0)
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.adminAccentMid,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      '${thread.unreadCount}',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              previewLabel,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              dateFormat.format(when.toLocal()),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.adminAccentMid,
                      ),
                    ],
                  ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const DiscoveryListSkeleton(
          rowCount: 6,
          rowHeight: 88,
          padding: EdgeInsets.all(16),
        ),
        error: (_, __) => Center(
          child: Text(
            DiscSupport.loadErr,
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
      ),
    );
  }
}
