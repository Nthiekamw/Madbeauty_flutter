import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../models/admin_verification_request.dart';
import '../providers/admin_pending_counts_provider.dart';
import '../providers/admin_verification_provider.dart';
import '../widgets/admin_revoke_verification_dialog.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../widgets/admin_discovery_widgets.dart';
import '../widgets/admin_screen_scaffold.dart';
import '../../../core/constants/app_strings.dart';

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

    return AdminScreenScaffold(
      title: DiscProfile.actionAdminVerifications,
      body: Column(
        children: [
          const AdminScreenIntroBanner(
            icon: Icons.verified_user_outlined,
            title: DiscProfile.adminVerificationsIntroTitle,
            body: DiscProfile.adminVerificationsIntroBody,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: AdminFilterSegment<AdminVerificationFilter>(
              segments: const [
                ButtonSegment(
                  value: AdminVerificationFilter.pending,
                  label: Text(DiscProfile.adminVerificationFilterPending),
                ),
                ButtonSegment(
                  value: AdminVerificationFilter.all,
                  label: Text(DiscProfile.adminVerificationFilterAll),
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
                  return const AdminListEmptyState(
                    icon: Icons.verified_user_outlined,
                    title: DiscProfile.adminVerificationEmpty,
                    body: DiscProfile.adminVerificationsIntroBody,
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
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
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
              loading: () => const DiscoveryListSkeleton(rowCount: 5),
              error: (_, __) => DiscoveryEmptyState(
                icon: Icons.cloud_off_outlined,
                title: CoreStrings.networkErrorTitle,
                body: CoreStrings.networkErrorBody,
                iconColor: theme.colorScheme.error,
                actionLabel: DiscList.retry,
                onAction: () =>
                    ref.invalidate(adminVerificationRequestsProvider(_filter)),
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
      ref.invalidate(adminPendingVerificationsCountProvider);
      if (mounted) {
        AppSnackBar.show(
          context,
          message: DiscProfile.adminVerificationApproveOk,
          kind: AppSnackKind.success,
        );
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: DiscProfile.adminVerificationApproveErr,
          kind: AppSnackKind.error,
        );
      }
    } finally {
      if (mounted) setState(() => _busyIds.remove(item.prestataireId));
    }
  }

  Future<void> _revoke(AdminVerificationRequest item) async {
    final note = await showAdminRevokeVerificationDialog(context);
    if (!mounted || note == null) return;

    final service = ref.read(adminVerificationServiceProvider);
    if (service == null) return;
    setState(() => _busyIds.add(item.prestataireId));
    try {
      await service.revoke(prestataireId: item.prestataireId, note: note);
      ref.invalidate(adminVerificationRequestsProvider(_filter));
      ref.invalidate(adminPendingVerificationsCountProvider);
      if (mounted) {
        AppSnackBar.show(
          context,
          message: DiscProfile.adminVerificationRevokeOk,
          kind: AppSnackKind.success,
        );
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: DiscProfile.adminVerificationRevokeErr,
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
    final theme = Theme.of(context);
    final verified = item.isVerified;
    final salon = item.nomSalon?.trim();
    final ville = item.ville?.trim();

    return AdminDiscoveryCard(
      accentColor: verified
          ? theme.colorScheme.tertiary
          : AppColors.adminAccentMid,
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
                  Icons.verified_user_outlined,
                  color: AppColors.adminAccentMid,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.displayName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (busy)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                AdminStatusChip(
                  label: verified
                      ? DiscProfile.adminVerificationChipVerified
                      : DiscProfile.adminVerificationChipNotVerified,
                  tone: verified
                      ? AdminStatusTone.success
                      : AdminStatusTone.pending,
                ),
            ],
          ),
          if (salon != null && salon.isNotEmpty)
            AdminInfoRow(
              icon: Icons.storefront_outlined,
              label: 'Salon',
              value: salon,
              dense: true,
            ),
          if (ville != null && ville.isNotEmpty)
            AdminInfoRow(
              icon: Icons.location_on_outlined,
              label: 'Ville',
              value: ville,
              dense: true,
            ),
          if (item.verificationRequestedAt != null)
            AdminInfoRow(
              icon: Icons.schedule_rounded,
              label: 'Demande',
              value: DiscProfile.adminVerificationRequestedAt(
                item.verificationRequestedAt!,
              ),
              dense: true,
            ),
          AdminActionRow(
            children: [
              FilledButton.icon(
                onPressed: busy || verified ? null : onApprove,
                icon: const Icon(Icons.check_rounded, size: 18),
                label: const Text(DiscProfile.adminVerificationApproveCta),
              ),
              OutlinedButton.icon(
                onPressed: busy || !verified ? null : onRevoke,
                icon: const Icon(Icons.block_rounded, size: 18),
                label: const Text(DiscProfile.adminVerificationRevokeCta),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

