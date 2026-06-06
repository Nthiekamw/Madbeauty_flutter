import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../models/admin_user_summary.dart';
import '../providers/admin_users_provider.dart';
import '../widgets/admin_screen_scaffold.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  final Set<String> _busyIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    setState(() => _query = _searchController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUsersSearchProvider(_query));

    return AdminScreenScaffold(
      title: DiscProfile.actionAdminUsers,
      body: Column(
        children: [
          const AdminScreenIntroBanner(
            icon: Icons.people_outline,
            title: DiscProfile.adminUsersIntroTitle,
            body: DiscProfile.adminUsersIntroBody,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: DiscProfile.adminUsersSearchHint,
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _search,
                  child: const Text(DiscProfile.adminUsersSearchAction),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: usersAsync.when(
              data: (users) {
                if (users.isEmpty) {
                  return const Center(child: Text(DiscProfile.adminUsersEmpty));
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(adminUsersSearchProvider(_query));
                    await ref.read(adminUsersSearchProvider(_query).future);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: users.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) => _UserCard(
                      user: users[index],
                      busy: _busyIds.contains(users[index].userId),
                      onBan: () => _ban(users[index]),
                      onUnban: () => _unban(users[index]),
                      onAddRole: (role) => _addRole(users[index], role),
                      onRemoveRole: (role) => _removeRole(users[index], role),
                    ),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _run(String userId, Future<void> Function() action) async {
    setState(() => _busyIds.add(userId));
    try {
      await action();
      ref.invalidate(adminUsersSearchProvider(_query));
      if (mounted) AppSnackBar.show(context, message: DiscProfile.adminActionOk);
    } catch (_) {
      if (mounted) {
        AppSnackBar.error(context, DiscProfile.adminActionErr);
      }
    } finally {
      if (mounted) setState(() => _busyIds.remove(userId));
    }
  }

  Future<void> _ban(AdminUserSummary user) async {
    final reason = await _promptBanReason(user);
    if (reason == null || !mounted) return;
    final service = ref.read(adminUsersServiceProvider);
    if (service == null) return;
    await _run(
      user.userId,
      () => service.banUser(userId: user.userId, reason: reason),
    );
  }

  Future<String?> _promptBanReason(AdminUserSummary user) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(DiscProfile.adminUsersBanDialogTitle(user.displayName)),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: DiscProfile.adminUsersBanReasonLabel,
              hintText: DiscProfile.adminUsersBanReasonHint,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return DiscProfile.adminUsersBanReasonRequired;
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(DiscProfile.adminUsersBanCancel),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() != true) return;
              Navigator.of(ctx).pop(controller.text.trim());
            },
            child: const Text(DiscProfile.adminUsersBanConfirm),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _unban(AdminUserSummary user) async {
    final service = ref.read(adminUsersServiceProvider);
    if (service == null) return;
    await _run(user.userId, () => service.unbanUser(userId: user.userId));
  }

  Future<void> _addRole(AdminUserSummary user, String role) async {
    final service = ref.read(adminUsersServiceProvider);
    if (service == null) return;
    await _run(
      user.userId,
      () => service.setUserRole(userId: user.userId, role: role),
    );
  }

  Future<void> _removeRole(AdminUserSummary user, String role) async {
    final service = ref.read(adminUsersServiceProvider);
    if (service == null) return;
    await _run(
      user.userId,
      () => service.removeUserRole(userId: user.userId, role: role),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.busy,
    required this.onBan,
    required this.onUnban,
    required this.onAddRole,
    required this.onRemoveRole,
  });

  final AdminUserSummary user;
  final bool busy;
  final VoidCallback onBan;
  final VoidCallback onUnban;
  final ValueChanged<String> onAddRole;
  final ValueChanged<String> onRemoveRole;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.displayName, style: Theme.of(context).textTheme.titleMedium),
            Text(user.email, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final role in user.roles)
                  InputChip(
                    label: Text(role),
                    onDeleted: busy ? null : () => onRemoveRole(role),
                  ),
                if (user.isBanned) ...[
                  const Chip(
                    label: Text(DiscProfile.adminUsersBannedBadge),
                    backgroundColor: Colors.redAccent,
                  ),
                  if (user.banReason != null && user.banReason!.trim().isNotEmpty)
                    Chip(label: Text(user.banReason!.trim())),
                ],
              ],
            ),
            const SizedBox(height: 8),
            if (busy)
              const LinearProgressIndicator()
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (!user.roles.contains('client'))
                    OutlinedButton(
                      onPressed: () => onAddRole('client'),
                      child: const Text('+ Client'),
                    ),
                  if (!user.roles.contains('prestataire'))
                    OutlinedButton(
                      onPressed: () => onAddRole('prestataire'),
                      child: const Text('+ Prestataire'),
                    ),
                  if (!user.roles.contains('admin'))
                    OutlinedButton(
                      onPressed: () => onAddRole('admin'),
                      child: const Text('+ Admin'),
                    ),
                  if (user.isBanned)
                    FilledButton(
                      onPressed: onUnban,
                      child: const Text(DiscProfile.adminUsersUnban),
                    )
                  else
                    OutlinedButton(
                      onPressed: onBan,
                      child: const Text(DiscProfile.adminUsersBan),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
