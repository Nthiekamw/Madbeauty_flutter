import 'package:flutter/material.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../../shared/theme/app_fonts.dart';
import '../../../../../../shared/theme/discovery_styles.dart';
import '../../../../booking/logic/booking_formatters.dart';
import '../../../../booking/widgets/reservation/reservation_payment_summary_card.dart';
import '../../../models/prestataire_reservation_item.dart';
import '../../shared/prestataire_client_identity_row.dart';

class PrestatairePendingRequestCard extends StatelessWidget {
  const PrestatairePendingRequestCard({
    super.key,
    required this.item,
    required this.onAccept,
    required this.onReject,
    this.busy = false,
  });

  final PrestataireReservationItem item;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateLabel = formatBookingDate(item.dateHeure);
    final timeLabel = formatBookingTime(item.dateHeure);
    final accent = theme.colorScheme.tertiary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: theme.colorScheme.surface.withValues(
          alpha: isDark ? 0.85 : 0.98,
        ),
        borderRadius: DiscoveryStyles.cardBorderRadius,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: DiscoveryStyles.cardBorderRadius,
            border: Border.all(
              color: accent.withValues(alpha: 0.22),
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: PrestataireClientIdentityRow(
                          clientName: item.clientDisplayName,
                          clientPrenom: item.clientPrenom,
                          clientNom: item.clientNom,
                          serviceName: item.serviceName,
                          clientAvatarUrl: item.clientAvatarUrl,
                          avatarRadius: 22,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          DiscPrestaDash.statPending,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontFamily: AppFonts.body,
                            color: accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: isDark ? 0.35 : 0.55),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.event_outlined,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                dateLabel,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontFamily: AppFonts.body,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              timeLabel,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontFamily: AppFonts.display,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (item.paymentDisplay.shouldShow) ...[
                      const SizedBox(height: 10),
                      ReservationPaymentSummaryCard(
                        display: item.paymentDisplay,
                        lines: item.paymentDisplay.prestataireLines(),
                        compact: true,
                      ),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: busy ? null : onReject,
                            child: const Text(DiscPrestaDash.reject),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: busy ? null : onAccept,
                            child: busy
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  )
                                : const Text(DiscPrestaDash.accept),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
