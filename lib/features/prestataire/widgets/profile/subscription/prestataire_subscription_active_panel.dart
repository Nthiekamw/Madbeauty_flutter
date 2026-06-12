import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../router/navigation_extensions.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_fonts.dart';
import '../../../../../shared/theme/discovery_styles.dart';
import '../../../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../../models/prestataire_subscription_status.dart';
import '../../subscription/prestataire_subscription_billing_cards_section.dart';

/// État abonnement actif sur l’écran « Mon abonnement ».
class PrestataireSubscriptionActivePanel extends ConsumerStatefulWidget {
  const PrestataireSubscriptionActivePanel({
    super.key,
    required this.status,
    required this.tierLabel,
    required this.refreshing,
    required this.onRefresh,
  });

  final PrestataireSubscriptionStatus status;
  final String tierLabel;
  final bool refreshing;
  final VoidCallback onRefresh;

  @override
  ConsumerState<PrestataireSubscriptionActivePanel> createState() =>
      _PrestataireSubscriptionActivePanelState();
}

class _PrestataireSubscriptionActivePanelState
    extends ConsumerState<PrestataireSubscriptionActivePanel> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final busy = widget.refreshing;
    final period = widget.status.periodEnd;
    final periodText = period != null
        ? DiscPrestaSub.renewsOn.replaceFirst(
            '%s',
            MaterialLocalizations.of(context).formatShortDate(period.toLocal()),
          )
        : null;
    final intervalLabel = widget.status.interval == 'year'
        ? DiscPrestaSub.activeIntervalYearly
        : DiscPrestaSub.activeIntervalMonthly;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DiscoverySurfaceCard(
          padding: EdgeInsets.zero,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: DiscoveryStyles.cardBorderRadius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.successBg12,
                  theme.colorScheme.primary.withValues(alpha: 0.08),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.successBg12,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.successBorder35),
                        ),
                        child: Text(
                          DiscPrestaSub.activeHeroBadge,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.verified_rounded,
                        color: AppColors.success.withValues(alpha: 0.9),
                        size: 28,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    DiscPrestaSub.activeHeroTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DiscPrestaSub.activeHeroBody,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(
                    icon: Icons.layers_rounded,
                    label: DiscPrestaSub.activeTierLabel(widget.tierLabel),
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.event_repeat_rounded,
                    label: intervalLabel,
                  ),
                  if (periodText != null) ...[
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.calendar_today_rounded,
                      label: periodText,
                    ),
                  ],
                  const SizedBox(height: 18),
                  if (busy)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: widget.onRefresh,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text(DiscPrestaSub.refreshStatus),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const DiscoverySurfaceCard(
          padding: EdgeInsets.all(18),
          child: PrestataireSubscriptionBillingCardsSection(),
        ),
        const SizedBox(height: 14),
        DiscoverySurfaceCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DiscPrestaSub.activeConnectHintTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontFamily: AppFonts.display,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DiscPrestaSub.activeConnectHintBodyShort,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.pushPrestatairePaymentMethods(),
                      child: const Text(DiscPrestaSub.activeConnectHintCta),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.success),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
