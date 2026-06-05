import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/supabase_error_handler.dart';
import '../../../../core/models/domain/catalog/photo_realisation.dart';
import '../../../../core/models/user_role.dart';
import '../../../auth/role_service.dart';
import '../../../../core/models/domain/catalog/service_category.dart';
import '../../../../core/models/domain/user/lieu_travail.dart';
import '../../../location/geocoding_service.dart';
import '../../profile/profile_service.dart';
import '../../storage/storage_service.dart';
import '../catalog/categorie_suggestion_service.dart';
import '../catalog/prestataire_filters.dart';
import '../catalog/prestataire_service.dart';
import '../photos/photo_realisation_service.dart';
import '../services/service_beaute_service.dart';

class PrestataireServiceFormData {
  const PrestataireServiceFormData({
    this.id,
    required this.nom,
    this.description = '',
    this.categorieId,
    this.prix = 0,
    this.dureeMinutes = 60,
  });

  final String? id;
  final String nom;
  final String description;
  final String? categorieId;
  final double prix;
  final int dureeMinutes;
}

class PrestataireProfileFormData {
  const PrestataireProfileFormData({
    this.prestataireId,
    required this.nomSalon,
    required this.nomAffiche,
    required this.bio,
    required this.description,
    required this.experienceProfessionnelle,
    required this.anneesExperience,
    required this.ville,
    this.adresse = '',
    this.codePostal = '',
    this.lieuTravail,
    this.avatarUrl,
    required this.categories,
    required this.selectedCategoryIds,
    required this.services,
    this.realisationPhotos = const [],
    this.suggestionCategorieNom = '',
    this.suggestionCategorieDescription = '',
    this.customSpecialtyLabels = const [],
    this.confortClient = const [],
    this.conditionsService = const [],
  });

  final String? prestataireId;
  final String nomSalon;
  final String nomAffiche;
  final String bio;
  final String description;
  final String experienceProfessionnelle;
  final String anneesExperience;
  final String ville;
  final String adresse;
  final String codePostal;
  final LieuTravail? lieuTravail;
  final String? avatarUrl;
  final List<ServiceCategory> categories;
  final Set<String> selectedCategoryIds;
  final List<PrestataireServiceFormData> services;
  final List<PhotoRealisation> realisationPhotos;
  final String suggestionCategorieNom;
  final String suggestionCategorieDescription;
  final List<String> customSpecialtyLabels;
  final List<String> confortClient;
  final List<String> conditionsService;

  static const empty = PrestataireProfileFormData(
    nomSalon: '',
    nomAffiche: '',
    bio: '',
    description: '',
    experienceProfessionnelle: '',
    anneesExperience: '',
    ville: '',
    adresse: '',
    codePostal: '',
    lieuTravail: null,
    avatarUrl: null,
    categories: [],
    selectedCategoryIds: {},
    services: [],
    realisationPhotos: [],
    suggestionCategorieNom: '',
    suggestionCategorieDescription: '',
    customSpecialtyLabels: [],
    confortClient: [],
    conditionsService: const [],
  );
}

class PrestataireProfileSavePayload {
  const PrestataireProfileSavePayload({
    required this.nomSalon,
    required this.nomAffiche,
    required this.bio,
    required this.description,
    required this.experienceProfessionnelle,
    required this.anneesExperience,
    required this.ville,
    required this.adresse,
    required this.codePostal,
    required this.lieuTravail,
    this.avatarBytes,
    this.avatarFileName,
    this.avatarMimeType,
    this.avatarUrl,
    required this.services,
    this.suggestionCategorieNom = '',
    this.suggestionCategorieDescription = '',
    this.customSpecialtyLabels = const [],
    this.specialtyCategoryIds,
    this.confortClient = const [],
    this.conditionsService = const [],
  });

  final String nomSalon;
  final String nomAffiche;
  final String bio;
  final String description;
  final String experienceProfessionnelle;
  final String anneesExperience;
  final String ville;
  final String adresse;
  final String codePostal;
  final LieuTravail lieuTravail;
  final Uint8List? avatarBytes;
  final String? avatarFileName;
  final String? avatarMimeType;
  final String? avatarUrl;
  final List<PrestataireServiceFormData> services;
  final String suggestionCategorieNom;
  final String suggestionCategorieDescription;
  final List<String> customSpecialtyLabels;
  final List<String> confortClient;
  final List<String> conditionsService;

  /// Catégories issues du catalogue (prioritaire) ou des services saisis.
  final Set<String>? specialtyCategoryIds;

