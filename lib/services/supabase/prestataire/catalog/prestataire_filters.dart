class PrestataireFilters {
  const PrestataireFilters({
    this.query,
    this.categoryId,
    this.limit = 10,
    this.offset = 0,
  });

  final String? query;
  final String? categoryId;
  final int limit;
  final int offset;
}

class PrestataireUpsertData {
  const PrestataireUpsertData({
    required this.userId,
    required this.nomSalon,
    required this.bio,
    required this.ville,
    this.latitude,
    this.longitude,
  });

  final String userId;
  final String nomSalon;
  final String bio;
  final String ville;
  final double? latitude;
  final double? longitude;
}
