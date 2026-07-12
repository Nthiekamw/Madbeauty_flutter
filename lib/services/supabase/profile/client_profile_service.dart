import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/market_config.dart';
import '../../../core/errors/supabase_error_handler.dart';
import '../../../core/logic/address/postal_address.dart';
import '../../../core/logic/address/postal_country_format.dart';
import '../../../core/models/domain/serialization/supabase_domain_codec.dart';
import '../../../core/models/domain/user/client_profile.dart';
import '../../location/geocoding_service.dart';

class ClientProfileService {
  ClientProfileService(this._client, {GeocodingService? geocoding})
    : _geocoding = geocoding ?? GeocodingService();

  final SupabaseClient _client;
  final GeocodingService _geocoding;

  Future<ClientProfile?> getByUserId(String userId) => SupabaseErrorHandler.run(
        operation: 'clientProfile.getByUserId',
        action: () async {
          final response = await _client
              .from('client_profiles')
              .select()
              .eq('user_id', userId)
              .maybeSingle();
          if (response == null) return null;
          return SupabaseDomainCodec.clientProfile(
            Map<String, dynamic>.from(response),
          );
        },
      );

  Future<ClientProfile> ensureForUserId(String userId) =>
      SupabaseErrorHandler.run(
        operation: 'clientProfile.ensureForUserId',
        action: () async {
          final existing = await getByUserId(userId);
          if (existing != null) return existing;

          await _client.from('client_profiles').insert({'user_id': userId});

          final created = await getByUserId(userId);
          if (created == null) {
            throw StateError('Impossible de créer le profil client.');
          }
          return created;
        },
      );

  Future<void> updateAddress({
    required String userId,
    required PostalAddress address,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'clientProfile.updateAddress',
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
                  countryIsoCode: postalCountryIso2(country),
                );
          await _client.from('client_profiles').update({
            'adresse': formatted.isEmpty ? null : formatted,
            'ville': city.isEmpty ? null : city,
            'code_postal': postalCode.isEmpty ? null : postalCode,
            'pays': _normalizeCountryIso2(country),
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

  static String? _normalizeCountryIso2(String? raw) {
    final value = raw?.trim();
    if (value == null || value.isEmpty) return null;
    final code = MarketConfig.normalizeCountryCode(value);
    return MarketConfig.isSupported(code) ? code : null;
  }
}

