/// Adresse postale structurée (inscription client / prestataire).
class PostalAddress {
  const PostalAddress({
    this.voieType = PostalVoieTypes.defaultType,
    this.voieNom = '',
    this.numero = '',
    this.codePostal = '',
    this.ville = '',
    this.pays = PostalAddress.defaultCountry,
  });

  static const defaultCountry = 'France';

  final String voieType;
  final String voieNom;
  final String numero;
  final String codePostal;
  final String ville;
  final String pays;

  bool get isEmpty =>
      voieNom.trim().isEmpty &&
      numero.trim().isEmpty &&
      codePostal.trim().isEmpty &&
      ville.trim().isEmpty;

  /// Ligne voie : « 12 rue de la Paix ».
  String get streetLine {
    final parts = <String>[];
    final n = numero.trim();
    final name = voieNom.trim();
    if (n.isNotEmpty) parts.add(n);
    if (name.isNotEmpty) {
      final type = voieType.trim().isEmpty
          ? PostalVoieTypes.defaultType
          : voieType.trim();
      parts.add('${type.toLowerCase()} $name');
    }
    return parts.join(' ');
  }

  /// Ligne complète pour [client_profiles.adresse].
  String get formattedLine {
    final segments = <String>[];
    final street = streetLine;
    if (street.isNotEmpty) segments.add(street);

    final cp = codePostal.trim();
    final city = ville.trim();
    if (cp.isNotEmpty && city.isNotEmpty) {
      segments.add('$cp $city');
    } else if (city.isNotEmpty) {
      segments.add(city);
    } else if (cp.isNotEmpty) {
      segments.add(cp);
    }

    final country = pays.trim();
    if (country.isNotEmpty) segments.add(country);
    return segments.join(', ');
  }

  /// Reprend une adresse enregistrée (texte libre ou format structuré).
  static PostalAddress tryParse(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return const PostalAddress();

    final segments = value.split(',').map((s) => s.trim()).toList();
    var voieType = PostalVoieTypes.defaultType;
    var voieNom = '';
    var numero = '';
    var codePostal = '';
    var ville = '';
    var pays = defaultCountry;

    String? streetSegment;
    if (segments.isNotEmpty) {
      streetSegment = segments.first;
      if (segments.length >= 2) {
        final cpVille = _parseCpVille(segments[1]);
        codePostal = cpVille.$1;
        ville = cpVille.$2;
      }
      if (segments.length >= 3) {
        pays = segments.sublist(2).join(', ').trim();
      }
    }

    if (streetSegment != null && streetSegment.isNotEmpty) {
      final parsedStreet = _parseStreet(streetSegment);
      voieType = parsedStreet.$1;
      voieNom = parsedStreet.$2;
      numero = parsedStreet.$3;
    }

    if (ville.isEmpty && segments.length == 1) {
      voieNom = value;
      voieType = PostalVoieTypes.defaultType;
      numero = '';
    }

    return PostalAddress(
      voieType: voieType,
      voieNom: voieNom,
      numero: numero,
      codePostal: codePostal,
      ville: ville,
      pays: pays.isEmpty ? defaultCountry : pays,
    );
  }

  static (String, String) _parseCpVille(String segment) {
    final match = RegExp(r'^(\d{4,5})\s+(.+)$').firstMatch(segment.trim());
    if (match != null) {
      return (match.group(1)!, match.group(2)!.trim());
    }
    return ('', segment.trim());
  }

  static (String, String, String) _parseStreet(String segment) {
    final trimmed = segment.trim();
    final numeroMatch = RegExp(r'^(\d+[A-Za-z]?)\s+(.+)$').firstMatch(trimmed);
    final rest = numeroMatch != null ? numeroMatch.group(2)! : trimmed;
    final numero = numeroMatch?.group(1) ?? '';

    for (final type in PostalVoieTypes.all) {
      final pattern = RegExp('^${RegExp.escape(type)}\\s+(.+)', caseSensitive: false);
      final match = pattern.firstMatch(rest);
      if (match != null) {
        return (type, match.group(1)!.trim(), numero);
      }
    }

    return (PostalVoieTypes.defaultType, rest, numero);
  }
}

abstract final class PostalVoieTypes {
  PostalVoieTypes._();

  static const defaultType = 'Rue';

  static const all = [
    'Rue',
    'Avenue',
    'Boulevard',
    'Place',
    'Allée',
    'Impasse',
    'Chemin',
    'Passage',
    'Quai',
    'Route',
    'Square',
    'Cours',
    'Résidence',
    'Voie',
    'Sentier',
  ];
}
