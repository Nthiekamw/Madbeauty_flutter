import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/theme/discovery_styles.dart';
import '../../../booking/logic/booking_formatters.dart';
import '../../../booking/logic/client_reservation_ui_status.dart';
import '../../../booking/widgets/reservation/reservation_payment_summary_card.dart';
import '../../logic/prestataire_reservation_completion.dart';
import '../../models/prestataire_reservation_item.dart';
import '../shared/prestataire_client_identity_row.dart';

class PrestataireAgendaReservationCard extends StatelessWidget {
  const PrestataireAgendaReservationCard({
    super.key,
    required this.item,
    required this.onAccept,
    required this.onReject,
    required this.onMarkDone,
    this.onTap,
    this.busy = false,
    this.showTimelineConnector = true,
  });

  final PrestataireReservationItem item;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onMarkDone;
  final VoidCallback? onTap;
  final bool busy;
  final bool showTimelineConnector;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final status = clientReservationUiStatusFromStatut(item.statut);
    final chip = chipColorsForReservationStatus(theme.colorScheme, status);
    final canMarkDone = status == ClientReservationUiStatus.confirmed &&
        prestataireCanMarkReservationDone(item);
    final showMarkDoneHint = status == ClientReservationUiStatus.confirmed &&
        !canMarkDone;
    final timeLabel = formatBookingTime(item.dateHeure);
    final accent = chip.foregroundColor;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 56,
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    timeLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                if (showTimelineConnector)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: theme.colorScheme.outline.withValues(
                                alpha: 0.25,
                              ),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: theme.colorScheme.surface.withValues(
                  alpha: isDark ? 0.65 : 0.9,
                ),
                borderRadius: DiscoveryStyles.cardBorderRadius,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: DiscoveryStyles.cardBorderRadius,
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: DiscoveryStyles.cardBorderRadius,
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(
                          alpha: 0.12,
                        ),
                      ),
                      boxShadow: isDark
                          ? null
                          : [
                              BoxShadow(
                                color: accent.withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: ClipRRect(
                      borderRadius: DiscoveryStyles.cardBorderRadius,
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: chip.backgroundColor.withValues(alpha: 0.55),
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
                                  serviceName: item.offerTitle,
                                  clientAvatarUrl: item.clientAvatarUrl,
                                  avatarRadius: 20,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: chip.backgroundColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  clientReservationStatusLabel(status),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontFamily: AppFonts.body,
                                    color: chip.foregroundColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (item.paymentDisplay.shouldShow) ...[
                              ReservationPaymentSummaryCard(
                                display: item.paymentDisplay,
                                lines: item.paymentDisplay.prestataireLines(),
                                compact: true,
                              ),
                              const SizedBox(height: 8),
                            ],
                            if (item.notesClient?.trim().isNotEmpty ==
                                true) ...[
                              _NoteBlock(
                                icon: Icons.chat_bubble_outline_rounded,
                                label: 'Note client',
                                text: item.notesClient!.trim(),
                              ),
                              const SizedBox(height: 8),
                            ],
                            if (item.notesPrestataire?.trim().isNotEmpty ==
                                true) ...[
                              _NoteBlock(
                                icon: Icons.info_outline_rounded,
                                label: 'Motif',
                                text: item.notesPrestataire!.trim(),
                                tone: theme.colorScheme.error,
                              ),
                              const SizedBox(height: 8),
                            ],
                            if (status ==
                                ClientReservationUiStatus.pending) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: busy ? null : onReject,
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: const Size(0, 40),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                      ),
                                      child: const Text(
                                        DiscPrestaDash.reject,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: false,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: FilledButton(
                                      onPressed: busy ? null : onAccept,
                                      style: FilledButton.styleFrom(
                                        minimumSize: const Size(0, 40),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                      ),
                                      child: busy
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text(
                                              DiscPrestaDash.accept,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: false,
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (canMarkDone)
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.tonal(
                                  onPressed: busy ? null : onMarkDone,
                                  child: Text(
                                    busy ? '…' : DiscPrestaAgenda.markDone,
                                  ),
                                ),
                              ),
                            if (showMarkDoneHint)
                              Text(
                                DiscPrestaAgenda.markDonePendingHint,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteBlock extends StatelessWidget {
  const _NoteBlock({
    required this.icon,
    required this.label,
    required this.text,
    this.tone,
  });

  final IconData icon;
  final String label;
  final String text;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = tone ?? theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.35 : 0.65,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
