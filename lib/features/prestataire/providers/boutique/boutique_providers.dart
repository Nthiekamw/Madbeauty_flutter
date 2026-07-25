import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/domain/catalog/boutique_commande.dart';
import '../../../../core/models/domain/catalog/pack_offre.dart';
import '../../../../core/models/domain/catalog/pack_offre_detail.dart';
import '../../../../core/models/domain/catalog/produit_boutique.dart';
import '../../../../core/models/domain/catalog/service_beaute.dart';
import '../../../../services/supabase/prestataire/boutique/boutique_providers.dart';
import '../../../../services/supabase/prestataire/services/service_beaute_providers.dart';
import '../profile/current_prestataire_provider.dart';

/// Produits du prestataire connecté (y compris inactifs pour gestion).
final ownProduitsBoutiqueProvider =
    FutureProvider.autoDispose<List<ProduitBoutique>>((ref) async {
  final presta = await ref.watch(currentPrestataireProvider.future);
  final service = ref.watch(produitBoutiqueServiceProvider);
  if (presta == null || service == null) return const [];
  return service.getByPrestataire(presta.id, actifsOnly: false);
});

/// Packs du prestataire connecté (y compris brouillons).
final ownPacksOffreProvider =
    FutureProvider.autoDispose<List<PackOffre>>((ref) async {
  final presta = await ref.watch(currentPrestataireProvider.future);
  final service = ref.watch(packOffreServiceProvider);
  if (presta == null || service == null) return const [];
  return service.listByPrestataire(presta.id, actifsOnly: false);
});

class PrestataireBoutiqueSummary {
  const PrestataireBoutiqueSummary({
    required this.produitsActifs,
    required this.packsActifs,
    this.commandesOuvertes = 0,
  });

  final int produitsActifs;
  final int packsActifs;
  final int commandesOuvertes;

  static const empty = PrestataireBoutiqueSummary(
    produitsActifs: 0,
    packsActifs: 0,
  );
}

final ownBoutiqueSummaryProvider =
    FutureProvider.autoDispose<PrestataireBoutiqueSummary>((ref) async {
  final presta = await ref.watch(currentPrestataireProvider.future);
  final produitSvc = ref.watch(produitBoutiqueServiceProvider);
  final packSvc = ref.watch(packOffreServiceProvider);
  final commandeSvc = ref.watch(boutiqueCommandeServiceProvider);
  if (presta == null || produitSvc == null || packSvc == null) {
    return PrestataireBoutiqueSummary.empty;
  }
  final results = await Future.wait([
    produitSvc.countActifs(presta.id),
    packSvc.countActifs(presta.id),
    if (commandeSvc != null)
      commandeSvc.countOpenForPrestataire(presta.id)
    else
      Future.value(0),
  ]);
  return PrestataireBoutiqueSummary(
    produitsActifs: results[0],
    packsActifs: results[1],
    commandesOuvertes: results[2],
  );
});

final ownBoutiqueCommandesProvider =
    FutureProvider.autoDispose<List<BoutiqueCommande>>((ref) async {
  final presta = await ref.watch(currentPrestataireProvider.future);
  final service = ref.watch(boutiqueCommandeServiceProvider);
  if (presta == null || service == null) return const [];
  return service.listForPrestataire(presta.id);
});

final ownBoutiqueOrdersOpenCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final presta = await ref.watch(currentPrestataireProvider.future);
  final service = ref.watch(boutiqueCommandeServiceProvider);
  if (presta == null || service == null) return 0;
  return service.countOpenForPrestataire(presta.id);
});

/// Produits publics d’un prestataire (fiche cliente).
final publicProduitsBoutiqueProvider = FutureProvider.autoDispose
    .family<List<ProduitBoutique>, String>((ref, prestataireId) async {
  final service = ref.watch(produitBoutiqueServiceProvider);
  if (service == null || prestataireId.isEmpty) return const [];
  return service.getByPrestataire(prestataireId, actifsOnly: true);
});

/// Packs publics d’un prestataire (fiche cliente).
final publicPacksOffreDetailProvider = FutureProvider.autoDispose
    .family<List<PackOffreDetail>, String>((ref, prestataireId) async {
  final packSvc = ref.watch(packOffreServiceProvider);
  final produitSvc = ref.watch(produitBoutiqueServiceProvider);
  final serviceSvc = ref.watch(serviceBeauteServiceProvider);
  if (packSvc == null || prestataireId.isEmpty) return const [];

  final services = serviceSvc == null
      ? const <ServiceBeaute>[]
      : await serviceSvc.getByPrestataire(prestataireId);
  final produits = produitSvc == null
      ? const <ProduitBoutique>[]
      : await produitSvc.getByPrestataire(prestataireId);

  return packSvc.listDetailsByPrestataire(
    prestataireId,
    actifsOnly: true,
    servicesById: {for (final s in services) s.id: s},
    produitsById: {for (final p in produits) p.id: p},
  );
});
