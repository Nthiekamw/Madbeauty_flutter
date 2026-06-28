import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/supabase/booking/booking_service_providers.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/layout/web_flow_panel.dart';
import '../../../shared/layout/web_flow_scaffold.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/app/app_avatar.dart';
import '../../../shared/widgets/app/app_button.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../logic/reservation_calendar_export.dart';
import '../widgets/reservation/reservation_pending_banner.dart';
import '../widgets/reservation/reservation_reject_reason_box.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../messaging/messaging_navigation.dart';
import '../../messaging/models/messaging_inbox_role.dart';
import '../logic/booking_formatters.dart';
import '../logic/client_reservation_ui_status.dart';
import '../logic/reservation_chat_eligibility.dart';
import '../logic/reservation_payment_display.dart';
import '../models/client_reservation_summary.dart';
import '../providers/client_reservation_detail_provider.dart';
import '../widgets/reservation/client_reservation_review_action.dart';
import '../widgets/reservation/reservation_payment_summary_card.dart';

class ClientReservationDetailScreen extends ConsumerStatefulWidget {
  const ClientReservationDetailScreen({
    super.key,
    required this.reservationId,
  });

  final String reservationId;

  @override
  ConsumerState<ClientReservationDetailScreen> createState() =>
      _ClientReservationDetailScreenState();
}