  Set<String> get categoryIdsFromServices =>
      specialtyCategoryIds ??
      services
          .map((s) => s.categorieId)
          .whereType<String>()
          .where((id) => id.trim().isNotEmpty)
          .toSet();
}

class PrestataireProfileFormService {
  const PrestataireProfileFormService({
    required SupabaseClient client,
    required PrestataireService prestataireService,
    required ServiceBeauteService serviceBeauteService,
    required ProfileService profileService,
    required StorageService storageService,
    required GeocodingService geocodingService,
    PhotoRealisationService? photoRealisationService,
    CategorieSuggestionService? categorieSuggestionService,
  }) : _client = client,
       _prestataireService = prestataireService,
       _serviceBeauteService = serviceBeauteService,
       _profileService = profileService,
       _storageService = storageService,
       _geocodingService = geocodingService,
       _photoRealisationService = photoRealisationService,
       _categorieSuggestionService = categorieSuggestionService;

  final SupabaseClient _client;
  final PrestataireService _prestataireService;
  final ServiceBeauteService _serviceBeauteService;
  final ProfileService _profileService;
  final StorageService _storageService;
  final GeocodingService _geocodingService;
  final PhotoRealisationService? _photoRealisationService;
  final CategorieSuggestionService? _categorieSuggestionService;

