import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../storage/storage_providers.dart';
import '../../profile/profile_providers.dart';
import '../../supabase_service.dart';
import 'pack_offre_service.dart';
import 'produit_boutique_service.dart';
import 'boutique_commande_service.dart';

final produitBoutiqueServiceProvider = Provider<ProduitBoutiqueService?>((ref) {
  if (!AppConfig.hasSupabase) return null;
  return ProduitBoutiqueService(
    SupabaseService.client,
    storageService: ref.watch(storageServiceProvider),
  );
});

final packOffreServiceProvider = Provider<PackOffreService?>((ref) {
  if (!AppConfig.hasSupabase) return null;
  return PackOffreService(
    SupabaseService.client,
    storageService: ref.watch(storageServiceProvider),
  );
});

final boutiqueCommandeServiceProvider =
    Provider<BoutiqueCommandeService?>((ref) {
  if (!AppConfig.hasSupabase) return null;
  return BoutiqueCommandeService(
    SupabaseService.client,
    profileService: ref.watch(profileServiceProvider),
  );
});