class _ClientReservationDetailScreenState
    extends ConsumerState<ClientReservationDetailScreen> {
  bool _cancelling = false;

  Future<void> _confirmCancel(ClientReservationSummary item) async {
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(DiscBk.revokeAskTitle),
        content: const Text(DiscBk.revokeAskBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(CoreStrings.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(DiscBk.revokeYes),
          ),
        ],
      ),
    );
    if (go != true || !mounted) return;

    final service = ref.read(bookingServiceProvider);
    if (service == null) return;

    setState(() => _cancelling = true);
    try {
      await service.cancelClientReservation(item.id);
      invalidateClientReservations(ref);
      ref.invalidate(clientReservationDetailProvider(item.id));
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: DiscBk.badgeCancelled,
        kind: AppSnackKind.success,
      );
      Navigator.of(context).maybePop();
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: DiscBk.revokeFail,
        kind: AppSnackKind.error,
      );
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final useWeb = DiscoveryResponsive.of(context).useWebSiteLayout;
    final detailAsync = ref.watch(
      clientReservationDetailProvider(widget.reservationId),
    );
    final listPadding = useWeb
        ? const EdgeInsets.fromLTRB(20, 16, 20, 32)
        : const EdgeInsets.fromLTRB(20, 8, 20, 32);

    final body = detailAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(20),
        child: DiscoveryListSkeleton(rowCount: 3, rowHeight: 88),
      ),
      error: (_, __) => Center(
        child: DiscoveryEmptyState(
          icon: Icons.cloud_off_outlined,
          title: CoreStrings.networkErrorTitle,
          body: DiscBk.listErrBody,
          iconColor: theme.colorScheme.error,
          actionLabel: DiscList.retry,
          onAction: () => ref.invalidate(
            clientReservationDetailProvider(widget.reservationId),
          ),
        ),
      ),
      data: (item) {
        if (item == null) {
          return Center(
            child: DiscoveryEmptyState(
              icon: Icons.event_busy_outlined,
              title: DiscBk.detailNotFoundTitle,
              body: DiscBk.detailNotFoundBody,
              iconColor: theme.colorScheme.onSurfaceVariant,
            ),
          );
        }

        final ui = clientReservationUiStatusFromStatut(item.statut);
        final chip = chipColorsForReservationStatus(theme.colorScheme, ui);
        final prestataireLabel =
            item.prestataireName?.trim().isNotEmpty == true
                ? item.prestataireName!.trim()
                : DiscBk.unknownPresta;
        final serviceLabel =
            item.serviceName?.trim().isNotEmpty == true
                ? item.serviceName!.trim()
                : DiscBk.unknownSvc;
        final canCancel = clientReservationCanCancel(ui);
        final canMessage = clientReservationCanMessage(ui);

        return ListView(
          padding: listPadding,
          children: [
            ReservationPendingBanner(statut: item.statut),
            if (ui == ClientReservationUiStatus.cancelled && item.hasRejectReason) ...[
              const SizedBox(height: 10),
              ReservationRejectReasonBox(reason: item.notesPrestataire!),
            ],
            const SizedBox(height: 12),
            DiscoverySurfaceCard(
              padding: const EdgeInsets.all(16),
              includeHorizontalMargin: !useWeb,
                child: Row(
                  children: [
                    AppAvatar(
                      imageUrl: item.prestataireAvatarUrl,
                      displayName: prestataireLabel,
                      radius: 32,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prestataireLabel,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontFamily: AppFonts.display,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            serviceLabel,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: chip.backgroundColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        clientReservationStatusLabel(ui),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: chip.foregroundColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              DiscoverySurfaceCard(
                padding: const EdgeInsets.all(16),
                includeHorizontalMargin: !useWeb,
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.calendar_today_outlined,
                      label: DiscBk.recapDate,
                      value: formatBookingDate(item.dateHeure),
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      icon: Icons.schedule_rounded,
                      label: DiscBk.recapTime,
                      value: formatBookingTime(item.dateHeure),
                    ),
                    if (item.servicePriceCents != null &&
                        item.servicePriceCents! > 0) ...[
                      const SizedBox(height: 12),
                      _DetailRow(
                        icon: Icons.euro_rounded,
                        label: DiscBk.recapPrice,
                        value: formatCentsEur(item.servicePriceCents!),
                      ),
                    ],
                  ],
                ),
              ),
              if (item.paymentDisplay.shouldShow) ...[
                const SizedBox(height: 12),
                ReservationPaymentSummaryCard(
                  display: item.paymentDisplay,
                  lines: item.paymentDisplay.clientLines(),
                ),
              ] else if (item.hasPaymentReceipt) ...[
                const SizedBox(height: 12),
                DiscoverySurfaceCard(
                  padding: const EdgeInsets.all(16),
                  includeHorizontalMargin: !useWeb,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DiscPay.receiptLabel,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('${DiscPay.receiptAmount} : ${item.formattedPaidAmount}'),
                      if (item.paidAt != null)
                        Text(
                          '${DiscPay.receiptPaidOn} ${formatBookingDate(item.paidAt!)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              if (canMessage)
                AppButton(
                  onPressed: _cancelling
                      ? null
                      : () => openChatForReservation(
                            context,
                            ref,
                            item.id,
                            viewerRole: MessagingInboxRole.client,
                          ),
                  child: const Text(DiscChat.openChat),
                ),
              if (canCancel) ...[
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: _cancelling ? null : () => _confirmCancel(item),
                  child: _cancelling
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(DiscBk.revokeLabel),
                ),
              ],
              if (ui == ClientReservationUiStatus.done) ...[
                const SizedBox(height: 10),
                ClientReservationReviewAction(
                  item: item,
                  onReviewSubmitted: () {
                    ref.invalidate(clientReservationDetailProvider(item.id));
                  },
                ),
              ],
              if (canMessage || ui == ClientReservationUiStatus.confirmed) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () async {
                    final ok = await ReservationCalendarExport.openInGoogleCalendar(
                      title: '$serviceLabel — $prestataireLabel',
                      start: item.dateHeure,
                      durationMinutes: item.durationMinutes,
                    );
                    if (!context.mounted) return;
                    if (!ok) {
                      AppSnackBar.show(
                        context,
                        message: DiscBk.calendarExportFail,
                      );
                    }
                  },
                  icon: const Icon(Icons.event_available_outlined),
                  label: const Text(DiscBk.addToCalendar),
                ),
              ],
              if (item.prestataireId != null &&
                  (ui == ClientReservationUiStatus.done ||
                      ui == ClientReservationUiStatus.confirmed)) ...[
                const SizedBox(height: 10),
                FilledButton.tonalIcon(
                  onPressed: () => context.pushBooking(
                    prestataireId: item.prestataireId!,
                    serviceId: item.serviceId,
                  ),
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text(DiscBk.rebookSamePresta),
                ),
              ],
              if (item.prestataireId != null) ...[
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () =>
                      context.pushPrestataireDetail(item.prestataireId!),
                  icon: const Icon(Icons.storefront_outlined),
                  label: Text(prestataireLabel),
                ),
              ],
            ],
          );
        },
      );

    return WebFlowScaffold(
      appBar: AppBar(title: const Text(DiscBk.detailTitle)),
      body: useWeb ? WebFlowPanel(child: body) : body,
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
