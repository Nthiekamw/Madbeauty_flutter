import '../../../../core/models/domain/user/lieu_travail.dart';

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
    this.adresse,
    this.codePostal,
    this.nomAffiche,
    this.lieuTravail,
    this.anneesExperience,
    this.experienceProfessionnelle,
    this.description,
    this.confortClient = const [],
    this.conditionsService = const [],
    this.latitude,
    this.longitude,
  });

  final String userId;
  final String nomSalon;
  final String bio;
  final String ville;
  final String? adresse;
  final String? codePostal;
  final String? nomAffiche;
  final LieuTravail? lieuTravail;
  final String? anneesExperience;
  final String? experienceProfessionnelle;
  final String? description;
  final List<String> confortClient;
  final List<String> conditionsService;
  final double? latitude;
  final double? longitude;
}

