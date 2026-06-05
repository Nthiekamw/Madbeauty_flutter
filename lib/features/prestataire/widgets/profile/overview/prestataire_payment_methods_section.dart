import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../services/stripe/stripe_connect_providers.dart';
import '../../../../../services/stripe/stripe_connect_service.dart';
import '../../../../../services/stripe/stripe_prestataire_subscription_service.dart';
import '../../../../../services/stripe/stripe_service.dart';
import '../../../../../services/stripe/stripe_subscription_providers.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_fonts.dart';
import '../../../../../shared/utils/app_url_launcher.dart';
import '../../../../../shared/widgets/app/app_snack_bar.dart';
import '../../../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../../models/prestataire_subscription_status.dart';
import '../../../providers/prestataire_profile_form_provider.dart';
import '../../shared/prestataire_section_header.dart';

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
    extends ConsumerState<PrestatairePaymentMethodsSection> {
  bool _busySubscription = false;
  bool _busyConnect = false;

  void _snack(String message, {AppSnackKind kind = AppSnackKind.info}) {
    AppSnackBar.show(context, message: message, kind: kind);
  }

  Future<bool> _ensureProfileForBilling() async {
    final formService = ref.read(prestataireProfileFormServiceProvider);
    if (formService == null) {
      _snack(DiscPrestaSub.payUnavailable, kind: AppSnackKind.error);
      return false;
    }
    try {
      await formService.ensureProfileForBilling();
      ref.invalidate(prestataireProfileFormProvider);
      ref.invalidate(prestataireSubscriptionStatusProvider);
      return true;
    } catch (_) {
      _snack(DiscPrestaSub.profileRequired, kind: AppSnackKind.error);
      return false;
    }
  }

  Future<void> _openBillingPortal() async {
    final service = ref.read(stripePrestaSubscriptionServiceProvider);
    if (service == null) {
      _snack(DiscPrestaSub.payUnavailable, kind: AppSnackKind.error);
      return;
    }

    setState(() => _busySubscription = true);
    try {
      if (!await _ensureProfileForBilling()) return;
      final url = await service.createBillingPortalUrl();
      if (!context.mounted) return;
      final opened = await AppUrlLauncher.openInApp(context, url);
      if (!context.mounted) return;
      if (!opened) {
        _snack(DiscPrestaSub.browserErr, kind: AppSnackKind.error);
      } else {
        _snack(DiscPaymentMethods.portalOpened);
      }
    } on StripePrestaSubscriptionException catch (e) {
      _snack(e.message, kind: AppSnackKind.error);
    } catch (e) {
      debugPrint('billing portal: $e');
      _snack(DiscPrestaSub.portalErr, kind: AppSnackKind.error);
    } finally {
      if (mounted) setState(() => _busySubscription = false);
    }
  }

  Future<void> _syncSubscription() async {
    setState(() => _busySubscription = true);
    try {
      final service = ref.read(stripePrestaSubscriptionServiceProvider);
      if (service != null) {
        await service.syncFromStripe();
      }
      ref.invalidate(prestataireSubscriptionStatusProvider);
      _snack(DiscPaymentMethods.statusUpdated, kind: AppSnackKind.success);
    } catch (_) {
      _snack(DiscPrestaSub.checkoutErr, kind: AppSnackKind.error);
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

  String _subscriptionStatusLabel(PrestataireSubscriptionStatus status) {
    if (status.isActive) return DiscPaymentMethods.subscriptionStatusActive;
    return switch (status.status) {
      'past_due' => DiscPaymentMethods.subscriptionStatusPastDue,
      'canceled' => DiscPrestaSub.statusCanceled,
      'incomplete' => DiscPrestaSub.statusIncomplete,
      _ => DiscPaymentMethods.subscriptionStatusNone,
    };
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

  @override
  Widget build(BuildContext context) {
    if (!StripeService.isConfigured) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final subscriptionAsync = ref.watch(prestataireSubscriptionStatusProvider);
    final connectAsync = ref.watch(prestataireStripeConnectProvider);

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
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (status) {
              if (!status.isActive && !status.needsAttention) {
                return const SizedBox.shrink();
              }
              final active = status.isActive;
              final pastDue = status.status == 'past_due';
              return Column(
                children: [
                  _PaymentMethodBlock(
                    icon: Icons.credit_card_rounded,
                    title: DiscPaymentMethods.subscriptionTitle,
                    hint: DiscPaymentMethods.subscriptionHint,
                    status: _subscriptionStatusLabel(status),
                    statusColor: active
                        ? AppColors.success
                        : pastDue
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurfaceVariant,
                    busy: _busySubscription,
                    primaryLabel: DiscPaymentMethods.subscriptionManage,
                    onPrimary: _openBillingPortal,
                    secondaryLabel: DiscStripeConnect.ctaRefresh,
                    onSecondary: _syncSubscription,
                  ),
                  Divider(
                    height: 24,
                    color: theme.colorScheme.outline.withValues(alpha: 0.12),
                  ),
                ],
              );
            },
          ),
          connectAsync.when(
            loading: () => const _PaymentMethodSkeleton(),
            error: (_, __) => _PaymentMethodBlock(
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
            data: (connect) {
              final canPay = connect?.canAcceptPayments ?? false;
              final hasAccount = connect?.accountId != null;
              return _PaymentMethodBlock(
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
