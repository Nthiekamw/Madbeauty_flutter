import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/prestataire_subscription_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../services/stripe/stripe_subscription_providers.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/widgets/discovery/content/discovery_detail_skeleton.dart';
import '../../../shared/widgets/discovery/content/discovery_section_error.dart';
import '../../../shared/widgets/discovery/discovery_screen_header.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../logic/prestataire_subscription_refresh.dart';
import '../providers/subscription/prestataire_subscription_provider.dart';
import '../widgets/profile/subscription/prestataire_subscription_active_panel.dart';
import '../widgets/profile/subscription/prestataire_subscription_checkout_section.dart';
import '../widgets/profile/subscription/prestataire_subscription_testimonials_section.dart';
import '../widgets/profile/subscription/prestataire_subscription_tier_cards.dart';
import '../widgets/subscription/prestataire_subscription_billing_cards_section.dart';
import '../widgets/workspace/layout/prestataire_brand_scaffold.dart';
import '../widgets/workspace/prestataire_flow_scaffold.dart';

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
    final useWeb = DiscoveryResponsive.of(context).useWebSiteLayout;
    final sectionPad = useWeb
        ? const EdgeInsets.symmetric(horizontal: 20)
        : const EdgeInsets.symmetric(horizontal: 20);
    final serviceCountAsync = ref.watch(prestatairePublishedServiceCountProvider);
    final statusAsync = ref.watch(prestataireSubscriptionStatusProvider);

    return PrestataireFlowScaffold(
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
          padding: EdgeInsets.only(
            top: useWeb ? 16 : 0,
            bottom: 32,
          ),
          children: [
            if (_refreshing)
              LinearProgressIndicator(
                minHeight: 2,
                color: primary,
                backgroundColor: primary.withValues(alpha: 0.12),
              ),
            if (!useWeb)
              const DiscoveryScreenHeader(
                title: DiscPrestaSub.heroTitle,
                subtitle: DiscPrestaSub.heroBody,
              )
            else
              Padding(
                padding: sectionPad,
                child: Text(
                  DiscPrestaSub.heroBody,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ),
            if (useWeb) const SizedBox(height: 12),
            statusAsync.when(
              loading: () => const DiscoveryDetailSkeleton(),
              error: (_, __) => Padding(
                padding: sectionPad,
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
                    padding: sectionPad,
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
                    padding: sectionPad,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DiscoverySurfaceCard(
                          includeHorizontalMargin: false,
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
                          includeHorizontalMargin: false,
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
                    padding: sectionPad,
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
                      padding: sectionPad,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DiscoverySurfaceCard(
                            includeHorizontalMargin: false,
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
                          PrestataireSubscriptionTierCards(
                            currentTierId: currentTier.id,
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
            const PrestataireSubscriptionTestimonialsSection(),
          ],
        ),
      ),
    );
  }
}
