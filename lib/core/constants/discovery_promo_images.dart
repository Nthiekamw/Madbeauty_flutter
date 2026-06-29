/// Images promo Unsplash vérifiées (HTTP 200) — accueil, catalogue, etc.
abstract final class DiscoveryPromoImages {
  DiscoveryPromoImages._();

  static const _base = 'https://images.unsplash.com';

  /// IDs photo (pour référence / tests).
  static const barberId = 'photo-1521590832167-7bcbfaa6381f';
  static const makeupId = 'photo-1487412947147-5cebf100ffc2';
  static const manicureId = 'photo-1604654894610-df63bc536371';
  static const hairSalonId = 'photo-1560066984-138dadb4c035';
  static const spaId = 'photo-1516975080664-ed2fc6a32937';
  static const nailTechId = 'photo-1632345031435-8727f6897d53';
  static const plantAccentId = 'photo-1490750967868-88aa4486c946';

  /// Bannière accueil (portrait ~4:5).
  static const barberHome =
      '$_base/$barberId?w=400&h=500&fit=crop&q=80';
  static const makeupHome =
      '$_base/$makeupId?w=400&h=500&fit=crop&q=80';
  static const manicureHome =
      '$_base/$manicureId?w=400&h=500&fit=crop&q=80';
  static const hairSalonHome =
      '$_base/$hairSalonId?w=400&h=500&fit=crop&q=80';
  static const spaHome = '$_base/$spaId?w=400&h=500&fit=crop&q=80';
  static const nailTechHome =
      '$_base/$nailTechId?w=400&h=500&fit=crop&q=80';
  static const plantAccentHome =
      '$_base/$plantAccentId?w=240&h=240&fit=crop&q=70';

  /// Carrousel catalogue (carré).
  static const hairSalonListing =
      '$_base/$hairSalonId?w=400&h=400&fit=crop&q=80';
  static const manicureListing =
      '$_base/$manicureId?w=400&h=400&fit=crop&q=80';
  static const makeupListing =
      '$_base/$makeupId?w=400&h=400&fit=crop&q=80';
  static const spaListing =
      '$_base/$spaId?w=400&h=400&fit=crop&q=80';
}
