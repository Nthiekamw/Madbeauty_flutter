import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/domain/user/prestataire_profile.dart';
import '../../../services/supabase/prestataire/catalog/prestataire_catalog_providers.dart';

/// Profils prestataires pour la section « proches » de l’accueil client.
final nearbyPrestatairesProvider =
    FutureProvider.autoDispose<List<PrestataireProfile>>((ref) async {
      final service = ref.watch(prestataireServiceProvider);
      if (service == null) return const [];
      return service.getNearbyFromReference();
    });
