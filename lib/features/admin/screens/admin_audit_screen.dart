import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../providers/admin_audit_provider.dart';
import '../widgets/admin_screen_scaffold.dart';

class AdminAuditScreen extends ConsumerWidget {
  const AdminAuditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auditAsync = ref.watch(adminAuditLogProvider);
    final verificationAsync = ref.watch(adminVerificationEventsProvider);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'fr_FR');

    return AdminScreenScaffold(
      title: DiscProfile.actionAdminAudit,
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const AdminScreenIntroBanner(
              icon: Icons.history,
              title: DiscProfile.adminAuditIntroTitle,
              body: DiscProfile.adminAuditIntroBody,
            ),
            const TabBar(
              tabs: [
                Tab(text: DiscProfile.adminAuditTabGeneral),
                Tab(text: DiscProfile.adminAuditTabVerifications),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  auditAsync.when(
                    data: (items) => _AuditList(
                      empty: DiscProfile.adminAuditEmpty,
                      entries: items
                          .map(
                            (e) => _AuditLine(
                              title: e.action,
                              subtitle:
                                  '${e.entityType} · ${e.entityId}\n${e.actorDisplayName ?? e.actorUserId}',
                              date: dateFormat.format(e.createdAt),
                            ),
                          )
                          .toList(),
                      onRefresh: () async {
                        ref.invalidate(adminAuditLogProvider);
                        await ref.read(adminAuditLogProvider.future);
                      },
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('$e')),
                  ),
                  verificationAsync.when(
                    data: (items) => _AuditList(
                      empty: DiscProfile.adminAuditVerificationsEmpty,
                      entries: items
                          .map(
                            (e) => _AuditLine(
                              title: '${e.action} · ${e.nomSalon ?? ''}',
                              subtitle: e.actorDisplayName ?? e.actorUserId,
                              date: dateFormat.format(e.createdAt),
                              note: e.note,
                            ),
                          )
                          .toList(),
                      onRefresh: () async {
                        ref.invalidate(adminVerificationEventsProvider);
                        await ref.read(adminVerificationEventsProvider.future);
                      },
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('$e')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuditLine {
  const _AuditLine({
    required this.title,
    required this.subtitle,
    required this.date,
    this.note,
  });

  final String title;
  final String subtitle;
  final String date;
  final String? note;
}

class _AuditList extends StatelessWidget {
  const _AuditList({
    required this.empty,
    required this.entries,
    required this.onRefresh,
  });

  final String empty;
  final List<_AuditLine> entries;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(child: Text(empty));
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: entries.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final e = entries[index];
          return Card(
            child: ListTile(
              title: Text(e.title),
              subtitle: Text(
                '${e.subtitle}\n${e.date}${e.note != null ? '\n${e.note}' : ''}',
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
