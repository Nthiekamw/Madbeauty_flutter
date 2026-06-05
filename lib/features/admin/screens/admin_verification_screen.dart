import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/app/app_snack_bar.dart';
import '../models/admin_verification_request.dart';
import '../providers/admin_verification_provider.dart';

class AdminVerificationScreen extends ConsumerStatefulWidget {
  const AdminVerificationScreen({super.key});

  @override
  ConsumerState<AdminVerificationScreen> createState() =>
      _AdminVerificationScreenState();
}

class _AdminVerificationScreenState extends ConsumerState<AdminVerificationScreen> {
  AdminVerificationFilter _filter = AdminVerificationFilter.pending;
  final Set<String> _busyIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final requestsAsync = ref.watch(adminVerificationRequestsProvider(_filter));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Demandes de vérification'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SegmentedButton<AdminVerificationFilter>(
              segments: const [
                ButtonSegment(
                  value: AdminVerificationFilter.pending,
                  label: Text('En attente'),
                ),
                ButtonSegment(
                  value: AdminVerificationFilter.all,
                  label: Text('Tous'),
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
            child: requestsAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Center(
                    child: Text('Aucune demande pour le moment.'),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(adminVerificationRequestsProvider(_filter));
                    await ref.read(
                      adminVerificationRequestsProvider(_filter).future,
                    );
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _RequestCard(
                        item: item,
                        busy: _busyIds.contains(item.prestataireId),
                        onApprove: () => _approve(item),
                        onRevoke: () => _revoke(item),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    err.toString(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _approve(AdminVerificationRequest item) async {
    final service = ref.read(adminVerificationServiceProvider);
    if (service == null) return;
    setState(() => _busyIds.add(item.prestataireId));
    try {
      await service.approve(prestataireId: item.prestataireId);
      ref.invalidate(adminVerificationRequestsProvider(_filter));
      if (mounted) {
        AppSnackBar.show(
          context,
          message: 'Vérification validée.',
          kind: AppSnackKind.success,
        );
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: 'Impossible de valider pour le moment.',
          kind: AppSnackKind.error,
        );
      }
    } finally {
      if (mounted) setState(() => _busyIds.remove(item.prestataireId));
    }
  }

  Future<void> _revoke(AdminVerificationRequest item) async {
    final service = ref.read(adminVerificationServiceProvider);
    if (service == null) return;
    setState(() => _busyIds.add(item.prestataireId));
    try {
      await service.revoke(prestataireId: item.prestataireId);
      ref.invalidate(adminVerificationRequestsProvider(_filter));
      if (mounted) {
        AppSnackBar.show(
          context,
          message: 'Vérification retirée.',
          kind: AppSnackKind.success,
        );
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: 'Impossible de retirer pour le moment.',
          kind: AppSnackKind.error,
        );
      }
    } finally {
      if (mounted) setState(() => _busyIds.remove(item.prestataireId));
    }
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.item,
    required this.busy,
    required this.onApprove,
    required this.onRevoke,
  });

  final AdminVerificationRequest item;
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onRevoke;

  @override
  Widget build(BuildContext context) {
    final verified = item.isVerified;
    final salon = item.nomSalon?.trim();
    final ville = item.ville?.trim();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.displayName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (salon != null && salon.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text('Salon: $salon'),
            ],
            if (ville != null && ville.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text('Ville: $ville'),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(verified ? 'Vérifié' : 'Non vérifié'),
                ),
                const Spacer(),
                if (busy)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: busy ? null : onApprove,
                  child: const Text('Valider'),
                ),
                OutlinedButton(
                  onPressed: busy ? null : onRevoke,
                  child: const Text('Retirer la vérification'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

