import '../../geo/geo_point.dart';
import 'postal_address.dart';

/// Suggestion d'adresse issue d'une source externe (BAN, géocodeur…).
class PostalAddressSuggestion {
  const PostalAddressSuggestion({
    required this.label,
    required this.address,
    this.location,
    this.score,
    this.source = 'manual',
  });

  final String label;
  final PostalAddress address;
  final GeoPoint? location;
  final double? score;
  final String source;
}
