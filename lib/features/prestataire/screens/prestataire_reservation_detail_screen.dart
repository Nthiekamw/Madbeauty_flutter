import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/discovery_empty_state.dart';
import '../logic/prestataire_reservation_actions.dart';
import '../models/prestataire_reservation_item.dart';
import '../providers/prestataire_agenda_provider.dart';
import '../widgets/prestataire_reservation_detail_body.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text(DiscPrestaReservation.detailTitle),
      ),
      body: agendaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: DiscoveryEmptyState(
            icon: Icons.cloud_off_outlined,
            title: DiscPrestaAgenda.loadErr,
            body: DiscList.pullDownHint,
            iconColor: theme.colorScheme.error,
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

          return PrestataireReservationDetailBody(
            item: item,
            busy: _acting,
            onAccept: () => _runAction(() => _actions.accept(item.id)),
            onReject: () => _runAction(() => _actions.reject(item.id)),
            onMarkDone: () => _runAction(() => _actions.markDone(item.id)),
          );
        },
      ),
    );
  }
}
