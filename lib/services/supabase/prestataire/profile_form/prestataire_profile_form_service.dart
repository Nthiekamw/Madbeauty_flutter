import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/supabase_error_handler.dart';
import '../../../../core/models/domain/catalog/service_category.dart';
import '../../../location/geocoding_service.dart';
import '../../profile/profile_service.dart';
import '../../storage/storage_service.dart';
import '../catalog/prestataire_filters.dart';
import '../catalog/prestataire_service.dart';
import '../services/service_beaute_service.dart';

class PrestataireServiceFormData {
  const PrestataireServiceFormData({
    this.id,
    required this.nom,
    required this.prix,
    required this.dureeMinutes,
  });

  final String? id;
  final String nom;
  final double prix;
  final int dureeMinutes;
}

class PrestataireProfileFormData {
  const PrestataireProfileFormData({
    this.prestataireId,
    required this.nomSalon,
    required this.bio,
    required this.ville,
    this.avatarUrl,
    required this.categories,
    required this.selectedCategoryIds,
    required this.services,
  });

  final String? prestataireId;
  final String nomSalon;
  final String bio;
  final String ville;
  final String? avatarUrl;
  final List<ServiceCategory> categories;
  final Set<String> selectedCategoryIds;
  final List<PrestataireServiceFormData> services;

  static const empty = PrestataireProfileFormData(
    nomSalon: '',
    bio: '',
    ville: '',
    avatarUrl: null,
    categories: [],
    selectedCategoryIds: {},
    services: [],
  );
}

class PrestataireProfileSavePayload {
  const PrestataireProfileSavePayload({
    required this.nomSalon,
    required this.bio,
    required this.ville,
    this.avatarBytes,
    this.avatarFileName,
    this.avatarMimeType,
    required this.categoryIds,
    required this.services,
  });

  final String nomSalon;
  final String bio;
  final String ville;
  final Uint8List? avatarBytes;
  final String? avatarFileName;
  final String? avatarMimeType;
  final Set<String> categoryIds;
  final List<PrestataireServiceFormData> services;
}

class PrestataireProfileFormService {
  const PrestataireProfileFormService({
    required SupabaseClient client,
    required PrestataireService prestataireService,
    required ServiceBeauteService serviceBeauteService,
    required ProfileService profileService,
    required StorageService storageService,
    required GeocodingService geocodingService,
  }) : _client = client,
       _prestataireService = prestataireService,
       _serviceBeauteService = serviceBeauteService,
       _profileService = profileService,
       _storageService = storageService,
       _geocodingService = geocodingService;

  final SupabaseClient _client;
  final PrestataireService _prestataireService;
  final ServiceBeauteService _serviceBeauteService;
  final ProfileService _profileService;
  final StorageService _storageService;
  final GeocodingService _geocodingService;

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
          bio: '',
          ville: '',
          avatarUrl: userProfile?.avatarUrl,
          categories: categories,
          selectedCategoryIds: const {},
          services: const [],
        );
      }

      final specialtyData = await _prestataireService
          .getSpecialtyDataForPrestataires([prestataire.id]);
      final services = await _serviceBeauteService.getByPrestataire(
        prestataire.id,
      );

      return PrestataireProfileFormData(
        prestataireId: prestataire.id,
        nomSalon: prestataire.nomSalon?.trim() ?? '',
        bio: prestataire.bio?.trim() ?? '',
        ville: prestataire.ville?.trim() ?? '',
        avatarUrl: userProfile?.avatarUrl,
        categories: categories,
        selectedCategoryIds: Set<String>.from(
          specialtyData.categoryIdsByPrestataire[prestataire.id] ?? const {},
        ),
        services: services.map((service) {
          return PrestataireServiceFormData(
            id: service.id,
            nom: service.nom,
            prix: service.prix,
            dureeMinutes: service.dureeMinutes,
          );
        }).toList(),
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
      }

      final coords = await _geocodingService.geocodeAddress(payload.ville);

      final prestataireId = await _prestataireService.upsert(
        PrestataireUpsertData(
          userId: user.id,
          nomSalon: payload.nomSalon,
          bio: payload.bio,
          ville: payload.ville,
          latitude: coords?.latitude,
          longitude: coords?.longitude,
        ),
      );

      await _prestataireService.replaceSpecialties(
        prestataireId: prestataireId,
        categoryIds: payload.categoryIds,
      );
      await _syncServices(prestataireId, payload.services);
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
          prix: service.prix,
          dureeMinutes: service.dureeMinutes,
        ),
      );
    }
  }
}
