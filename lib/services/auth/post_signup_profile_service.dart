import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_strings.dart';
import '../../core/errors/app_failure.dart';
import '../../core/logic/address/postal_address.dart';
import '../../core/errors/supabase_error_handler.dart';
import '../../core/models/domain/user/lieu_travail.dart';
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
        await _client.from('user_profiles').upsert(
          {
            'user_id': userId,
            'nom': nom.trim().isEmpty ? null : nom.trim(),
            'prenom': prenom.trim().isEmpty ? null : prenom.trim(),
            if (phone != null && phone.trim().isNotEmpty)
              'telephone': phone.trim(),
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          },
          onConflict: 'user_id',
        );
      },
    );
  }

  Future<void> updateClientExtras({
    required String userId,
    required PostalAddress address,
  }) {
    return SupabaseErrorHandler.run(
      operation: 'postSignup.updateClientExtras',
      action: () async {
        final formatted = address.formattedLine.trim();
        final city = address.ville.trim();
        final postalCode = address.codePostal.trim();
        final country = address.pays.trim();
        final query = [
          if (address.streetLine.trim().isNotEmpty) address.streetLine.trim(),
          if (postalCode.isNotEmpty) postalCode,
          if (city.isNotEmpty) city,
        ].join(', ');
        final coords = query.isEmpty
            ? null
            : await _geocoding.geocodeAddress(
                query,
                countryIsoCode: country,
              );
        await _client.from('client_profiles').update({
          'adresse': formatted.isEmpty ? null : formatted,
          'ville': city.isEmpty ? null : city,
          'code_postal': postalCode.isEmpty ? null : postalCode,
          'pays': country.isEmpty ? null : _normalizeCountryIso2(country),
          'voie_type': address.voieType.trim().isEmpty
              ? null
              : address.voieType.trim(),
          'voie_nom': address.voieNom.trim().isEmpty
              ? null
              : address.voieNom.trim(),
          'numero_rue': address.numero.trim().isEmpty
              ? null
              : address.numero.trim(),
          'latitude': coords?.latitude,
          'longitude': coords?.longitude,
        }).eq('user_id', userId);
      },
    );
  }

  Future<void> updatePrestataireExtras({
    required String userId,
    required String nomSalon,
    required String ville,
    String? adresse,
    String? codePostal,
    String? pays,
    String? nomAffiche,
    LieuTravail? lieuTravail,
    String? bio,
    String? description,
    String? anneesExperience,
    String? experienceProfessionnelle,
  }) {
    return SupabaseErrorHandler.run(
      operation: 'postSignup.updatePrestataireExtras',
      action: () async {
        final countryIso2 = _normalizeCountryIso2(pays);
        final geoQuery = _geocodeQuery(
          adresse: adresse,
          codePostal: codePostal,
          ville: ville,
        );
        final coords = await _geocoding.geocodeAddress(
          geoQuery,
          countryIsoCode: countryIso2,
        );
        if (geoQuery.trim().isNotEmpty && coords == null) {
          throw const AppFailure(AuthStrings.registerValidationAddressNotFound);
        }
        await _client.from('prestataire_profiles').upsert({
          'user_id': userId,
          'nom_salon': nomSalon.trim(),
          'ville': ville.trim(),
          if (adresse != null && adresse.trim().isNotEmpty)
            'adresse': adresse.trim(),
          if (codePostal != null && codePostal.trim().isNotEmpty)
            'code_postal': codePostal.trim(),
          if (countryIso2 != null) 'pays': countryIso2,
          if (nomAffiche != null && nomAffiche.trim().isNotEmpty)
            'nom_affiche': nomAffiche.trim(),
          if (lieuTravail != null) 'lieu_travail': lieuTravail.value,
          if (bio != null && bio.trim().isNotEmpty) 'bio': bio.trim(),
          if (description != null && description.trim().isNotEmpty)
            'description': description.trim(),
          if (anneesExperience != null && anneesExperience.trim().isNotEmpty)
            'annees_experience': anneesExperience.trim(),
          if (experienceProfessionnelle != null &&
              experienceProfessionnelle.trim().isNotEmpty)
            'experience_professionnelle': experienceProfessionnelle.trim(),
          if (coords != null) ...{
            'latitude': coords.latitude,
            'longitude': coords.longitude,
          },
        }, onConflict: 'user_id');
      },
    );
  }

  static String _geocodeQuery({
    String? adresse,
    String? codePostal,
    required String ville,
  }) {
    final parts = <String>[
      if (adresse != null && adresse.trim().isNotEmpty) adresse.trim(),
      if (codePostal != null && codePostal.trim().isNotEmpty) codePostal.trim(),
      if (ville.trim().isNotEmpty) ville.trim(),
    ];
    return parts.isEmpty ? ville.trim() : parts.join(', ');
  }

  static String? _normalizeCountryIso2(String? raw) {
    final value = raw?.trim();
    if (value == null || value.isEmpty) return null;
    final upper = value.toUpperCase();
    if (upper.length == 2) return upper;
    return switch (upper) {
      'FRANCE' => 'FR',
      'BELGIQUE' => 'BE',
      'BELGIUM' => 'BE',
      'LUXEMBOURG' => 'LU',
      'SUISSE' => 'CH',
      'SWITZERLAND' => 'CH',
      _ => null,
    };
  }
}

