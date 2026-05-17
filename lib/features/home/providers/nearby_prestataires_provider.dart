import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/geo/discovery_reference.dart';
import '../../../core/models/domain/user/prestataire_profile.dart';
import '../../../services/supabase/prestataire/catalog/prestataire_catalog_providers.dart';
import '../../listing/providers/client_location_provider.dart';

/// Profils prestataires pour la section « proches » de l’accueil client.
final nearbyPrestatairesProvider =
    FutureProvider.autoDispose<List<PrestataireProfile>>((ref) async {
      final service = ref.watch(prestataireServiceProvider);
      if (service == null) return const [];

      final clientLocation = await ref.watch(clientLocationProvider.future);
      if (clientLocation != null) {
        return service.getNearby(
          clientLocation.latitude,
          clientLocation.longitude,
          kNearbyPrestatairesRadiusKm,
        );
      }

      return service.getNearbyFromReference(
        rayonKm: kNearbyPrestatairesRadiusKm,
      );
    });
