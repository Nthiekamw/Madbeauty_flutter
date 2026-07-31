import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../supabase_service.dart';
import 'dispute_service.dart';

final disputeServiceProvider = Provider<DisputeService?>((ref) {
  if (!AppConfig.hasSupabase) return null;
  return DisputeService(SupabaseService.client);
});

final myDisputesProvider =
    FutureProvider.autoDispose<List<BookingDispute>>((ref) async {
  final service = ref.watch(disputeServiceProvider);
  if (service == null) return const [];
  return service.listMine();
});

final disputeByIdProvider =
    FutureProvider.autoDispose.family<BookingDispute?, String>((ref, id) async {
  final service = ref.watch(disputeServiceProvider);
  if (service == null) return null;
  return service.getById(id);
});

final activeDisputeForReservationProvider =
    FutureProvider.autoDispose.family<BookingDispute?, String>((ref, reservationId) async {
  final service = ref.watch(disputeServiceProvider);
  if (service == null) return null;
  return service.findActiveForReservation(reservationId);
});

final disputeMessagesProvider =
    FutureProvider.autoDispose.family<List<DisputeMessage>, String>((ref, disputeId) async {
  final service = ref.watch(disputeServiceProvider);
  if (service == null) return const [];
  return service.listMessages(disputeId);
});

enum AdminDisputeFilter { open, all }

final adminDisputesProvider = FutureProvider.autoDispose
    .family<List<BookingDispute>, AdminDisputeFilter>((ref, filter) async {
  final service = ref.watch(disputeServiceProvider);
  if (service == null) return const [];
  return service.adminList(openOnly: filter == AdminDisputeFilter.open);
});
