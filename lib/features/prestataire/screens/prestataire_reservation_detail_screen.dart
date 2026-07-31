import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/supabase/disputes/dispute_providers.dart';
import '../../../services/supabase/disputes/dispute_service.dart';
import '../../../shared/widgets/discovery/content/discovery_detail_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../disputes/widgets/open_dispute_sheet.dart';
import '../logic/prestataire_reservation_actions.dart';
import '../models/prestataire_reservation_item.dart';
import '../providers/agenda/prestataire_agenda_provider.dart';
import '../../messaging/messaging_navigation.dart';
import '../../messaging/models/messaging_inbox_role.dart';
import '../../messaging/widgets/send_result_media_sheet.dart';
import '../../../services/supabase/relations/client_prestataire_relation_providers.dart';
import '../providers/profile/current_prestataire_provider.dart';
import '../widgets/agenda/prestataire_reservation_detail_body.dart';
import '../widgets/workspace/layout/prestataire_brand_scaffold.dart';
import '../widgets/workspace/prestataire_flow_scaffold.dart';

class PrestataireReservationDetailScreen extends ConsumerStatefulWidget {
  const PrestataireReservationDetailScreen({
    super.key,
    required this.reservationId,
  });

  final String reservationId;

  @override
  ConsumerState<PrestataireReservationDetailScreen> createState() =>
      _PrestataireReservationDetailScreenState();
}

class _PrestataireReservationDetailScreenState
    extends ConsumerState<PrestataireReservationDetailScreen> {
  bool _acting = false;

  PrestataireReservationItem? _findItem(List<PrestataireReservationItem> all) {
    for (final item in all) {
      if (item.id == widget.reservationId) return item;
    }
    return null;
  }

  PrestataireReservationActions get _actions =>
      PrestataireReservationActions(ref, context);

  Future<void> _runAction(Future<bool> Function() action) async {
    setState(() => _acting = true);
    final ok = await action();
    if (mounted) setState(() => _acting = false);
    if (ok && mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final agendaAsync = ref.watch(prestataireAgendaProvider);

    return PrestataireFlowScaffold(
      appBar: prestataireBrandAppBar(
        context: context,
        title: const Text(DiscPrestaReservation.detailTitle),
      ),
      body: agendaAsync.when(
        loading: () => const DiscoveryDetailSkeleton(),
        error: (_, __) => Center(
          child: DiscoveryEmptyState(
            icon: Icons.cloud_off_outlined,
            title: CoreStrings.networkErrorTitle,
            body: DiscPrestaAgenda.loadErr,
            iconColor: theme.colorScheme.error,
            actionLabel: DiscList.retry,
            onAction: () => ref.invalidate(prestataireAgendaProvider),
          ),
        ),
        data: (reservations) {
          final item = _findItem(reservations);
          if (item == null) {
            return Center(
              child: DiscoveryEmptyState(
                icon: Icons.event_busy_outlined,
                title: DiscPrestaReservation.notFoundTitle,
                body: DiscPrestaReservation.notFoundBody,
                iconColor: theme.colorScheme.onSurfaceVariant,
              ),
            );
          }

          final activeDisputeAsync =
              ref.watch(activeDisputeForReservationProvider(item.id));
          final activeDispute = activeDisputeAsync.asData?.value;
          final prestaId = ref
              .watch(currentPrestataireProvider)
              .maybeWhen(data: (p) => p?.id, orElse: () => null);
          final isVip = item.clientId != null &&
                  prestaId != null
              ? ref
                  .watch(
                    isClientVipForPairProvider((
                      clientId: item.clientId!,
                      prestataireId: prestaId,
                    )),
                  )
                  .maybeWhen(data: (v) => v, orElse: () => false)
              : false;

          return PrestataireReservationDetailBody(
            item: item,
            busy: _acting,
            isClientVip: isVip,
            hasActiveDispute: activeDispute != null,
            onMessage: () => openChatForReservation(
              context,
              ref,
              item.id,
              viewerRole: MessagingInboxRole.prestataire,
            ),
            onSendResultMedia: () => showSendResultMediaSheet(
              context,
              ref,
              reservationId: item.id,
            ),
            onOpenDispute: () => showOpenDisputeSheet(
              context,
              reservationId: item.id,
              viewerRole: DisputeSenderRole.prestataire,
            ),
            onViewDispute: activeDispute == null
                ? null
                : () => context.pushPrestataireDisputeDetail(activeDispute.id),
            onAccept: () => _runAction(() => _actions.accept(item.id)),
            onReject: () => _runAction(() => _actions.reject(item.id)),
            onMarkDone: () => _runAction(() => _actions.markDone(item)),
          );
        },
      ),
    );
  }
}

