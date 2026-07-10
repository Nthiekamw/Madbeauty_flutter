import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/config/stripe_platform_policy.dart';
import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../core/errors/supabase_service_exception.dart';
import '../../../../../../services/stripe/stripe_connect_providers.dart';
import '../../../../../../services/stripe/stripe_connect_service.dart';
import '../../../../../../services/supabase/prestataire/subscription/prestataire_subscription_providers.dart';
import '../../../../../../../shared/theme/app_colors.dart';
import '../../../../../../../shared/theme/app_fonts.dart';
import '../../../../../../../shared/utils/app_url_launcher.dart';
import '../../../../../../../shared/widgets/app/app_snack_bar.dart';
import '../../../../../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../../../providers/prestataire_deposit_option_provider.dart';
import '../../../../logic/prestataire_subscription_refresh.dart';
import '../../../../models/prestataire_subscription_status.dart';
import '../../../subscription/prestataire_subscription_billing_cards_section.dart';
import '../../../shared/prestataire_section_header.dart';

/// Abonnement (carte) + encaissement (Stripe Connect) dans le profil.
class PrestatairePaymentMethodsSection extends ConsumerStatefulWidget {
  const PrestatairePaymentMethodsSection({
    super.key,
    this.standalone = false,
  });

  /// `true` sur l'écran dédié (sans carte ni en-tête dupliqués).
  final bool standalone;

  @override
  ConsumerState<PrestatairePaymentMethodsSection> createState() =>
      _PrestatairePaymentMethodsSectionState();
}

