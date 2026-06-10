import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../services/stripe/stripe_connect_providers.dart';
import '../../../../../../services/stripe/stripe_connect_service.dart';
import '../../../../../../services/stripe/stripe_service.dart';
import '../../../../../../../shared/theme/app_colors.dart';
import '../../../../../../../shared/theme/app_fonts.dart';
import '../../../../../../../shared/utils/app_url_launcher.dart';
import '../../../../../../../shared/widgets/app/app_snack_bar.dart';
import '../../../../../../../shared/widgets/discovery/discovery_menu_tile.dart';
import '../../../../../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../../shared/prestataire_section_header.dart';

/// Carte profil prestataire : onboarding Stripe Connect.
class PrestataireStripeConnectTile extends ConsumerStatefulWidget {
  const PrestataireStripeConnectTile({super.key});

  @override
  ConsumerState<PrestataireStripeConnectTile> createState() =>
      _PrestataireStripeConnectTileState();
}

class _PrestataireStripeConnectTileState
    extends ConsumerState<PrestataireStripeConnectTile> {
  bool _busy = false;

  String _statusLabel(StripeConnectStatus? status) {
    if (status == null) return DiscStripeConnect.statusNotStarted;
    if (status.canAcceptPayments) return DiscStripeConnect.statusComplete;
    return switch (status.onboardingStatus) {
      'complete' => DiscStripeConnect.statusComplete,
      'restricted' => DiscStripeConnect.statusRestricted,
      'pending' => DiscStripeConnect.statusPending,
      _ => DiscStripeConnect.statusNotStarted,
    };
  }

  Future<void> _openOnboarding() async {
    final service = ref.read(stripeConnectServiceProvider);
    if (service == null) {
      _snack(DiscStripeConnect.stripeUnavailable, error: true);
      return;
    }

    setState(() => _busy = true);
    try {
      final result = await service.startOnboarding();
      ref.invalidate(prestataireStripeConnectProvider);

      if (result.alreadyComplete) {
        if (!mounted) return;
        _snack(DiscStripeConnect.alreadyActive);
        return;
      }

      final url = result.url;
      if (url == null || url.isEmpty) {
        _snack(DiscStripeConnect.openErr, error: true);
        return;
      }

      if (!context.mounted) return;
      final opened = await AppUrlLauncher.openInApp(context, url);
      if (!context.mounted) return;
      if (!opened) {
        _snack(DiscStripeConnect.openErr, error: true);
      }
    } on StripeConnectException catch (e) {
      _snack(e.message, error: true);
    } catch (e, st) {
      debugPrint('Stripe Connect onboarding failed: $e\n$st');
      _snack(DiscStripeConnect.openErr, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _refresh() async {
    setState(() => _busy = true);
    try {
      ref.invalidate(prestataireStripeConnectProvider);
      await ref.read(prestataireStripeConnectProvider.future);
      if (!mounted) return;
      _snack(DiscPaymentMethods.statusUpdated);
    } on StripeConnectException catch (e) {
      _snack(e.message, error: true);
    } catch (e, st) {
      debugPrint('Stripe Connect sync failed: $e\n$st');
      _snack(DiscStripeConnect.syncErr, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String message, {bool error = false}) {
    AppSnackBar.show(
      context,
      message: message,
      kind: error ? AppSnackKind.error : AppSnackKind.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!StripeService.isConfigured) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final statusAsync = ref.watch(prestataireStripeConnectProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: DiscoverySurfaceCard(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PrestataireSectionHeader(
              icon: Icons.account_balance_wallet_outlined,
              title: DiscStripeConnect.sectionTitle,
              subtitle: DiscStripeConnect.sectionSubtitle,
              iconColor: theme.colorScheme.primary,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.12),
                ),
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
                      DiscStripeConnect.distinctionNote,
                      style: theme.textTheme.bodySmall?.copyWith(
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            statusAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => DiscoveryMenuTile(
                icon: Icons.refresh_rounded,
                title: DiscStripeConnect.ctaRefresh,
                onTap: _busy ? null : _refresh,
              ),
              data: (status) {
                final canPay = status?.canAcceptPayments ?? false;
                final label = _statusLabel(status);
                return Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        canPay
                            ? Icons.check_circle_rounded
                            : Icons.pending_outlined,
                        color: canPay
                            ? AppColors.success
                            : theme.colorScheme.primary,
                      ),
                      title: Text(
                        label,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontFamily: AppFonts.display,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: status?.accountId != null
                          ? Text(
                              'Compte ${status!.accountId}',
                              style: theme.textTheme.bodySmall,
                            )
                          : null,
                    ),
                    if (_busy)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else ...[
                      DiscoveryMenuTile(
                        icon: Icons.link_rounded,
                        title: canPay
                            ? DiscStripeConnect.ctaContinue
                            : (status?.accountId != null
                                  ? DiscStripeConnect.ctaContinue
                                  : DiscStripeConnect.ctaStart),
                        onTap: _openOnboarding,
                      ),
                      Divider(
                        height: 1,
                        color: theme.colorScheme.outline.withValues(
                          alpha: 0.12,
                        ),
                      ),
                      DiscoveryMenuTile(
                        icon: Icons.refresh_rounded,
                        title: DiscStripeConnect.ctaRefresh,
                        onTap: _refresh,
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
