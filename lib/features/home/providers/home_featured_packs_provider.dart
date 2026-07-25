import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/supabase/prestataire/boutique/boutique_providers.dart';
import '../../../services/supabase/prestataire/boutique/pack_offre_service.dart';

/// Packs / offres mis en avant sur l’accueil client.
final homeFeaturedPacksProvider =
    FutureProvider.autoDispose<List<PackOffreHomeEntry>>((ref) async {
  final service = ref.watch(packOffreServiceProvider);
  if (service == null) return const [];
  return service.listFeaturedForHome();
});
