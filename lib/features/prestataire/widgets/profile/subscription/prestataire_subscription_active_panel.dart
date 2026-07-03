import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_fonts.dart';
import '../../../../../shared/theme/discovery_styles.dart';
import '../../../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../../models/prestataire_subscription_status.dart';

/// État d’accès catalogue sur l’écran « Accès catalogue ».
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
    final inTrial = widget.status.isInCatalogTrial;
    final trialDays = widget.status.catalogTrialDaysRemaining;

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
                          inTrial
                              ? DiscPrestaSub.statusCatalogTrial
                              : DiscPrestaSub.activeHeroBadge,
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
                    inTrial && trialDays != null
                        ? DiscPrestaSub.trialBannerBody(trialDays)
                        : DiscPrestaSub.activeHeroBody,
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
