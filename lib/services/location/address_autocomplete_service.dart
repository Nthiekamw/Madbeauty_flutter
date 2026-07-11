import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../core/config/market_config.dart';
import '../../core/geo/geo_point.dart';
import '../../core/logic/address/address_search_query_parser.dart';
import '../../core/logic/address/postal_address.dart';
import '../../core/logic/address/postal_country_format.dart';
import '../../core/logic/address/postal_address_suggestion.dart';

/// Autocomplétion d'adresses par pays (sources gratuites / open data).
class AddressAutocompleteService {
  AddressAutocompleteService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  static const _nominatimUserAgent = 'MadBeauty/1.0 (address-autocomplete)';
  static const _bestBaseUrl =
      'https://best.pr.fedservices.be/api/opendata/best/v1/belgianAddress/v2/addresses';
  static const _banEndpoint = 'https://api-adresse.data.gouv.fr/search/';
  static const _canadaLocateBase =
      'https://geogratis.gc.ca/services/geolocation/fr/locate';
  static const _nominatimSearch = 'https://nominatim.openstreetmap.org/search';

  /// Recherche selon le pays ISO (FR, BE, CA, …).
  Future<List<PostalAddressSuggestion>> searchAddresses(
    String query, {
    required String countryIsoCode,
    int limit = 5,
  }) async {
    final country = MarketConfig.normalizeCountryCode(countryIsoCode);
    return switch (country) {
      'FR' => searchFrenchAddresses(query, limit: limit),
      'BE' => _searchBelgianAddresses(query, limit: limit),
      'CA' => _searchCanadianAddresses(query, limit: limit),
      _ => _searchNominatimAddresses(
        query,
        countryIso: country,
        limit: limit,
      ),
    };
  }

  Future<List<PostalAddressSuggestion>> searchFrenchAddresses(
    String query, {
    int limit = 5,
  }) async {
    final trimmed = query.trim();
    if (trimmed.length < 4) return const [];

    final uri = Uri.parse(_banEndpoint).replace(
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
      final suggestion = _parseBanFeature(raw);
      if (suggestion != null) suggestions.add(suggestion);
    }
    return suggestions;
  }