class _PrestatairePaymentMethodsSectionState
    extends ConsumerState<PrestatairePaymentMethodsSection>
    with WidgetsBindingObserver {
  bool _busySubscription = false;
  bool _busyConnect = false;
  bool _busyDeposit = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncSubscription());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncSubscription();
    }
  }

  void _snack(String message, {AppSnackKind kind = AppSnackKind.info}) {
    AppSnackBar.show(context, message: message, kind: kind);
  }

  Future<void> _syncSubscription({bool showSnack = false}) async {
    if (_busySubscription) return;
    setState(() => _busySubscription = true);
    try {
      await refreshPrestataireSubscription(ref);
      if (showSnack && mounted) {
        _snack(DiscPaymentMethods.statusUpdated, kind: AppSnackKind.success);
      }
    } catch (_) {
      if (showSnack && mounted) {
        _snack(DiscPrestaSub.checkoutErr, kind: AppSnackKind.error);
      }
    } finally {
      if (mounted) setState(() => _busySubscription = false);
    }
  }

  Future<void> _openConnectOnboarding() async {
    final service = ref.read(stripeConnectServiceProvider);
    if (service == null) {
      _snack(DiscStripeConnect.stripeUnavailable, kind: AppSnackKind.error);
      return;
    }

    setState(() => _busyConnect = true);
    try {
      final result = await service.startOnboarding();
      ref.invalidate(prestataireStripeConnectProvider);

      if (result.alreadyComplete) {
        _snack(DiscStripeConnect.alreadyActive);
        return;
      }

      final url = result.url;
      if (url == null || url.isEmpty) {
        _snack(DiscStripeConnect.openErr, kind: AppSnackKind.error);
        return;
      }

      if (!context.mounted) return;
      final opened = await AppUrlLauncher.openInApp(context, url);
      if (!context.mounted) return;
      if (!opened) {
        _snack(DiscPrestaSub.browserErr, kind: AppSnackKind.error);
      }
    } on StripeConnectException catch (e) {
      _snack(e.message, kind: AppSnackKind.error);
    } catch (e, st) {
      debugPrint('Connect onboarding: $e\n$st');
      _snack(DiscStripeConnect.openErr, kind: AppSnackKind.error);
    } finally {
      if (mounted) setState(() => _busyConnect = false);
    }
  }

  Future<void> _refreshConnect() async {
    setState(() => _busyConnect = true);
    try {
      ref.invalidate(prestataireStripeConnectProvider);
      await ref.read(prestataireStripeConnectProvider.future);
      ref.invalidate(currentPrestataireDepositOptionProvider);
      _snack(DiscPaymentMethods.statusUpdated, kind: AppSnackKind.success);
    } on StripeConnectException catch (e) {
      _snack(e.message, kind: AppSnackKind.error);
    } catch (e, st) {
      debugPrint('Connect sync: $e\n$st');
      _snack(DiscStripeConnect.syncErr, kind: AppSnackKind.error);
    } finally {
      if (mounted) setState(() => _busyConnect = false);
    }
  }

  Future<void> _setDepositOption(bool enabled) async {
    final service = ref.read(prestataireDepositServiceProvider);
    if (service == null) {
      _snack(DiscStripeConnect.stripeUnavailable, kind: AppSnackKind.error);
      return;
    }

    setState(() => _busyDeposit = true);
    try {
      await service.setDepositOptionEnabled(enabled);
      ref.invalidate(currentPrestataireDepositOptionProvider);
      _snack(
        enabled
            ? DiscPaymentMethods.depositOptionEnabled
            : DiscPaymentMethods.depositOptionDisabled,
        kind: AppSnackKind.success,
      );
    } on SupabaseServiceException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('connect_required')) {
        _snack(DiscPaymentMethods.depositConnectRequired, kind: AppSnackKind.error);
      } else {
        _snack(e.message, kind: AppSnackKind.error);
      }
    } catch (e, st) {
      debugPrint('Deposit option: $e\n$st');
      _snack(DiscStripeConnect.syncErr, kind: AppSnackKind.error);
    } finally {
      if (mounted) setState(() => _busyDeposit = false);
    }
  }

  Widget _buildDepositOptionTile({
    required ThemeData theme,
    required bool connectReady,
    required bool optionEnabled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Divider(
          height: 24,
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: optionEnabled,
          onChanged: connectReady && !_busyDeposit
              ? (value) => _setDepositOption(value)
              : null,
          title: Text(
            DiscPaymentMethods.depositOptionTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w800,
            ),
          ),
          subtitle: Text(
            connectReady
                ? DiscPaymentMethods.depositOptionHint
                : DiscPaymentMethods.depositConnectRequired,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          secondary: _busyDeposit
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  Icons.account_balance_wallet_outlined,
                  color: connectReady
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
        ),
      ],
    );
  }

  String _connectStatusLabel(StripeConnectStatus? status) {
    if (status == null) return DiscPaymentMethods.payoutNotStarted;
    if (status.canAcceptPayments) return DiscPaymentMethods.payoutActive;
    return switch (status.onboardingStatus) {
      'pending' => DiscPaymentMethods.payoutPending,
      'restricted' => DiscStripeConnect.statusRestricted,
      _ => DiscPaymentMethods.payoutNotStarted,
    };
  }

  Widget _buildSubscriptionBillingSection(
    ThemeData theme,
    PrestataireSubscriptionStatus? status,
  ) {
    if (!widget.standalone &&
        (status == null || (!status.isActive && !status.needsAttention))) {
      return const SizedBox.shrink();
    }

    final pastDue = status?.status == 'past_due';
    final showStatus =
        status != null && (status.isActive || status.needsAttention);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showStatus)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SubscriptionStatusChip(
              label: status.isActive
                  ? DiscPaymentMethods.subscriptionStatusActive
                  : pastDue
                      ? DiscPaymentMethods.subscriptionStatusPastDue
                      : DiscPaymentMethods.subscriptionStatusNone,
              color: status.isActive
                  ? AppColors.success
                  : pastDue
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        const PrestataireSubscriptionBillingCardsSection(),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed:
                _busySubscription ? null : () => _syncSubscription(showSnack: true),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(DiscStripeConnect.ctaRefresh),
          ),
        ),
        Divider(
          height: 24,
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!StripePlatformPolicy.isEnabled) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final subscriptionAsync = ref.watch(prestataireSubscriptionStatusProvider);
    final connectAsync = ref.watch(prestataireStripeConnectProvider);
    final depositOptionAsync = ref.watch(currentPrestataireDepositOptionProvider);

    final body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!widget.standalone) ...[
            PrestataireSectionHeader(
              icon: Icons.payment_rounded,
              title: DiscPaymentMethods.sectionTitle,
              subtitle: DiscPaymentMethods.sectionSubtitle,
              iconColor: theme.colorScheme.primary,
            ),
            const SizedBox(height: 10),
          ],
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    DiscPaymentMethods.distinctionNote,
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          subscriptionAsync.when(
            loading: () => widget.standalone
                ? _buildSubscriptionBillingSection(theme, null)
                : const SizedBox.shrink(),
            error: (_, __) => widget.standalone
                ? _buildSubscriptionBillingSection(theme, null)
                : const SizedBox.shrink(),
            data: (status) => _buildSubscriptionBillingSection(theme, status),
          ),
          connectAsync.when(
            loading: () => const _PaymentMethodSkeleton(),
            error: (_, __) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PaymentMethodBlock(
                  icon: Icons.account_balance_outlined,
                  title: DiscPaymentMethods.payoutTitle,
                  hint: DiscPaymentMethods.payoutHint,
                  status: DiscPaymentMethods.payoutNotStarted,
                  statusColor: theme.colorScheme.onSurfaceVariant,
                  busy: _busyConnect,
                  primaryLabel: DiscPaymentMethods.payoutConfigure,
                  onPrimary: _openConnectOnboarding,
                  secondaryLabel: DiscPaymentMethods.payoutRefresh,
                  onSecondary: _refreshConnect,
                ),
                depositOptionAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => _buildDepositOptionTile(
                    theme: theme,
                    connectReady: false,
                    optionEnabled: false,
                  ),
                  data: (enabled) => _buildDepositOptionTile(
                    theme: theme,
                    connectReady: false,
                    optionEnabled: enabled,
                  ),
                ),
              ],
            ),
            data: (connect) {
              final canPay = connect?.canAcceptPayments ?? false;
              final hasAccount = connect?.accountId != null;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PaymentMethodBlock(
                    icon: Icons.account_balance_outlined,
                    title: DiscPaymentMethods.payoutTitle,
                    hint: DiscPaymentMethods.payoutHint,
                    status: _connectStatusLabel(connect),
                    statusColor:
                        canPay ? AppColors.success : theme.colorScheme.primary,
                    busy: _busyConnect,
                    primaryLabel: canPay
                        ? DiscPaymentMethods.payoutContinue
                        : hasAccount
                            ? DiscPaymentMethods.payoutContinue
                            : DiscPaymentMethods.payoutConfigure,
                    onPrimary: _openConnectOnboarding,
                    secondaryLabel: DiscPaymentMethods.payoutRefresh,
                    onSecondary: _refreshConnect,
                  ),
                  depositOptionAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => _buildDepositOptionTile(
                      theme: theme,
                      connectReady: canPay,
                      optionEnabled: false,
                    ),
                    data: (enabled) => _buildDepositOptionTile(
                      theme: theme,
                      connectReady: canPay,
                      optionEnabled: enabled,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      );

    if (widget.standalone) return body;

    return DiscoverySurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: body,
    );
  }
}

class _PaymentMethodBlock extends StatelessWidget {
  const _PaymentMethodBlock({
    required this.icon,
    required this.title,
    required this.hint,
    required this.status,
    required this.statusColor,
    required this.busy,
    required this.primaryLabel,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
  });

  final IconData icon;
  final String title;
  final String hint;
  final String status;
  final Color statusColor;
  final bool busy;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String secondaryLabel;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hint,
                    maxLines: 3,
                    overflow: TextOverflow.fade,
                    softWrap: true,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Icon(
                          Icons.circle,
                          size: 8,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          status,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (busy)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton(
                onPressed: onPrimary,
                child: Text(
                  primaryLabel,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: onSecondary,
                child: Text(
                  secondaryLabel,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _SubscriptionStatusChip extends StatelessWidget {
  const _SubscriptionStatusChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _PaymentMethodSkeleton extends StatelessWidget {
  const _PaymentMethodSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
