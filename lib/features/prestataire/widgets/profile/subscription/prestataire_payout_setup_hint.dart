import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../router/navigation_extensions.dart';
import '../../../../../services/stripe/stripe_connect_providers.dart';
import '../../../../../services/stripe/stripe_service.dart';

/// Rappel : abonnement MadBeauty ≠ encaissement des prestations (Stripe Connect).
class PrestatairePayoutSetupHint extends ConsumerWidget {
  const PrestatairePayoutSetupHint({
    super.key,
    this.compact = false,
    this.showCta = true,
  });

  final bool compact;
  final bool showCta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!StripeService.isConfigured) return const SizedBox.shrink();

    final connectAsync = ref.watch(prestataireStripeConnectProvider);
    final canAccept = connectAsync.asData?.value?.canAcceptPayments ?? false;
    if (canAccept) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final accent = theme.colorScheme.tertiary;

    return Container(
      margin: EdgeInsets.only(top: compact ? 10 : 0),
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.account_balance_outlined,
                size: compact ? 20 : 22,
                color: accent,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DiscPrestaSub.activeConnectHintTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      compact
                          ? DiscPrestaSub.activeConnectHintBodyShort
                          : DiscPrestaSub.activeConnectHintBody,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (showCta) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => context.goPrestataireProfile(),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text(DiscPrestaSub.activeConnectHintCta),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