  Future<List<PostalAddressSuggestion>> _searchBelgianAddresses(
    String query, {
    required int limit,
  }) async {
    final trimmed = query.trim();
    if (trimmed.length < 4) return const [];

    final parsed = AddressSearchQueryParser.parseBelgian(trimmed);
    if (parsed.isEmpty) return const [];

    final params = <String, String>{
      'pageSize': '$limit',
      'status': 'current',
    };
    if (parsed.postCode != null) params['postCode'] = parsed.postCode!;
    if (parsed.houseNumber != null) params['houseNumber'] = parsed.houseNumber!;
    if (parsed.streetNamePattern != null) {
      params['streetName'] = parsed.streetNamePattern!;
    }
    if (parsed.municipalityName != null) {
      params['municipalityName'] = parsed.municipalityName!;
    }

    final uri = Uri.parse(_bestBaseUrl).replace(queryParameters: params);
    final response = await _client
        .get(uri, headers: const {'accept': 'application/json'})
        .timeout(AppConfig.supabaseHttpTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('BeSt HTTP ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return const [];
    final items = decoded['items'];
    if (items is! List) return const [];

    final suggestions = <PostalAddressSuggestion>[];
    for (final raw in items) {
      final suggestion = _parseBestItem(raw);
      if (suggestion != null) suggestions.add(suggestion);
    }
    return suggestions;
  }

  Future<List<PostalAddressSuggestion>> _searchCanadianAddresses(
    String query, {
    required int limit,
  }) async {
    final trimmed = query.trim();
    if (trimmed.length < 4) return const [];

    final fromNrc = await _searchCanadaNrcLocate(trimmed, limit: limit);
    if (fromNrc.length >= limit) return fromNrc.take(limit).toList();

    final fromNominatim = await _searchNominatimAddresses(
      trimmed,
      countryIso: 'CA',
      limit: limit,
    );

    final seen = fromNrc.map((s) => s.label.toLowerCase()).toSet();
    final merged = [...fromNrc];
    for (final item in fromNominatim) {
      if (merged.length >= limit) break;
      if (seen.add(item.label.toLowerCase())) merged.add(item);
    }
    return merged;
  }

  Future<List<PostalAddressSuggestion>> _searchCanadaNrcLocate(
    String query, {
    required int limit,
  }) async {
    try {
      final uri = Uri.parse(_canadaLocateBase).replace(
        queryParameters: {'q': query},
      );
      final response = await _client
          .get(uri, headers: const {'accept': 'application/json'})
          .timeout(AppConfig.supabaseHttpTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return const [];
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) return const [];

      final suggestions = <PostalAddressSuggestion>[];
      for (final raw in decoded) {
        if (suggestions.length >= limit) break;
        final suggestion = _parseCanadaNrcItem(raw);
        if (suggestion != null) suggestions.add(suggestion);
      }
      return suggestions;
    } on Object {
      return const [];
    }
  }

  Future<List<PostalAddressSuggestion>> _searchNominatimAddresses(
    String query, {
    required String countryIso,
    required int limit,
  }) async {
    try {
      final uri = Uri.parse(_nominatimSearch).replace(
        queryParameters: {
          'q': query,
          'format': 'json',
          'addressdetails': '1',
          'countrycodes': countryIso.toLowerCase(),
          'limit': '$limit',
        },
      );
      final response = await _client
          .get(
            uri,
            headers: const {
              'accept': 'application/json',
              'User-Agent': _nominatimUserAgent,
            },
          )
          .timeout(AppConfig.supabaseHttpTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return const [];
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) return const [];

      final suggestions = <PostalAddressSuggestion>[];
      for (final raw in decoded) {
        final suggestion = _parseNominatimItem(raw, countryIso: countryIso);
        if (suggestion != null) suggestions.add(suggestion);
      }
      return suggestions;
    } on Object {
      return const [];
    }
  }

  PostalAddressSuggestion? _parseBanFeature(Object? raw) {
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

    return PostalAddressSuggestion(
      label: label,
      score: score,
      source: 'ban',
      location: _geoPointFromGeoJson(raw['geometry']),
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

  PostalAddressSuggestion? _parseBestItem(Object? raw) {
    if (raw is! Map<String, dynamic>) return null;

    final houseNumber = (raw['houseNumber'] as String?)?.trim() ?? '';
    final streetMap = raw['hasStreetName'];
    final streetName = _localizedName(
      streetMap is Map<String, dynamic> ? streetMap['name'] : null,
    );
    if (streetName.isEmpty) return null;

    final municipalityMap = raw['hasMunicipality'];
    final municipality = _localizedName(
      municipalityMap is Map<String, dynamic>
          ? municipalityMap['name']
          : null,
    );

    final postalMap = raw['hasPostalInfo'];
    final postCode = postalMap is Map<String, dynamic>
        ? (postalMap['postCode'] as String?)?.trim() ?? ''
        : '';

    final streetLine = [
      if (houseNumber.isNotEmpty) houseNumber,
      streetName,
    ].join(' ');
    final parsedStreet = PostalAddress.tryParse(streetLine);

    final labelParts = <String>[
      streetLine,
      if (postCode.isNotEmpty && municipality.isNotEmpty)
        '$postCode $municipality'
      else if (municipality.isNotEmpty)
        municipality
      else if (postCode.isNotEmpty)
        postCode,
    ];

    GeoPoint? point;
    final position = raw['addressPosition'];
    if (position is Map<String, dynamic>) {
      final wgs84 = position['wgs84'];
      if (wgs84 is Map<String, dynamic>) {
        final lat = (wgs84['lat'] as num?)?.toDouble();
        final lon = (wgs84['long'] as num?)?.toDouble();
        if (lat != null && lon != null) {
          point = GeoPoint(latitude: lat, longitude: lon);
        }
      }
    }

    return PostalAddressSuggestion(
      label: labelParts.join(', '),
      source: 'best',
      location: point,
      address: PostalAddress(
        voieType: parsedStreet.voieType,
        voieNom: parsedStreet.voieNom,
        numero: houseNumber.isNotEmpty ? houseNumber : parsedStreet.numero,
        codePostal: postCode,
        ville: municipality,
        pays: postalCountryLabelForIso('BE'),
      ),
    );
  }

  PostalAddressSuggestion? _parseCanadaNrcItem(Object? raw) {
    if (raw is! Map<String, dynamic>) return null;

    final type = (raw['type'] as String?) ?? '';
    if (type.contains('Intersection')) return null;

    final title = (raw['title'] as String?)?.trim() ?? '';
    if (title.isEmpty || title.contains(' & ')) return null;

    final parts = title
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return null;

    final streetPart = parts.first;
    if (!RegExp(r'^\d+\s').hasMatch(streetPart) &&
        !type.contains('Street')) {
      return null;
    }

    final city = parts.length >= 2 ? parts[parts.length - 2] : '';
    final parsedStreet = PostalAddress.tryParse(streetPart);

    return PostalAddressSuggestion(
      label: title,
      source: 'nrcan',
      location: _geoPointFromGeoJson(raw['geometry']),
      address: PostalAddress(
        voieType: parsedStreet.voieType,
        voieNom: parsedStreet.voieNom,
        numero: parsedStreet.numero,
        codePostal: AddressSearchQueryParser.parseCanadianPostalCode(title) ?? '',
        ville: city,
        pays: postalCountryLabelForIso('CA'),
      ),
    );
  }

  PostalAddressSuggestion? _parseNominatimItem(
    Object? raw, {
    required String countryIso,
  }) {
    if (raw is! Map<String, dynamic>) return null;

    final label = (raw['display_name'] as String?)?.trim() ?? '';
    if (label.isEmpty) return null;

    final address = raw['address'];
    if (address is! Map<String, dynamic>) return null;

    final houseNumber = (address['house_number'] as String?)?.trim() ?? '';
    final road = (address['road'] as String?)?.trim() ?? '';
    if (road.isEmpty) return null;

    final city = _firstNonEmpty([
      address['city'] as String?,
      address['town'] as String?,
      address['village'] as String?,
      address['municipality'] as String?,
    ]);
    final postCode = (address['postcode'] as String?)?.trim() ?? '';

    final streetLine = [
      if (houseNumber.isNotEmpty) houseNumber,
      road,
    ].join(' ');
    final parsedStreet = PostalAddress.tryParse(streetLine);

    final lat = double.tryParse('${raw['lat']}');
    final lon = double.tryParse('${raw['lon']}');
    final point = lat != null && lon != null
        ? GeoPoint(latitude: lat, longitude: lon)
        : null;

    return PostalAddressSuggestion(
      label: label,
      source: 'nominatim',
      location: point,
      address: PostalAddress(
        voieType: parsedStreet.voieType,
        voieNom: parsedStreet.voieNom,
        numero: houseNumber.isNotEmpty ? houseNumber : parsedStreet.numero,
        codePostal: postCode,
        ville: city,
        pays: postalCountryLabelForIso(countryIso),
      ),
    );
  }

  static String _localizedName(Object? raw) {
    if (raw is! Map<String, dynamic>) return '';
    for (final key in ['fr', 'nl', 'de', 'en']) {
      final value = raw[key] as String?;
      if (value != null && value.trim().isNotEmpty) return value.trim();
    }
    for (final value in raw.values) {
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return '';
  }

  static String _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    }
    return '';
  }

  static GeoPoint? _geoPointFromGeoJson(Object? geometry) {
    if (geometry is! Map<String, dynamic>) return null;
    final coordinates = geometry['coordinates'];
    if (coordinates is! List || coordinates.length < 2) return null;
    final lon = (coordinates[0] as num?)?.toDouble();
    final lat = (coordinates[1] as num?)?.toDouble();
    if (lat == null || lon == null) return null;
    return GeoPoint(latitude: lat, longitude: lon);
  }
}
