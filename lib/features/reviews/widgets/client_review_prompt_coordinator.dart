import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../features/auth/guest/guest_mode_provider.dart';
import '../../../features/booking/logic/client_reservation_ui_status.dart';
import '../../../features/booking/models/client_reservation_summary.dart';
import '../../../services/storage/review_prompt_store.dart';
import '../../../services/supabase/booking/booking_service_providers.dart';
import '../../../services/supabase/profile/client_profile_providers.dart';
import '../../../services/supabase/supabase_service.dart';
import '../providers/prestataire_note_moyenne_provider.dart';
import '../providers/review_provider.dart';
import 'create_review_sheet.dart';

/// Affiche automatiquement l'écran de notation après une prestation terminée.
class ClientReviewPromptCoordinator extends ConsumerStatefulWidget {
  const ClientReviewPromptCoordinator({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ClientReviewPromptCoordinator> createState() =>
      _ClientReviewPromptCoordinatorState();
}

class _ClientReviewPromptCoordinatorState
    extends ConsumerState<ClientReviewPromptCoordinator> {
  bool _sheetOpen = false;
  RealtimeChannel? _reservationsChannel;
  String? _subscribedClientId;

  @override
  void dispose() {
    unawaited(_unsubscribeReservations());
    super.dispose();
  }

  Future<void> _unsubscribeReservations() async {
    final ch = _reservationsChannel;
    _reservationsChannel = null;
    _subscribedClientId = null;
    if (ch != null && AppConfig.hasSupabase) {
      await SupabaseService.client.removeChannel(ch);
    }
  }

  Future<void> _subscribeReservations(String clientProfileId) async {
    if (!AppConfig.hasSupabase) return;
    if (_subscribedClientId == clientProfileId) return;
    await _unsubscribeReservations();
    _subscribedClientId = clientProfileId;

    _reservationsChannel = SupabaseService.client
        .channel('client-reservations-$clientProfileId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'reservations',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'client_id',
            value: clientProfileId,
          ),
          callback: (_) {
            ref.invalidate(clientReservationsProvider);
            ref.invalidate(clientPendingReservationsCountProvider);
          },
        )
        .subscribe();
  }

  Future<void> _maybePrompt(List<ClientReservationSummary> list) async {
    if (_sheetOpen || !mounted || ref.read(isGuestBrowsingProvider)) return;

    final handled = ReviewPromptStore.instance.handledBookingIds;
    final service = ref.read(reviewServiceProvider);
    if (service == null) return;

    for (final item in list) {
      final ui = clientReservationUiStatusFromStatut(item.statut);
      if (ui != ClientReservationUiStatus.done) continue;
      if (handled.contains(item.id)) continue;

      final reviewed = await service.hasReviewed(item.id);
      if (!mounted) return;
      if (reviewed) {
        await ReviewPromptStore.instance.markHandled(item.id);
        continue;
      }

      _sheetOpen = true;
      final name = item.prestataireName?.trim().isNotEmpty == true
          ? item.prestataireName!.trim()
          : 'Prestataire';

      final submitted = await showCreateReviewSheet(
        context,
        bookingId: item.id,
        prestataireName: name,
        prestataireId: item.prestataireId,
      );

      _sheetOpen = false;
      if (!mounted) return;

      await ReviewPromptStore.instance.markHandled(item.id);
      if (submitted == true && item.prestataireId != null) {
        ref.invalidate(reviewsByPrestataireProvider(item.prestataireId!));
        ref.invalidate(prestataireNoteMoyenneProvider(item.prestataireId!));
      }
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(isGuestBrowsingProvider)) {
      final clientAsync = ref.watch(currentClientProfileProvider);
      clientAsync.whenData((client) {
        if (client != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            unawaited(_subscribeReservations(client.id));
          });
        }
      });
    }

    ref.listen(reservationsRefreshSignalProvider, (_, __) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.invalidate(clientReservationsProvider);
      });
    });

    ref.listen(clientReservationsProvider, (prev, next) {
      next.whenData((list) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          unawaited(_maybePrompt(list));
        });
      });
    });

    return widget.child;
  }
}

