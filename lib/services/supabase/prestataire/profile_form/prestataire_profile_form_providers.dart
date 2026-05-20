import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../location/location_providers.dart';
import '../../profile/profile_providers.dart';
import '../../storage/storage_providers.dart';
import '../../supabase_service.dart';
import '../catalog/categorie_suggestion_providers.dart';
import '../catalog/prestataire_catalog_providers.dart';
import '../photos/photo_realisation_providers.dart';
import '../services/service_beaute_providers.dart';
import 'prestataire_profile_form_service.dart';

final prestataireProfileFormServiceProvider =
    Provider<PrestataireProfileFormService?>((ref) {
      final prestataireService = ref.watch(prestataireServiceProvider);
      final serviceBeauteService = ref.watch(serviceBeauteServiceProvider);
      final profileService = ref.watch(profileServiceProvider);
      final storageService = ref.watch(storageServiceProvider);
      if (prestataireService == null ||
          serviceBeauteService == null ||
          profileService == null ||
          storageService == null) {
        return null;
      }

      return PrestataireProfileFormService(
        client: SupabaseService.client,
        prestataireService: prestataireService,
        serviceBeauteService: serviceBeauteService,
        profileService: profileService,
        storageService: storageService,
        geocodingService: ref.watch(geocodingServiceProvider),
        photoRealisationService: ref.watch(photoRealisationServiceProvider),
        categorieSuggestionService:
            ref.watch(categorieSuggestionServiceProvider),
      );
    });
