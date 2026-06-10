import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/logic/booking/booking_create_failure.dart';

/// Résolution client / prestataire connecté pour les opérations booking.
class BookingSessionContext {
  BookingSessionContext(this._client);

  final SupabaseClient _client;

  Future<String> requireClientId() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw const BookingNotAuthenticatedFailure();

    final response = await _client
        .from('client_profiles')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();
    if (response == null) throw const BookingClientProfileMissingFailure();
    return Map<String, dynamic>.from(response)['id'] as String;
  }

  Future<String> requirePrestataireId() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw const BookingNotAuthenticatedFailure();

    final response = await _client
        .from('prestataire_profiles')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();
    if (response == null) {
      throw AppFailure(DiscBk.errPrestaProfile);
    }
    return Map<String, dynamic>.from(response)['id'] as String;
  }

  Future<void> rejectIfBookingOwnPrestataire(String prestataireId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final response = await _client
        .from('prestataire_profiles')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();
    if (response == null) return;

    final ownId = Map<String, dynamic>.from(response)['id'] as String?;
    if (ownId != null && ownId == prestataireId.trim()) {
      throw const BookingCannotReserveOwnServiceFailure();
    }
  }
}
