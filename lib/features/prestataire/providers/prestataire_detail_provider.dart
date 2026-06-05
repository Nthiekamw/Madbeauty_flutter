import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/domain/availability/horaire_plage.dart';
import '../../../core/models/domain/catalog/photo_realisation.dart';
import '../../../core/models/domain/catalog/service_beaute.dart';
import '../../../core/models/domain/reviews/avis.dart';
import '../../../core/models/domain/user/prestataire_profile.dart';
import '../../../services/supabase/disponibilite/disponibilite_service_providers.dart';
import '../../../services/supabase/prestataire/catalog/prestataire_catalog_providers.dart';
import '../../../services/supabase/profile/profile_providers.dart';
import 'prestataire_photos_provider.dart';
import 'prestataire_services_provider.dart';

class PrestataireDetailData {
  const PrestataireDetailData({
    required this.profile,
    this.avatarUrl,
    required this.specialtyNames,
    required this.services,
    required this.photos,
    required this.horaires,
    required this.reviews,
  });

  final PrestataireProfile profile;
  final String? avatarUrl;
  final List<String> specialtyNames;
  final List<ServiceBeaute> services;
  final List<PhotoRealisation> photos;
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
      final specialtyNames = await prestataireService.getSpecialtyNames(
        prestataireId,
      );
      final services = await ref.watch(servicesProvider(prestataireId).future);
      final photos = await ref.watch(
        realisationPhotosProvider(prestataireId).future,
      );

      final disponibiliteService = ref.watch(disponibiliteServiceProvider);
      final horaires = disponibiliteService != null
          ? await disponibiliteService.getHoraires(prestataireId)
          : <HorairePlage>[];

      return PrestataireDetailData(
        profile: profile,
        avatarUrl: userProfile?.avatarUrl,
        specialtyNames: specialtyNames,
        services: services,
        photos: photos,
        horaires: horaires,
        reviews: const [],
      );
    });

