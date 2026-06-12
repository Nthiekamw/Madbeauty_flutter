import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/prestataire_subscription_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../services/stripe/stripe_subscription_providers.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/discovery/content/discovery_detail_skeleton.dart';
import '../../../shared/widgets/discovery/content/discovery_section_error.dart';
import '../../../shared/widgets/discovery/discovery_screen_header.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../logic/prestataire_subscription_refresh.dart';
import '../providers/subscription/prestataire_subscription_provider.dart';
import '../widgets/profile/subscription/prestataire_subscription_active_panel.dart';
import '../widgets/profile/subscription/prestataire_subscription_checkout_section.dart';
import '../widgets/subscription/prestataire_subscription_billing_cards_section.dart';
import '../widgets/workspace/prestataire_brand_scaffold.dart';

/// Grille d’abonnement + paiement Stripe Checkout.
class PrestataireSubscriptionScreen extends ConsumerStatefulWidget {
  const PrestataireSubscriptionScreen({super.key});

  @override
  ConsumerState<PrestataireSubscriptionScreen> createState() =>
      _PrestataireSubscriptionScreenState();
}

class _PrestataireSubscriptionScreenState
    extends ConsumerState<PrestataireSubscriptionScreen>
    with WidgetsBindingObserver {
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refresh();
    }
  }

  Future<void> _refresh() async {
    if (_refreshing) return;
    if (ref.read(stripePrestaSubscriptionServiceProvider) == null) return;

    setState(() => _refreshing = true);
    try {
      await refreshPrestataireSubscription(ref);
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  String _tierLabel(String tierId) {
    return tierId == PrestataireSubscriptionConfig.multi.id
        ? DiscPrestaSub.tierMulti
        : DiscPrestaSub.tierSolo;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final serviceCountAsync = ref.watch(prestatairePublishedServiceCountProvider);
    final statusAsync = ref.watch(prestataireSubscriptionStatusProvider);

    return PrestataireBrandScaffold(
      appBar: prestataireBrandAppBar(
        context: context,
        title: const Text(DiscPrestaSub.screenTitle),
        actions: [
          IconButton(
            tooltip: DiscPrestaSub.refreshStatus,
            onPressed: _refreshing ? null : _refresh,
            icon: _refreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            if (_refreshing)
              LinearProgressIndicator(
                minHeight: 2,
                color: primary,
                backgroundColor: primary.withValues(alpha: 0.12),
              ),
            const DiscoveryScreenHeader(
              title: DiscPrestaSub.heroTitle,
              subtitle: DiscPrestaSub.heroBody,
            ),
            statusAsync.when(
              loading: () => const DiscoveryDetailSkeleton(),
              error: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: DiscoverySectionError(
                  message: DiscPrestaDash.loadErr,
                  onRetry: () {
                    ref.invalidate(prestataireSubscriptionStatusProvider);
                  },
                ),
              ),
              data: (status) {
                if (status.isActive) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: PrestataireSubscriptionActivePanel(
                      status: status,
                      tierLabel: _tierLabel(
                        status.tier ??
                            PrestataireSubscriptionConfig.solo.id,
                      ),
                      refreshing: _refreshing,
                      onRefresh: _refresh,
                    ),
                  );
                }

                if (status.needsAttention) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DiscoverySurfaceCard(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: theme.colorScheme.error,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      DiscPaymentMethods.subscriptionStatusPastDue,
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        fontFamily: AppFonts.display,
                                        fontWeight: FontWeight.w800,
                                        color: theme.colorScheme.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                DiscPrestaSub.statusPastDue,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        const DiscoverySurfaceCard(
                          padding: EdgeInsets.all(18),
                          child: PrestataireSubscriptionBillingCardsSection(),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _refreshing ? null : _refresh,
                          icon: _refreshing
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text(DiscPrestaSub.refreshStatus),
                        ),
                      ],
                    ),
                  );
                }

                return serviceCountAsync.when(
                  loading: () => const DiscoveryDetailSkeleton(),
                  error: (_, __) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: DiscoverySectionError(
                      message: DiscPrestaDash.loadErr,
                      onRetry: () {
                        ref.invalidate(prestatairePublishedServiceCountProvider);
                      },
                    ),
                  ),
                  data: (serviceCount) {
                    final currentTier =
                        PrestataireSubscriptionConfig.tierForServiceCount(
                      serviceCount,
                    );
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DiscoverySurfaceCard(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DiscPrestaSub.currentTier,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontFamily: AppFonts.body,
                                    fontWeight: FontWeight.w700,
                                    color: primary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  DiscPrestaSub.serviceCount.replaceFirst(
                                    '%s',
                                    '$serviceCount',
                                  ),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currentTier.id == 'solo'
                                      ? DiscPrestaSub.tierSolo
                                      : DiscPrestaSub.tierMulti,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontFamily: AppFonts.display,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            DiscPrestaSub.plansSectionTitle,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontFamily: AppFonts.display,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DiscPrestaSub.plansSectionSubtitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _TierCard(
                            theme: theme,
                            primary: primary,
                            title: DiscPrestaSub.tierSolo,
                            monthly:
                                PrestataireSubscriptionConfig.solo.monthlyEur,
                            yearly: PrestataireSubscriptionConfig.solo.yearlyEur,
                            highlighted: currentTier.id ==
                                PrestataireSubscriptionConfig.solo.id,
                          ),
                          const SizedBox(height: 12),
                          _TierCard(
                            theme: theme,
                            primary: primary,
                            title: DiscPrestaSub.tierMulti,
                            monthly:
                                PrestataireSubscriptionConfig.multi.monthlyEur,
                            yearly:
                                PrestataireSubscriptionConfig.multi.yearlyEur,
                            highlighted: currentTier.id ==
                                PrestataireSubscriptionConfig.multi.id,
                          ),
                          const SizedBox(height: 20),
                          const PrestataireSubscriptionCheckoutSection(),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  const _TierCard({
    required this.theme,
    required this.primary,
    required this.title,
    required this.monthly,
    required this.yearly,
    required this.highlighted,
  });

  final ThemeData theme;
  final Color primary;
  final String title;
  final double monthly;
  final double yearly;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return DiscoverySurfaceCard(
      padding: const EdgeInsets.all(18),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: highlighted
              ? Border.all(color: primary.withValues(alpha: 0.5), width: 1.5)
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              _PriceRow(
                label: DiscPrestaSub.monthly,
                value:
                    '${monthly.toStringAsFixed(2)} €${DiscPrestaSub.perMonth}',
                theme: theme,
                primary: primary,
              ),
              const SizedBox(height: 8),
              _PriceRow(
                label: DiscPrestaSub.yearly,
                value: '${yearly.toStringAsFixed(0)} €${DiscPrestaSub.perYear}',
                theme: theme,
                primary: primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    required this.theme,
    required this.primary,
  });

  final String label;
  final String value;
  final ThemeData theme;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: primary,
          ),
        ),
      ],
    );
  }
}
