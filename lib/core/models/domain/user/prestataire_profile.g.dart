// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prestataire_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PrestataireProfile _$PrestataireProfileFromJson(Map<String, dynamic> json) =>
    _PrestataireProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      nomSalon: json['nom_salon'] as String?,
      bio: json['bio'] as String?,
      ville: json['ville'] as String?,
      adresse: json['adresse'] as String?,
      codePostal: json['code_postal'] as String?,
      pays: json['pays'] as String?,
      nomAffiche: json['nom_affiche'] as String?,
      lieuTravail: const LieuTravailConverter().fromJson(
        json['lieu_travail'] as String?,
      ),
      anneesExperience: json['annees_experience'] as String?,
      experienceProfessionnelle: json['experience_professionnelle'] as String?,
      description: json['description'] as String?,
      confortClient:
          (json['confort_client'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      conditionsService: json['conditions_service'] == null
          ? const []
          : _conditionsServiceFromJson(json['conditions_service']),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      noteMoyenne: (json['note_moyenne'] as num?)?.toDouble(),
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: const IsoDateTimeConverter().fromJson(json['created_at']),
    );

Map<String, dynamic> _$PrestataireProfileToJson(_PrestataireProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'nom_salon': instance.nomSalon,
      'bio': instance.bio,
      'ville': instance.ville,
      'adresse': instance.adresse,
      'code_postal': instance.codePostal,
      'pays': instance.pays,
      'nom_affiche': instance.nomAffiche,
      'lieu_travail': const LieuTravailConverter().toJson(instance.lieuTravail),
      'annees_experience': instance.anneesExperience,
      'experience_professionnelle': instance.experienceProfessionnelle,
      'description': instance.description,
      'confort_client': instance.confortClient,
      'conditions_service': instance.conditionsService,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'note_moyenne': instance.noteMoyenne,
      'is_verified': instance.isVerified,
      'created_at': const IsoDateTimeConverter().toJson(instance.createdAt),
    };
