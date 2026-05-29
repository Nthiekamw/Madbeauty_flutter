import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/discovery_styles.dart';
import '../../../shared/widgets/app/app_avatar.dart';
import '../logic/booking_formatters.dart';
import '../logic/client_reservation_ui_status.dart';
import '../models/client_reservation_summary.dart';
import 'client_reservation_review_action.dart';

class ClientReservationCard extends StatelessWidget {
  const ClientReservationCard({
    super.key,
    required this.item,
    this.onCancel,
    this.onMessage,
    this.onReviewSubmitted,
    this.cancelLoading = false,
  });

  final ClientReservationSummary item;
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
    final showMessage = onMessage != null &&
        uiStatus != ClientReservationUiStatus.cancelled &&
        uiStatus != ClientReservationUiStatus.unknown;

    return Material(
      color: Colors.transparent,
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AppAvatar(
                        imageUrl: item.prestataireAvatarUrl,
                        displayName: prestataireLabel,
                        radius: 30,
                      ),
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: chipStyle.backgroundColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.surface,
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            _statusIcon(uiStatus),
                            size: 10,
                            color: chipStyle.foregroundColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prestataireLabel,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontFamily: AppFonts.display,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Icon(
                              Icons.content_cut_rounded,
                              size: 13,
                              color: primary,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                serviceLabel,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontFamily: AppFonts.body,
                                  fontWeight: FontWeight.w600,
                                  color: primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: chipStyle.backgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      clientReservationStatusLabel(uiStatus),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontFamily: AppFonts.body,
                        color: chipStyle.foregroundColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (item.hasPaymentReceipt) ...[
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
                    children: [
                      Flexible(
                        child: _MetaChip(
                          icon: Icons.calendar_today_rounded,
                          text: formatBookingDate(item.dateHeure),
                          theme: theme,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _MetaChip(
                        icon: Icons.schedule_rounded,
                        text: formatBookingTime(item.dateHeure),
                        theme: theme,
                      ),
                    ],
                  ),
                  if (showMessage || showCancel)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          if (showMessage)
                            IconButton(
                              onPressed: onMessage,
                              icon: Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 20,
                                color: primary,
                              ),
                              tooltip: DiscChat.openChat,
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                            ),
                          ClientReservationReviewAction(
                            item: item,
                            onReviewSubmitted: onReviewSubmitted,
                          ),
                          const Spacer(),
                          if (showCancel)
                            cancelLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: primary,
                                    ),
                                  )
                                : TextButton.icon(
                                    onPressed: onCancel,
                                    icon: Icon(
                                      Icons.close_rounded,
                                      size: 16,
                                      color: primary,
                                    ),
                                    label: Text(
                                      DiscBk.revokeLabel,
                                      style: TextStyle(
                                        fontFamily: AppFonts.body,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      minimumSize: const Size(0, 34),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                      ),
                                      foregroundColor: primary,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
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
    );
  }

  IconData _statusIcon(ClientReservationUiStatus status) {
    switch (status) {
      case ClientReservationUiStatus.confirmed:
        return Icons.check_rounded;
      case ClientReservationUiStatus.pending:
        return Icons.hourglass_top_rounded;
      case ClientReservationUiStatus.cancelled:
        return Icons.close_rounded;
      case ClientReservationUiStatus.done:
        return Icons.done_all_rounded;
      case ClientReservationUiStatus.syncPending:
        return Icons.sync_rounded;
      case ClientReservationUiStatus.unknown:
        return Icons.help_outline_rounded;
    }
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
              const Icon(Icons.receipt_long_rounded,
                  size: 18, color: Color(0xFF10B981)),
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

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.text,
    required this.theme,
  });

  final IconData icon;
  final String text;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: AppFonts.body,
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
