import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../core/geo/geo_point.dart';
import '../../core/logic/address/postal_address.dart';
import '../../core/logic/address/postal_address_suggestion.dart';

/// Recherche d'adresses réelles via la Base Adresse Nationale (France).
class AddressAutocompleteService {
  AddressAutocompleteService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  static final Uri _endpoint = Uri.parse(
    'https://api-adresse.data.gouv.fr/search/',
  );

  Future<List<PostalAddressSuggestion>> searchFrenchAddresses(
    String query, {
    int limit = 5,
  }) async {
    final trimmed = query.trim();
    if (trimmed.length < 4) return const [];

    final uri = _endpoint.replace(
      queryParameters: {
        'q': trimmed,
        'limit': '$limit',
        'autocomplete': '1',
        'type': 'housenumber',
      },
    );

    final response = await _client
        .get(uri, headers: const {'accept': 'application/json'})
        .timeout(AppConfig.supabaseHttpTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('BAN HTTP ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return const [];
    final features = decoded['features'];
    if (features is! List) return const [];

    final suggestions = <PostalAddressSuggestion>[];
    for (final raw in features) {
      final suggestion = _parseFeature(raw);
      if (suggestion != null) suggestions.add(suggestion);
    }
    return suggestions;
  }

  PostalAddressSuggestion? _parseFeature(Object? raw) {
    if (raw is! Map<String, dynamic>) return null;
    final props = raw['properties'];
    if (props is! Map<String, dynamic>) return null;

    final street = (props['street'] as String?)?.trim() ?? '';
    final houseNumber = (props['housenumber'] as String?)?.trim() ?? '';
    final city = (props['city'] as String?)?.trim() ?? '';
    final postcode = (props['postcode'] as String?)?.trim() ?? '';
    final label = (props['label'] as String?)?.trim() ?? '';
    final score = (props['score'] as num?)?.toDouble();
    if (label.isEmpty || street.isEmpty || city.isEmpty) return null;

    final parsedStreet = PostalAddress.tryParse(
      [if (houseNumber.isNotEmpty) houseNumber, street].join(' '),
    );

    GeoPoint? point;
    final geometry = raw['geometry'];
    if (geometry is Map<String, dynamic>) {
      final coordinates = geometry['coordinates'];
      if (coordinates is List && coordinates.length >= 2) {
        final lng = (coordinates[0] as num?)?.toDouble();
        final lat = (coordinates[1] as num?)?.toDouble();
        if (lat != null && lng != null) {
          point = GeoPoint(latitude: lat, longitude: lng);
        }
      }
    }

    return PostalAddressSuggestion(
      label: label,
      score: score,
      source: 'ban',
      location: point,
      address: PostalAddress(
        voieType: parsedStreet.voieType,
        voieNom: parsedStreet.voieNom,
        numero: houseNumber.isNotEmpty ? houseNumber : parsedStreet.numero,
        codePostal: postcode,
        ville: city,
        pays: PostalAddress.defaultCountry,
      ),
    );
  }
}