  /// Garantit rôle prestataire + ligne profil avant Stripe Checkout / portail.
  Future<String> ensureProfileForBilling() => SupabaseErrorHandler.run(
    operation: 'prestataireProfileForm.ensureProfileForBilling',
    action: () async {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw StateError('Utilisateur non connecté');
      }
      await RoleService(_client).ensureRole(UserRole.prestataire);
      return _prestataireService.ensureProfileForUser(user.id);
    },
  );

  Future<PrestataireProfileFormData> fetch() => SupabaseErrorHandler.run(
    operation: 'prestataireProfileForm.fetch',
    action: () async {
      final user = _client.auth.currentUser;
      if (user == null) return PrestataireProfileFormData.empty;

      final categories = await _prestataireService.getServiceCategories();
      final userProfile = await _profileService.getByUserId(user.id);
      final prestataire = await _prestataireService.getByUserId(user.id);
      if (prestataire == null) {
        return PrestataireProfileFormData(
          nomSalon: '',
          nomAffiche: '',
          bio: '',
          description: '',
          experienceProfessionnelle: '',
          anneesExperience: '',
          ville: '',
          adresse: '',
          codePostal: '',
          avatarUrl: userProfile?.avatarUrl,
          categories: categories,
          selectedCategoryIds: const {},
          services: const [],
          realisationPhotos: const [],
        );
      }

      final specialtyData = await _prestataireService
          .getSpecialtyDataForPrestataires([prestataire.id]);
      final services = await _serviceBeauteService.getByPrestataire(
        prestataire.id,
      );

      final photos = await _photoRealisationService
              ?.getByPrestataire(prestataire.id) ??
          const <PhotoRealisation>[];

      final suggestions = await _categorieSuggestionService
              ?.getByPrestataire(prestataire.id) ??
          const [];
      final suggestion = suggestions.isNotEmpty ? suggestions.first : null;
      final customLabels = suggestions
          .map((s) => s.nom.trim())
          .where((n) => n.isNotEmpty)
          .toList();

      return PrestataireProfileFormData(
        prestataireId: prestataire.id,
        nomSalon: prestataire.nomSalon?.trim() ?? '',
        nomAffiche: prestataire.nomAffiche?.trim() ?? '',
        bio: prestataire.bio?.trim() ?? '',
        description: prestataire.description?.trim() ?? '',
        experienceProfessionnelle:
            prestataire.experienceProfessionnelle?.trim() ?? '',
        anneesExperience: prestataire.anneesExperience?.trim() ?? '',
        ville: prestataire.ville?.trim() ?? '',
        adresse: prestataire.adresse?.trim() ?? '',
        codePostal: prestataire.codePostal?.trim() ?? '',
        lieuTravail: prestataire.lieuTravail,
        avatarUrl: userProfile?.avatarUrl,
        categories: categories,
        selectedCategoryIds: Set<String>.from(
          specialtyData.categoryIdsByPrestataire[prestataire.id] ?? const {},
        ),
        services: services.map((service) {
          return PrestataireServiceFormData(
            id: service.id,
            nom: service.nom,
            description: service.description?.trim() ?? '',
            categorieId: service.categorieId,
            prix: service.prix,
            dureeMinutes: service.dureeMinutes,
          );
        }).toList(),
        realisationPhotos: photos,
        suggestionCategorieNom: suggestion?.nom.trim() ?? '',
        suggestionCategorieDescription: suggestion?.description?.trim() ?? '',
        customSpecialtyLabels: customLabels,
        confortClient: List<String>.from(prestataire.confortClient),
        conditionsService: List<String>.from(prestataire.conditionsService),
      );
    },
  );

  Future<void> save(
    PrestataireProfileSavePayload payload, {
    StorageUploadProgress? onAvatarUploadProgress,
  }) => SupabaseErrorHandler.run(
    operation: 'prestataireProfileForm.save',
    action: () async {
      final user = _client.auth.currentUser;
      if (user == null) throw StateError('Aucun utilisateur connecté.');

      await RoleService(_client).ensureRole(UserRole.prestataire);

      final bytes = payload.avatarBytes;
      if (bytes != null) {
        final avatarUrl = await _storageService.uploadAvatar(
          userId: user.id,
          file: StorageUploadFile(
            bytes: bytes,
            fileName: payload.avatarFileName,
            mimeType: payload.avatarMimeType,
          ),
          onProgress: onAvatarUploadProgress,
        );
        await _profileService.upsertAvatar(
          userId: user.id,
          avatarUrl: avatarUrl,
        );
      } else {
        final avatarUrl = payload.avatarUrl?.trim();
        if (avatarUrl != null && avatarUrl.isNotEmpty) {
          await _profileService.upsertAvatar(
            userId: user.id,
            avatarUrl: avatarUrl,
          );
        }
      }

      final coords = await _geocodingService.geocodeAddress(
        _geocodeQuery(
          adresse: payload.adresse,
          codePostal: payload.codePostal,
          ville: payload.ville,
        ),
      );

      final prestataireId = await _prestataireService.upsert(
        PrestataireUpsertData(
          userId: user.id,
          nomSalon: payload.nomSalon,
          bio: payload.bio,
          ville: payload.ville,
          adresse: payload.adresse.trim().isEmpty ? null : payload.adresse.trim(),
          codePostal:
              payload.codePostal.trim().isEmpty ? null : payload.codePostal.trim(),
          nomAffiche:
              payload.nomAffiche.trim().isEmpty ? null : payload.nomAffiche.trim(),
          lieuTravail: payload.lieuTravail,
          anneesExperience: payload.anneesExperience.trim().isEmpty
              ? null
              : payload.anneesExperience.trim(),
          experienceProfessionnelle:
              payload.experienceProfessionnelle.trim().isEmpty
              ? null
              : payload.experienceProfessionnelle.trim(),
          description: payload.description.trim().isEmpty
              ? null
              : payload.description.trim(),
          confortClient: payload.confortClient,
          conditionsService: payload.conditionsService,
          latitude: coords?.latitude,
          longitude: coords?.longitude,
        ),
      );

      await _prestataireService.replaceSpecialties(
        prestataireId: prestataireId,
        categoryIds: payload.categoryIdsFromServices,
      );
      await _syncServices(prestataireId, payload.services);
      if (payload.customSpecialtyLabels.isNotEmpty) {
        await _categorieSuggestionService?.replaceLabelsForPrestataire(
          prestataireId: prestataireId,
          labels: payload.customSpecialtyLabels,
        );
      } else {
        await _categorieSuggestionService?.replaceForPrestataire(
          prestataireId: prestataireId,
          nom: payload.suggestionCategorieNom,
          description: payload.suggestionCategorieDescription,
        );
      }
    },
  );

  Future<void> _syncServices(
    String prestataireId,
    List<PrestataireServiceFormData> services,
  ) async {
    final existingIds = await _serviceBeauteService.getIdsByPrestataire(
      prestataireId,
    );
    final keptIds = services.map((s) => s.id).whereType<String>().toSet();
    await _serviceBeauteService.deleteManyForPrestataire(
      prestataireId: prestataireId,
      ids: existingIds.difference(keptIds).toList(),
    );

    for (final service in services) {
      await _serviceBeauteService.upsert(
        ServiceBeauteUpsertData(
          id: service.id,
          prestataireId: prestataireId,
          nom: service.nom,
          description: service.description,
          categorieId: service.categorieId,
          prix: service.prix,
          dureeMinutes: service.dureeMinutes,
        ),
      );
    }
  }

  static String _geocodeQuery({
    required String adresse,
    required String codePostal,
    required String ville,
  }) {
    final parts = <String>[
      if (adresse.trim().isNotEmpty) adresse.trim(),
      if (codePostal.trim().isNotEmpty) codePostal.trim(),
      if (ville.trim().isNotEmpty) ville.trim(),
    ];
    return parts.isEmpty ? ville.trim() : parts.join(', ');
  }
}

