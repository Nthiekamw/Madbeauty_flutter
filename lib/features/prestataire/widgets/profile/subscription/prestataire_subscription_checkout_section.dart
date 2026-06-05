import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/config/prestataire_subscription_config.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../services/stripe/stripe_prestataire_subscription_service.dart';
import '../../../../../services/stripe/stripe_service.dart';
import '../../../../../services/stripe/stripe_subscription_providers.dart';
import '../../../../../shared/utils/app_url_launcher.dart';
import '../../../../../shared/widgets/app/app_snack_bar.dart';
import '../../../models/prestataire_subscription_status.dart';
import '../../../providers/prestataire_profile_form_provider.dart';
import '../../../providers/prestataire_subscription_provider.dart';
import 'prestataire_payout_setup_hint.dart';

/// Boutons d'abonnement / portail Stripe pour le palier courant.
class PrestataireSubscriptionCheckoutSection extends ConsumerStatefulWidget {
  const PrestataireSubscriptionCheckoutSection({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  ConsumerState<PrestataireSubscriptionCheckoutSection> createState() =>
      _PrestataireSubscriptionCheckoutSectionState();
}

class _PrestataireSubscriptionCheckoutSectionState
    extends ConsumerState<PrestataireSubscriptionCheckoutSection> {
  bool _busy = false;
  String _selectedInterval = 'month';

  void _snack(String message, {bool error = false}) {
    AppSnackBar.show(
      context,
      message: message,
      kind: error ? AppSnackKind.error : AppSnackKind.info,
    );
  }

  Future<void> _refreshStatus() async {
    ref.invalidate(prestataireSubscriptionStatusProvider);
    final service = ref.read(stripePrestaSubscriptionServiceProvider);
    if (service == null) return;
    try {
      await service.syncFromStripe();
      ref.invalidate(prestataireSubscriptionStatusProvider);
    } catch (_) {}
  }

  Future<bool> _ensureProfileForBilling() async {
    final formService = ref.read(prestataireProfileFormServiceProvider);
    if (formService == null) {
      _snack(DiscPrestaSub.payUnavailable, error: true);
      return false;
    }
    try {
      await formService.ensureProfileForBilling();
      ref.invalidate(prestataireProfileFormProvider);
      ref.invalidate(prestatairePublishedServiceCountProvider);
      ref.invalidate(prestataireSubscriptionStatusProvider);
      return true;
    } catch (e) {
      debugPrint('ensureProfileForBilling: $e');
      _snack(DiscPrestaSub.profileRequired, error: true);
      return false;
    }
  }

  Future<void> _subscribe(String tier) async {
    final stripeService = ref.read(stripePrestaSubscriptionServiceProvider);
    if (stripeService == null) {
      _snack(DiscPrestaSub.payUnavailable, error: true);
      return;
    }

    setState(() => _busy = true);
    try {
      if (!await _ensureProfileForBilling()) return;

      final result = await stripeService.createCheckout(
        tier: tier,
        interval: _selectedInterval,
      );
      if (!context.mounted) return;
      final opened = await AppUrlLauncher.openInApp(context, result.url);
      if (!context.mounted) return;
      if (!opened) _snack(DiscPrestaSub.browserErr, error: true);
    } on StripePrestaSubscriptionException catch (e) {
      if (e.code == 'subscription_already_active') {
        await _openPortal();
      } else {
        _snack(e.message, error: true);
      }
    } catch (e) {
      debugPrint('subscription checkout: $e');
      _snack(DiscPrestaSub.checkoutErr, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openPortal() async {
    final stripeService = ref.read(stripePrestaSubscriptionServiceProvider);
    if (stripeService == null) {
      _snack(DiscPrestaSub.payUnavailable, error: true);
      return;
    }

    setState(() => _busy = true);
    try {
      if (!await _ensureProfileForBilling()) return;

      final url = await stripeService.createBillingPortalUrl();
      if (!context.mounted) return;
      final opened = await AppUrlLauncher.openInApp(context, url);
      if (!context.mounted) return;
      if (!opened) _snack(DiscPrestaSub.browserErr, error: true);
    } on StripePrestaSubscriptionException catch (e) {
      _snack(e.message, error: true);
    } catch (e) {
      debugPrint('billing portal: $e');
      _snack(DiscPrestaSub.portalErr, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _statusLabel(PrestataireSubscriptionStatus status) {
    if (status.isActive) return DiscPrestaSub.statusActive;
    return switch (status.status) {
      'past_due' => DiscPrestaSub.statusPastDue,
      'canceled' => DiscPrestaSub.statusCanceled,
      'incomplete' => DiscPrestaSub.statusIncomplete,
      _ => DiscPrestaSub.statusNone,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (!StripeService.isConfigured) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final statusAsync = ref.watch(prestataireSubscriptionStatusProvider);
    final serviceCountAsync = ref.watch(
      prestatairePublishedServiceCountProvider,
    );

    return serviceCountAsync.when(
      loading: () => const SizedBox(
        height: 40,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (serviceCount) {
        final tier = PrestataireSubscriptionConfig.tierForServiceCount(
          serviceCount,
        );

        return statusAsync.when(
          loading: () => const SizedBox(
            height: 40,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (status) {
            if (status.isActive) {
              return _ActiveBanner(
                theme: theme,
                status: status,
                busy: _busy,
                onManage: _openPortal,
                onRefresh: _refreshStatus,
                statusLabel: _statusLabel(status),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (status.needsAttention) ...[
                  _AttentionBanner(theme: theme, status: status),
                  const SizedBox(height: 10),
                ],
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'month',
                      label: Text(DiscPrestaSub.monthly),
                    ),
                    ButtonSegment(
                      value: 'year',
                      label: Text(DiscPrestaSub.yearly),
                    ),
                  ],
                  selected: {_selectedInterval},
                  onSelectionChanged: _busy
                      ? null
                      : (s) => setState(() => _selectedInterval = s.first),
                ),
                SizedBox(height: widget.compact ? 10 : 14),
                FilledButton.icon(
                  onPressed: _busy ? null : () => _subscribe(tier.id),
                  icon: _busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.payment_rounded),
                  label: Text(
                    _selectedInterval == 'year'
                        ? DiscPrestaSub.subscribeYearly
                        : DiscPrestaSub.subscribeMonthly,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _busy ? null : _refreshStatus,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text(DiscPrestaSub.refreshStatus),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ActiveBanner extends StatelessWidget {
  const _ActiveBanner({
    required this.theme,
    required this.status,
    required this.busy,
    required this.onManage,
    required this.onRefresh,
    required this.statusLabel,
  });

  final ThemeData theme;
  final PrestataireSubscriptionStatus status;
  final bool busy;
  final VoidCallback onManage;
  final VoidCallback onRefresh;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    final period = status.periodEnd;
    final periodText = period != null
        ? DiscPrestaSub.renewsOn.replaceFirst(
            '%s',
            MaterialLocalizations.of(context).formatShortDate(period.toLocal()),
          )
        : null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  statusLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (periodText != null) ...[
            const SizedBox(height: 6),
            Text(
              periodText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: busy ? null : onManage,
            icon: const Icon(Icons.manage_accounts_outlined, size: 18),
            label: const Text(DiscPrestaSub.manageBilling),
          ),
          TextButton(
            onPressed: busy ? null : onRefresh,
            child: const Text(DiscPrestaSub.refreshStatus),
          ),
          const PrestatairePayoutSetupHint(compact: true),
        ],
      ),
    );
  }
}

class _AttentionBanner extends StatelessWidget {
  const _AttentionBanner({required this.theme, required this.status});

  final ThemeData theme;
  final PrestataireSubscriptionStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.status == 'past_due'
            ? DiscPrestaSub.statusPastDue
            : DiscPrestaSub.statusIncomplete,
        style: theme.textTheme.bodySmall,
      ),
    );
  }
}
