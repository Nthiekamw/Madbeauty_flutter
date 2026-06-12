import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/supabase/profile/client_profile_providers.dart';
import '../../../services/supabase/supabase_service.dart';

/// Nombre de réservations client (hors annulées) — pour le seuil frais 1 €.
final clientPriorBookingCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final client = await ref.watch(currentClientProfileProvider.future);
  if (client == null) return 0;

  final response = await SupabaseService.client
      .from('reservations')
      .select('id')
      .eq('client_id', client.id)
      .not('statut', 'in', '(annulee,cancelled)');

  final rows = response as List;
  return rows.length;
});
