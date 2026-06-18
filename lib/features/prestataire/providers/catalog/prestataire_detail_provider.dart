import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/domain/availability/horaire_plage.dart';
import '../../../../core/models/domain/catalog/photo_realisation.dart';
import '../../../../core/models/domain/catalog/service_beaute.dart';
import '../../../../core/models/domain/reviews/avis.dart';
import '../../../../core/models/domain/user/prestataire_profile.dart';
import '../../../../services/supabase/disponibilite/disponibilite_service_providers.dart';
import '../../../../services/supabase/prestataire/catalog/prestataire_catalog_providers.dart';
import '../../../../services/supabase/profile/profile_providers.dart';
import '../../../../core/constants/app_strings.dart';
import '../../logic/realisation_gallery_grouping.dart';
import '../../logic/prestataire_services_grouping.dart';
import '../profile/prestataire_photos_provider.dart';
import '../profile/prestataire_services_provider.dart';

class PrestataireDetailData {
  const PrestataireDetailData({
    required this.profile,
    this.avatarUrl,
    required this.specialtyNames,
    required this.specialtyGroups,
    required this.services,
    required this.photos,
    required this.gallerySections,
    required this.horaires,
    required this.reviews,
  });

  final PrestataireProfile profile;
  final String? avatarUrl;
  final List<String> specialtyNames;
  final List<PrestataireSpecialtyServiceGroup> specialtyGroups;
  final List<ServiceBeaute> services;
  final List<PhotoRealisation> photos;
  final List<RealisationPhotosServiceSection> gallerySections;
  final List<HorairePlage> horaires;
  final List<Avis> reviews;
}

final prestataireDetailProvider = FutureProvider.autoDispose
    .family<PrestataireDetailData?, String>((ref, prestataireId) async {
      final prestataireService = ref.watch(prestataireServiceProvider);
      final profileService = ref.watch(profileServiceProvider);
      if (prestataireService == null || profileService == null) {
        return null;
      }

      final profile = await prestataireService.getById(prestataireId);
      if (profile == null) return null;

      final userProfile = await profileService.getByUserId(profile.userId);
      final specialtyData = await prestataireService
          .getSpecialtyDataForPrestataires([prestataireId]);
      final specialtyNames = List<String>.from(
        specialtyData.namesByPrestataire[prestataireId] ?? const [],
      );
      final services = await ref.watch(servicesProvider(prestataireId).future);
      final categoryIds =
          specialtyData.categoryIdsByPrestataire[prestataireId] ?? const {};
      final specialtyGroups = buildPrestataireSpecialtyGroups(
        categoryIds: categoryIds,
        services: services,
      );
      final photos = await ref.watch(
        realisationPhotosProvider(prestataireId).future,
      );
      final gallerySections = groupRealisationPhotosByService(
        photos: photos,
        services: services,
        catalogSelection: catalogSelectionFromCategoryIds(categoryIds),
        categoryIds: categoryIds,
        uncategorizedServiceTitle: DiscPrestaDetail.galleryOtherService,
        uncategorizedSpecialtyLabel: DiscPrestaDetail.galleryOtherSpecialty,
      );

      final disponibiliteService = ref.watch(disponibiliteServiceProvider);
      final horaires = disponibiliteService != null
          ? await disponibiliteService.getHoraires(prestataireId)
          : <HorairePlage>[];

      return PrestataireDetailData(
        profile: profile,
        avatarUrl: userProfile?.avatarUrl,
        specialtyNames: specialtyNames,
        specialtyGroups: specialtyGroups,
        services: services,
        photos: photos,
        gallerySections: gallerySections,
        horaires: horaires,
        reviews: const [],
      );
    });

