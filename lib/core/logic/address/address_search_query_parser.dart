/// Paramètres extraits d'une recherche libre (Belgique).
class BelgianAddressSearchQuery {
  const BelgianAddressSearchQuery({
    this.postCode,
    this.houseNumber,
    this.streetNamePattern,
    this.municipalityName,
  });

  final String? postCode;
  final String? houseNumber;
  final String? streetNamePattern;
  final String? municipalityName;

  bool get isEmpty =>
      (postCode == null || postCode!.isEmpty) &&
      (houseNumber == null || houseNumber!.isEmpty) &&
      (streetNamePattern == null || streetNamePattern!.isEmpty) &&
      (municipalityName == null || municipalityName!.isEmpty);
}

abstract final class AddressSearchQueryParser {
  AddressSearchQueryParser._();

  static BelgianAddressSearchQuery parseBelgian(String raw) {
    var query = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (query.isEmpty) return const BelgianAddressSearchQuery();

    final postCode = RegExp(r'\b(\d{4})\b').firstMatch(query)?.group(1);
    if (postCode != null) {
      query = query.replaceAll(postCode, ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    }

    String? houseNumber;
    final houseMatch = RegExp(
      r'^(\d+[a-zA-Z]?(?:/\d+[a-zA-Z]?)?)\b',
    ).firstMatch(query);
    if (houseMatch != null) {
      houseNumber = houseMatch.group(1);
      query = query.substring(houseMatch.end).trim();
    }

    String? municipality;
    if (query.contains(',')) {
      final parts = query
          .split(',')
          .map((part) => part.trim())
          .where((part) => part.isNotEmpty)
          .toList();
      if (parts.length >= 2) {
        municipality = parts.last;
        query = parts.sublist(0, parts.length - 1).join(' ').trim();
      }
    } else if (postCode != null) {
      final tokens = query.split(' ').where((token) => token.isNotEmpty).toList();
      if (tokens.length >= 2 && _isLikelyMunicipality(tokens.last)) {
        municipality = tokens.removeLast();
        query = tokens.join(' ').trim();
      }
    }

    final streetNeedle = query.trim();
    String? streetPattern;
    if (streetNeedle.isNotEmpty) {
      streetPattern = streetNeedle.contains('*') ? streetNeedle : '*$streetNeedle*';
    }

    return BelgianAddressSearchQuery(
      postCode: postCode,
      houseNumber: houseNumber,
      streetNamePattern: streetPattern,
      municipalityName: municipality,
    );
  }

  /// Extrait code postal canadien (A1A 1A1) d'une recherche libre.
  static String? parseCanadianPostalCode(String raw) {
    final match = RegExp(
      r'\b([A-Za-z]\d[A-Za-z][ -]?\d[A-Za-z]\d)\b',
    ).firstMatch(raw);
    return match?.group(1)?.toUpperCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  static bool _isLikelyMunicipality(String token) {
    final value = token.trim();
    if (value.length < 3) return false;
    return RegExp(r'^[A-Za-z\u00C0-\u024F][A-Za-z\u00C0-\u024F\- ]*$').hasMatch(value);
  }
}
