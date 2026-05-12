import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/domain/user/prestataire_profile.dart';
import '../../../services/supabase/prestataire_catalog_providers.dart';

final prestataireDetailProvider =
    FutureProvider.autoDispose.family<PrestataireProfile?, String>(
  (ref, prestataireId) async {
    final repo = ref.watch(prestataireCatalogRepositoryProvider);
    if (repo == null) return null;
    return repo.fetchPrestataireById(prestataireId);
  },
);
