import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/theme/discovery_styles.dart';
import '../../../../shared/widgets/app/app_avatar.dart';
import '../../logic/booking_formatters.dart';
import '../../logic/client_reservation_ui_status.dart';
import '../../logic/reservation_chat_eligibility.dart';
import '../../models/client_reservation_summary.dart';
import 'client_reservation_review_action.dart';
import 'reservation_payment_summary_card.dart';
import 'reservation_pending_banner.dart';
import 'reservation_reject_reason_box.dart';

class ClientReservationCard extends StatelessWidget {
  const ClientReservationCard({
    super.key,
    required this.item,
    this.onTap,
    this.onCancel,
    this.onMessage,
    this.onReviewSubmitted,
    this.cancelLoading = false,
  });

  final ClientReservationSummary item;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onMessage;
  final VoidCallback? onReviewSubmitted;
  final bool cancelLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final primary = cs.primary;

    final prestataireLabel =
        item.prestataireName?.trim().isNotEmpty == true
            ? item.prestataireName!.trim()
            : DiscBk.unknownPresta;
    final serviceLabel =
        item.serviceName?.trim().isNotEmpty == true
            ? item.serviceName!.trim()
            : DiscBk.unknownSvc;

    final uiStatus = clientReservationUiStatusFromStatut(item.statut);
    final chipStyle = chipColorsForReservationStatus(cs, uiStatus);
    final showCancel =
        onCancel != null && clientReservationCanCancel(uiStatus);
    final showMessage =
        onMessage != null && clientReservationCanMessage(uiStatus);

    return Material(
      color: Colors.transparent,
      borderRadius: DiscoveryStyles.cardBorderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: DiscoveryStyles.cardBorderRadius,
        child: Ink(
        decoration: BoxDecoration(
          borderRadius: DiscoveryStyles.cardBorderRadius,
          color: theme.colorScheme.surface.withValues(
            alpha: isDark ? 0.92 : 0.98,
          ),
          border: Border.all(
            color: chipStyle.backgroundColor.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: ReservationPendingBanner(statut: item.statut),
            ),
            if (uiStatus == ClientReservationUiStatus.cancelled &&
                item.hasRejectReason)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: ReservationRejectReasonBox(reason: item.notesPrestataire!),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppAvatar(
                    imageUrl: item.prestataireAvatarUrl,
                    displayName: prestataireLabel,
                    radius: 30,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                prestataireLabel,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontFamily: AppFonts.display,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: chipStyle.backgroundColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _statusIcon(uiStatus),
                                    size: 14,
                                    color: chipStyle.foregroundColor,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    clientReservationStatusLabel(uiStatus),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontFamily: AppFonts.body,
                                      color: chipStyle.foregroundColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Icon(
                                Icons.spa_outlined,
                                size: 14,
                                color: primary,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                serviceLabel,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontFamily: AppFonts.body,
                                  fontWeight: FontWeight.w600,
                                  color: primary,
                                  height: 1.25,
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
            ),
            if (item.paymentDisplay.shouldShow) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: ReservationPaymentSummaryCard(
                  display: item.paymentDisplay,
                  lines: item.paymentDisplay.clientLines(),
                  compact: true,
                ),
              ),
            ] else if (item.hasPaymentReceipt) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: _PaymentReceiptStrip(item: item, theme: theme),
              ),
            ],
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: isDark ? 0.07 : 0.04),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
                border: Border(
                  top: BorderSide(
                    color: primary.withValues(alpha: isDark ? 0.1 : 0.07),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: _InfoPill(
                          icon: Icons.calendar_month_rounded,
                          text: formatBookingDate(item.dateHeure),
                          theme: theme,
                          primary: primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: _InfoPill(
                          icon: Icons.schedule_rounded,
                          text: formatBookingTime(item.dateHeure),
                          theme: theme,
                          primary: primary,
                        ),
                      ),
                    ],
                  ),
                  if (showMessage || showCancel)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Row(
                        children: [
                          if (showMessage)
                            _ReservationIconAction(
                              onPressed: onMessage,
                              icon: Icons.forum_rounded,
                              label: DiscChat.openChat,
                              tooltip: DiscChat.openChat,
                              primary: primary,
                              filled: true,
                            ),
                          ClientReservationReviewAction(
                            item: item,
                            onReviewSubmitted: onReviewSubmitted,
                          ),
                          const Spacer(),
                          if (showCancel)
                            cancelLoading
                                ? SizedBox(
                                    height: 36,
                                    width: 36,
                                    child: Center(
                                      child: SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: primary,
                                        ),
                                      ),
                                    ),
                                  )
                                : _ReservationIconAction(
                                    onPressed: onCancel,
                                    icon: Icons.event_busy_rounded,
                                    label: DiscBk.revokeLabel,
                                    tooltip: DiscBk.revokeLabel,
                                    primary: theme.colorScheme.error,
                                    filled: false,
                                  ),
                        ],
                      ),
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

  IconData _statusIcon(ClientReservationUiStatus status) {
    switch (status) {
      case ClientReservationUiStatus.confirmed:
        return Icons.verified_rounded;
      case ClientReservationUiStatus.pending:
        return Icons.pending_actions_rounded;
      case ClientReservationUiStatus.cancelled:
        return Icons.block_rounded;
      case ClientReservationUiStatus.done:
        return Icons.task_alt_rounded;
      case ClientReservationUiStatus.syncPending:
        return Icons.cloud_sync_rounded;
      case ClientReservationUiStatus.unknown:
        return Icons.help_outline_rounded;
    }
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.text,
    required this.theme,
    required this.primary,
  });

  final IconData icon;
  final String text;
  final ThemeData theme;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.35 : 0.65,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 16, color: primary),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              softWrap: true,
              style: theme.textTheme.labelMedium?.copyWith(
                fontFamily: AppFonts.body,
                fontWeight: FontWeight.w600,
                fontSize: 11.5,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReservationIconAction extends StatelessWidget {
  const _ReservationIconAction({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.primary,
    required this.filled,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final String tooltip;
  final Color primary;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (filled) {
      return Padding(
        padding: const EdgeInsets.only(right: 6),
        child: FilledButton.tonalIcon(
          onPressed: onPressed,
          icon: Icon(icon, size: 18),
          label: Text(label),
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 36),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            foregroundColor: primary,
            backgroundColor: primary.withValues(alpha: 0.12),
            textStyle: theme.textTheme.labelMedium?.copyWith(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 17),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        foregroundColor: primary,
        side: BorderSide(color: primary.withValues(alpha: 0.45)),
        textStyle: theme.textTheme.labelMedium?.copyWith(
          fontFamily: AppFonts.body,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PaymentReceiptStrip extends StatelessWidget {
  const _PaymentReceiptStrip({required this.item, required this.theme});

  final ClientReservationSummary item;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final paidAt = item.paidAt!;
    final primary = theme.colorScheme.primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.payments_rounded,
                size: 18,
                color: const Color(0xFF10B981),
              ),
              const SizedBox(width: 8),
              Text(
                DiscPay.receiptLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${DiscPay.receiptAmount} : ${item.formattedPaidAmount}',
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${DiscPay.receiptPaidOn} ${formatBookingDate(paidAt)} à ${formatBookingTime(paidAt)}',
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: AppFonts.body,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (item.prestataireName?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 2),
            Text(
              item.prestataireName!.trim(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: AppFonts.body,
                color: primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

