import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/supabase_error_handler.dart';
import '../location/geocoding_service.dart';
import '../supabase/supabase_service.dart';

/// Complète les profils après inscription (user_profiles, client / prestataire).
class PostSignupProfileService {
  PostSignupProfileService(this._client, {GeocodingService? geocoding})
      : _geocoding = geocoding ?? GeocodingService();

  final SupabaseClient _client;
  final GeocodingService _geocoding;

  factory PostSignupProfileService.fromEnv() =>
      PostSignupProfileService(SupabaseService.client);

  Future<void> updateUserIdentity({
    required String userId,
    required String prenom,
    required String nom,
    String? phone,
  }) {
    return SupabaseErrorHandler.run(
      operation: 'postSignup.updateUserIdentity',
      action: () async {
        await _client.from('user_profiles').upsert({
          'user_id': userId,
          'nom': nom.trim().isEmpty ? null : nom.trim(),
          'prenom': prenom.trim().isEmpty ? null : prenom.trim(),
          if (phone != null && phone.trim().isNotEmpty)
            'telephone': phone.trim(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }, onConflict: 'user_id');
      },
    );
  }

  Future<void> updateClientExtras({
    required String userId,
    String? adresse,
  }) {
    return SupabaseErrorHandler.run(
      operation: 'postSignup.updateClientExtras',
      action: () async {
        await _client.from('client_profiles').update({
          if (adresse != null && adresse.trim().isNotEmpty)
            'adresse': adresse.trim(),
        }).eq('user_id', userId);
      },
    );
  }

  Future<void> updatePrestataireExtras({
    required String userId,
    required String nomSalon,
    required String ville,
    String? bio,
  }) {
    return SupabaseErrorHandler.run(
      operation: 'postSignup.updatePrestataireExtras',
      action: () async {
        final coords = await _geocoding.geocodeAddress(ville);
        await _client.from('prestataire_profiles').update({
          'nom_salon': nomSalon.trim(),
          'ville': ville.trim(),
          if (bio != null && bio.trim().isNotEmpty) 'bio': bio.trim(),
          if (coords != null) ...{
            'latitude': coords.latitude,
            'longitude': coords.longitude,
          },
        }).eq('user_id', userId);
      },
    );
  }
}
